# Security Policy

## What this skill does

`iphone-duo-design` is a set of Markdown instructions for AI coding agents, plus one helper script.

- **No installer, no network.** The skill downloads nothing, installs nothing, and makes no network calls.
- **Read-only script.** `skills/iphone-duo-design/scripts/audit_duo_readiness.sh` runs `grep` / `rg` over `*.swift` files in the directory you pass it and prints matches. It never modifies your files; its only writes are temporary files it deletes on exit.
- **Scoped edits.** The instructions tell the agent to change only the app code the user asked about.
- **Declared tools.** `SKILL.md` lists `allowed-tools: Read, Grep, Glob` in its frontmatter.

Only `skills/iphone-duo-design/` is installed. `tests/` and `.github/` stay in this repository.

## Supported versions

Only the latest release on `main` receives fixes.

## Reporting a vulnerability

Please don't open a public issue for a security problem. Use GitHub's
[private vulnerability reporting](https://github.com/tudorturcanu/iphone-duo-skill/security/advisories/new)
for this repository. Include the file, the behavior you saw, and steps to reproduce.

You should get a reply within 7 days.
