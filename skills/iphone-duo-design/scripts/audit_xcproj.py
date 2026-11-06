#!/usr/bin/env python3
"""Read Xcode-emitted .xcproj settings for the shell audit; never modify a project.

Schema: https://github.com/apple/xcode-project-format (Project, Target, BuildSetting).
The Xcode writer emits quoted JSON with comments and trailing commas. Other JSON5
extensions fail explicitly rather than silently producing a clean audit.
"""
import json
import re
import sys
from pathlib import Path


STRING = r'"(?:\\.|[^"\\])*"'
COMMENTS = re.compile(STRING + r'|//[^\r\n]*|/\*.*?\*/', re.S)
TRAILING_COMMAS = re.compile(STRING + r'|,(?=\s*[}\]])', re.S)
SETTING = re.compile(r'([^\[]+)(?:\[[^\]\r\n]+\])*\Z')


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key {key!r}")
        result[key] = value
    return result


def invalid_constant(value):
    raise ValueError(f"unsupported JSON constant {value}")


DECODER = json.JSONDecoder(object_pairs_hook=unique_object, parse_constant=invalid_constant)


def normalize(source):
    """Remove comments/trailing commas without shifting source offsets or lines."""
    def replace(match):
        token = match.group()
        if token.startswith('"'):
            return token
        return re.sub(r'[^\r\n]', ' ', token)
    return TRAILING_COMMAS.sub(replace, COMMENTS.sub(replace, source))


def skip_space(source, offset):
    while offset < len(source) and source[offset].isspace():
        offset += 1
    return offset


def members(source, start):
    """Yield decoded object members plus the original key and value offsets.

    Called only after the whole document has been decoded and validated as JSON.
    The standard decoder skips nested values; no string searches inside scripts.
    """
    offset = skip_space(source, start + 1)
    while source[offset] != '}':
        key_start = offset
        key, offset = DECODER.raw_decode(source, offset)
        offset = skip_space(source, offset) + 1  # colon
        value_start = skip_space(source, offset)
        value, offset = DECODER.raw_decode(source, value_start)
        yield key, value, key_start, value_start
        offset = skip_space(source, offset)
        if source[offset] == ',':
            offset = skip_space(source, offset + 1)


def build_settings(source, start):
    for key, value, _, value_start in members(source, start):
        if key == 'build-settings':
            if not isinstance(value, dict):
                raise ValueError('build-settings must be an object')
            yield from members(source, value_start)


def settings(source):
    project = DECODER.decode(source)
    if not isinstance(project, dict):
        raise ValueError('project must be an object')
    start = skip_space(source, 0)
    yield from build_settings(source, start)
    for key, value, _, value_start in members(source, start):
        if key != 'targets':
            continue
        if not isinstance(value, list) or any(not isinstance(target, dict) for target in value):
            raise ValueError('targets must be an array of objects')
        offset = skip_space(source, value_start + 1)
        while source[offset] != ']':
            yield from build_settings(source, offset)
            _, offset = DECODER.raw_decode(source, offset)
            offset = skip_space(source, offset)
            if source[offset] == ',':
                offset = skip_space(source, offset + 1)


def findings(source):
    clean = normalize(source)
    for key, value, key_start, _ in settings(clean):
        values = [value] if isinstance(value, str) else value
        if not isinstance(values, list) or any(not isinstance(item, str) for item in values):
            raise ValueError(f"build setting {key!r} must be a string or array of strings")
        match = SETTING.fullmatch(key)
        if not match or not any(item.strip().upper() in ('YES', 'TRUE', '1') for item in values):
            continue
        name = match[1]
        if name == 'INFOPLIST_KEY_UIRequiresFullScreen':
            tag = 'UIRequiresFullScreen'
        elif name == 'INFOPLIST_KEY_UIApplicationSceneManifest_Generation':
            tag = 'UIScene configured'
        else:
            continue
        line = source.count('\n', 0, key_start) + 1
        yield line, f'{json.dumps(key)}: {json.dumps(value)}  [{tag}]'


def main(paths):
    # Buffer until every file succeeds so malformed input never yields partial success.
    output = []
    for path in paths:
        try:
            source = Path(path).read_text(encoding='utf-8')
            output.extend(f'{path}:{line}: {message}' for line, message in findings(source))
        except (OSError, UnicodeError, ValueError, RecursionError) as error:
            print(f'Error: cannot audit {path}: {error}. Review the project settings manually; '
                  'expected Xcode-emitted JSON with optional comments and trailing commas.', file=sys.stderr)
            return 2
    if output:
        print('\n'.join(output))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
