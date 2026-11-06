"""Exercise the installed audit end to end, with both search backends."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'skills/iphone-duo-design/scripts/audit_duo_readiness.sh'
FULL_SCREEN = 'INFOPLIST_KEY_UIRequiresFullScreen'
SCENE = 'INFOPLIST_KEY_UIApplicationSceneManifest_Generation'


class XCProjectAuditTests(unittest.TestCase):
    def audit(self, source, expected_code, expected_text=(), absent_text=(), delegate=False, prefix='', no_python=False):
        with tempfile.TemporaryDirectory(prefix='duo xcproj ') as temporary:
            root = Path(temporary)
            project = root / prefix / 'My App:Demo.xcodeproj/project.xcproj'
            if source is not None:
                project.parent.mkdir(parents=True)
                project.write_text(source)
            if delegate:
                (root / 'AppDelegate.swift').write_text('class AppDelegate: UIApplicationDelegate {}\n')
            original = project.read_bytes() if source is not None else None
            env = os.environ.copy()
            env.pop('AUDIT_NO_RG', None)
            if no_python:
                binaries = root / 'bin'
                binaries.mkdir()
                for command in ('dirname', 'mktemp', 'find', 'head', 'grep', 'xargs', 'awk', 'sed',
                                'sort', 'uniq', 'tr', 'wc', 'cut', 'cat', 'rm', 'rg'):
                    executable = shutil.which(command)
                    if executable:
                        (binaries / command).symlink_to(executable)
                env['PATH'] = str(binaries)
            for backend in ('rg', 'grep'):
                with self.subTest(backend=backend):
                    if backend == 'rg' and not shutil.which('rg'):
                        self.skipTest('ripgrep is required to verify both backends')
                    env['AUDIT_NO_RG'] = '1' if backend == 'grep' else ''
                    result = subprocess.run(
                        [shutil.which('bash'), str(SCRIPT), str(root), '-q', '-n', '0'],
                        env=env, capture_output=True, text=True, timeout=30,
                    )
                    output = result.stdout + result.stderr
                    self.assertEqual(result.returncode, expected_code, output)
                    for text in expected_text:
                        self.assertIn(text, output)
                    for text in absent_text:
                        self.assertNotIn(text, output)
                    if original is not None:
                        self.assertEqual(project.read_bytes(), original, 'audit changed the project')

    def test_project_only_with_comments_trailing_commas_arrays_and_conditions(self):
        source = '''{
  // "INFOPLIST_KEY_UIRequiresFullScreen": "YES" is only a comment.
  "build-settings": {
    "INFOPLIST_KEY_UIRequiresFullScreen": "NO",
  },
  "targets": [{
    "name": "Demo",
    "build-settings": {
      "INFOPLIST_KEY_UIRequiresFullScreen[config=Release][sdk=iphoneos*]": [
        "YES",
      ],
    },
  }],
}
'''
        self.audit(source, 1, ('project.xcproj:9:', '1 line(s) flagged in 1 category'),
                   ('project.xcproj:2:', 'project.xcproj:4:'))

    def test_clean_settings_and_lookalikes_in_scripts(self):
        source = json.dumps({
            'build-settings': {FULL_SCREEN: 'NO', FULL_SCREEN + '_DISABLED': 'YES'},
            'targets': [{'build-phases': [{
                'script': '/* not a comment */ "INFOPLIST_KEY_UIRequiresFullScreen": "YES",}',
                'build-settings': {FULL_SCREEN: 'YES'},
            }]}],
        })
        self.audit(source, 0, ('No common iPhone Duo anti-patterns found',), ('[UIRequiresFullScreen]',))

    def test_compact_project_setting_and_escaped_key(self):
        source = '{"build-settings":{"INFOPLIST_KEY_UIRequiresFull\\u0053creen":"YES"}}'
        self.audit(source, 1, ('project.xcproj:1:', '[UIRequiresFullScreen]'))

    def test_multiline_value_and_block_comment_keep_key_line(self):
        source = '''{/* block
        "INFOPLIST_KEY_UIRequiresFullScreen": "YES"
        */ "build-settings": {
  "INFOPLIST_KEY_UIRequiresFullScreen":
  /* more comment */ "YES",
}}
'''
        self.audit(source, 1, ('project.xcproj:4:', '1 line(s) flagged'), ('project.xcproj:2:',))

    def test_scene_generation_yes_is_recognized(self):
        self.audit(json.dumps({'targets': [{'build-settings': {SCENE: 'YES'}}]}), 0,
                   absent_text=('no UIScene life cycle', '[UIScene configured]'), delegate=True)

    def test_disabled_or_mentioned_scene_generation_does_not_hide_missing_scenes(self):
        source = json.dumps({'build-settings': {SCENE: 'NO'}, 'note': SCENE + ' = YES'})
        self.audit(source, 1, ('no UIScene life cycle',), delegate=True)

    def test_tag_in_setting_value_does_not_count_as_scene_evidence(self):
        source = json.dumps({'build-settings': {FULL_SCREEN: ['YES', '[UIScene configured]']}})
        self.audit(source, 1, ('no UIScene life cycle', '[UIRequiresFullScreen]'), delegate=True)

    def test_malformed_or_unsupported_input_cannot_report_clean(self):
        for source in ('{"build-settings":', '{"build-settings": []}', '{"targets": {}}',
                       '{"build-settings":{"KEY":true}}', '{"build-settings":{},"build-settings":{}}',
                       "{'build-settings': {}}", '[]', '{/* unterminated'):
            with self.subTest(source=source):
                self.audit(source, 2, ('cannot audit',), ('No common iPhone Duo anti-patterns',))

    def test_excluded_dependency_projects_are_not_scanned(self):
        self.audit('not even valid JSON', 1, ('no UIScene life cycle',),
                   ('cannot audit', 'UIRequiresFullScreen'), delegate=True, prefix='Pods/Dependency')

    def test_missing_python_is_an_error_only_for_json_projects(self):
        self.audit('{"build-settings":{}}', 2, ('Python 3 is required',),
                   ('No common iPhone Duo anti-patterns',), no_python=True)
        self.audit(None, 1, ('no UIScene life cycle',), ('Python 3 is required',),
                   delegate=True, no_python=True)


if __name__ == '__main__':
    unittest.main()
