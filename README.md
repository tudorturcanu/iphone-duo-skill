# iPhone Duo Design Skill

[![skills.sh](https://skills.sh/b/tudorturcanu/iphone-duo-skill)](https://skills.sh/tudorturcanu/iphone-duo-skill)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-orange.svg)](https://anthropic.com)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

An agent skill that teaches your AI coding assistant (Claude Code, Google Antigravity, and other agents that support skills) how to audit, adapt, and build iOS apps for **iPhone Duo**, Apple's dual-display, hinged iPhone.

Install it once, then say "get my app ready for iPhone Duo". The agent audits your code, fixes what breaks, and uses the real iPhone Duo APIs instead of guessing.

New to iPhone Duo? [tryduo.online](https://tryduo.online) is the companion site for this skill: guides and interactive demos of the poses, fold, and reserved regions the skill works with.

## Install

```bash
npx skills add tudorturcanu/iphone-duo-skill -g
```

Drop `-g` to install for the current project only (shared with your team through git). Run the same command again to update.

The skill activates when you mention iPhone Duo, the fold or hinge, device poses, reserved regions, or side toolbars. In Claude Code you can also call it directly with `/iphone-duo-design`.

## What the skill does

- **Audits your code** for layouts that break on iPhone Duo: `UIScreen.main`, fixed frames, device and orientation checks, homemade tab bars, blanket `.ignoresSafeArea()`, and more.
- **Refactors to system components** that adapt on their own to side bars, overflow, and the fold.
- **Uses real APIs**: reserved regions, arrangement views, and the side-bar APIs. Anything it can't verify becomes a marked TODO, not an invented name.
- **Follows Apple's HIG** for poses (flat, book, tabletop) without per-pose code branches.
- **Covers shipping**: iPhone Duo screenshot and app preview sizes, and the App Store requirements.
- **Handles cameras**: the virtual front camera, camera direction, and capture scene accessories for the outer display.
- **Answers the rest**: multiple windows, Picture in Picture, Core Motion, Live Activities and widgets, web content, accessibility.

It works alongside the resizability skill in Xcode 27.1's coding assistant. Apple's skill handles resizing; this one adds side bars, the fold, arrangement views, cameras, and App Store assets. Use both.

## The audit script

The skill bundles a read-only scanner, `audit_duo_readiness.sh`. It searches Swift files, `Info.plist`, and Xcode project settings (`.pbxproj` and Xcode 27.2 JSON `.xcproj`), never changes files, and never touches the network. It exits `1` when it finds candidates, so you can use it in CI.

```bash
S=skills/iphone-duo-design/scripts/audit_duo_readiness.sh
bash $S path/to/ios/project -s   # counts per category
bash $S path/to/ios/project -q   # up to 5 matches per category
bash $S path/to/ios/project -n 0 # every match
```

It checks 20 categories plus one advisory: launch and resizing blockers, display-specific sizing, safe areas, bars and overflow, and the fold. Every hit is a candidate, not a verdict. The agent reads each one in context before changing anything. JSON `.xcproj` projects need Python 3.

## Try it

> *"We're getting our notes app ready for iPhone Duo. The code is in tests/fixtures/NotesApp/. Audit and refactor it so it adapts properly."*

> *"Our photo gallery screen has a broken toolbar and hardcoded frames on iPhone Duo. Refactor it using native system bars."*

> *"Write an engineering spec for a recipe app adapting to iPhone Duo in book pose."*

## Repository layout

Only `skills/iphone-duo-design/` is installed. Everything else is tests and CI.

```text
skills/iphone-duo-design/
├── SKILL.md                  # Main instructions
├── scripts/                  # Audit scanner and .xcproj parser
└── references/               # HIG condensation, cameras, shipping, system behaviors
tests/                        # Evals, fixtures, and Apple doc drift checks
```

## Testing

- `tests/evals/` holds benchmark prompts with graded expectations and trigger queries for tuning the skill description.
- CI validates the `SKILL.md` frontmatter, runs `shellcheck`, and checks the audit script against fixtures in both directions: every `// duo-bad` line must be flagged and the clean fixtures must report nothing.
- A weekly job checks Apple's HIG article, the iPhone Duo APIs the skill names, and Apple's launch and App Store sources, so the references stay current. See [CHANGELOG.md](CHANGELOG.md) for versions.

## Contributing

Found an anti-pattern the audit misses, or an API Apple has added or renamed? Open an issue or PR. Keep `SKILL.md` at 160 lines or fewer (CI enforces it) and put long material in `references/`. Security issues: see [SECURITY.md](SECURITY.md).

## Attribution

The references condense Apple's Human Interface Guidelines article [Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo) in original wording. iPhone, iPhone Duo, and Dynamic Island are trademarks of Apple Inc. This project is not affiliated with Apple.

## License

[MIT](LICENSE)
