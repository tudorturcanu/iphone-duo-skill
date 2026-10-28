# Security Policy

## What this skill does

`iphone-duo-design` is a set of Markdown instructions for AI coding agents, plus read-only audit helpers.

- **No installer, no network.** The skill downloads nothing, installs nothing, and makes no network calls.
- **Read-only scripts.** `skills/iphone-duo-design/scripts/audit_duo_readiness.sh` scans Swift, plist, and Xcode project files in the directory you pass it. Its Python 3 helper, `audit_xcproj.py`, parses JSON settings without evaluating scripts or build-setting expressions. Neither modifies your files; the shell script's only writes are temporary files it deletes on exit. Missing dependencies, malformed/unsupported JSON, search errors, or a folder with no Swift files or Xcode project exit `2` instead of reporting clean.
- **Scoped edits.** The instructions tell the agent to change only the app code the user asked about.
- **Declared tools.** `SKILL.md`'s `allowed-tools` pre-approves `Read`, `Grep`, `Glob`, the read-only audit script,
  and `xcrun simctl list devicetypes`. In Claude Code this skips permission prompts for those calls only; edits to
  your code and any other command still ask. Other agents may ignore the field.

Only `skills/iphone-duo-design/` is installed. `tests/` and `.github/` stay in this repository.

## Supported versions

Only the latest release on `main` receives fixes.

## Reporting a vulnerability

Please don't open a public issue for a security problem. Use GitHub's
[private vulnerability reporting](https://github.com/tudorturcanu/iphone-duo-skill/security/advisories/new)
for this repository. Include the file, the behavior you saw, and steps to reproduce.

You should get a reply within 7 days.
