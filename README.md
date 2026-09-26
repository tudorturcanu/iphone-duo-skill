# iPhone Duo Design & Implementation Skill

[![skills.sh](https://skills.sh/b/tudorturcanu/iphone-duo-skill)](https://skills.sh/tudorturcanu/iphone-duo-skill)
[![Antigravity Skill](https://img.shields.io/badge/Antigravity-Skill-blue.svg)](https://antigravity.google)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-orange.svg)](https://anthropic.com)
[![Swift](https://img.shields.io/badge/Swift-6.0-green.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS%2027.1%20SDK-iPhone%20Duo-lightgrey.svg)](https://developer.apple.com/iphone-duo/)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

An agent skill that teaches AI pair programmers (**Google Antigravity**, **Claude Code**, and compatible agentic tools) how to design, audit, and adapt iOS apps for **iPhone Duo** — Apple's dual-display, hinged iPhone.

---

## 📖 Overview

iPhone Duo introduces a dual-display form factor with a center hinge, dynamic device poses, reserved display regions, and side/vertical control bars.

This skill equips coding assistants to:
1. **Audit existing codebases for resize hostility** (fixed frames, `UIScreen.main.bounds`, homemade tab bars, manual spacers).
2. **Refactor layouts to use native system components** that automatically adapt to side placement, fold avoidance, and overflow.
3. **Use the real iPhone Duo APIs** (iOS 27.1 beta, checked against Apple's docs): reserved regions (`reservedRegions(kind: .division)`), arrangement views (`ArrangementView`, `UIArrangementViewController`), and the side-bar APIs (`visibilityPriority`, `axisBehavior`, `toolbarVerticalCompressionBehavior`). Anything not in the skill gets a marked TODO instead of an invented name.
4. **Follow Apple Human Interface Guidelines (HIG)** for device poses (flat, book-style, standing) without designing fragmented "per-pose" code branches.

---

## ⚡ Quick Install

Install with the [skills](https://skills.sh) CLI. It detects your agents and lets you pick which ones get the skill.

**Global (all projects)**
```bash
npx skills add tudorturcanu/iphone-duo-skill -g
```

**This project only (shared with your team via git)**
```bash
npx skills add tudorturcanu/iphone-duo-skill
```

Run the same command again to update to the latest version.

Once installed, the skill activates automatically when you mention iPhone Duo, the fold or hinge, device poses, reserved regions, or side/vertical toolbars. You can also invoke it directly with `/iphone-duo-design` in Claude Code.

---

## 🧠 Mental Model

| Surface | Width Class | Bars Placement | Notes |
|---|---|---|---|
| **Outer display (closed)** | `compact` | **On the side** (trailing edge, aligned with camera) | Wider and shorter than classic iPhones; outer camera is always a reserved region |
| **Inner display, landscape** | `regular` | **On the side** | Kept on the side for continuity with the outer display |
| **Inner display, portrait** | `regular` | Standard horizontal bars | The single exception |
| **Inner display, partially folded** | `regular` | Depends on orientation | Folding region splits the display; keep content out of center |
| **Inner display, Split View multitasking** | Varies | Each app puts bars on its **outer** edge | Left app → left edge; right app → right edge |

---

## 🛠 Included Tools

### Automated readiness audit

Run the scanner against any iOS codebase. It is read-only: it searches Swift files, `Info.plist` files, and Xcode build settings, prints matches, and never modifies your files or touches the network. It searches the tree once (with `rg` if installed, otherwise `grep`), skips `Pods`, `.build`, `DerivedData`, and `node_modules`, and exits `1` when it finds candidates so you can wire it into CI.

Output is capped so it stays cheap for an agent to read, even on large codebases.

```bash
S=skills/iphone-duo-design/scripts/audit_duo_readiness.sh
bash $S path/to/ios/project -s       # counts per category only
bash $S path/to/ios/project -q       # up to 5 matches per category, hide clean ones
bash $S path/to/ios/project -n 0     # every match
```

It flags 19 categories of anti-pattern, grouped as:

| Group | Examples |
|---|---|
| Resizing opt-out | `UIRequiresFullScreen` in `Info.plist` or build settings |
| Display-specific sizing | any `UIScreen.main`, `screen.bounds` / `nativeBounds`, hard-coded iPhone dimensions, fixed frames ≥ 300 pt, `userInterfaceIdiom` and device-model checks, `UIDevice.current.orientation` layout branches |
| Safe areas & reserved regions | blanket `.ignoresSafeArea()` / `(.container, edges: .all)`, `insets.left * 2` math, hard-coded status bar and home indicator insets |
| Bars & overflow | custom `UIToolbar` / `UITabBar` / `UINavigationBar` and homemade tab bars, `.fixedSpace`, `Spacer()` between toolbar items, several controls in one `ToolbarItem`, symbol-only items (SwiftUI and UIKit), custom `ellipsis` menus, hidden system tab bars, disabled side bars, deprecated `NavigationView` |
| The fold | odd column counts in `GridItem` arrays and compositional layouts, orientation locks |

Every hit is a candidate, not a verdict. The agent reads each one in context before changing it.

---

## 🧪 Testing & Evals

Five benchmark prompts live in `tests/evals/evals.json`, in the [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) format. Each has pass/fail `expectations` to grade against. `files` paths are relative to the repository root, not the skill folder. `tests/evals/trigger_evals.json` holds 26 queries (13 should trigger, 13 near misses such as Galaxy Fold, visionOS, or iPad Stage Manager) for tuning the description.

The prompts cover the SwiftUI fixture, the UIKit fixture, a design spec, already-clean code (no over-editing), and the exact fold APIs. When running them, give the agent a copy of the fixture with `//` comment lines stripped (the `Clean` and `Patterns` headers describe the expected answer), and compare against a run without the skill. On the last benchmark (v1.2.0) the skill passed 96% of expectations against 63% without it; the biggest gaps were the design spec (9/10 vs 4/10) and the no-over-editing review (5/5 vs 2/5).

CI validates the `SKILL.md` frontmatter (name, description length, `allowed-tools` syntax, version matching `CHANGELOG.md`) and the eval files, runs `shellcheck` on the audit script, and guards the script's accuracy in both directions, with `rg` and with `grep`:
- every line marked `// duo-bad` in `tests/fixtures/Patterns/` must be flagged, and nothing else;
- `tests/fixtures/Clean/` (correct code that looks similar) must report nothing.

A weekly job (`hig-drift.yml`) fails when Apple changes the HIG article, so the reference gets re-checked. It stores only a hash of the article, never Apple's text. Tip: Apple serves HIG and API pages as Markdown at `developer.apple.com/tutorials/data/<path>.md`, which is how the API names in `references/` were verified.

Only `skills/iphone-duo-design/` is installed. Tests and CI stay in the repo.

```text
├── skills/iphone-duo-design/             # ← what gets installed
│   ├── SKILL.md                          # Main instruction file
│   ├── scripts/
│   │   └── audit_duo_readiness.sh        # Read-only audit script (capped output)
│   └── references/
│       └── apple-hig-designing-for-iphone-duo.md # Condensed HIG + developer guidance + API reference
├── tests/
│   ├── evals/evals.json                  # Benchmark evals with graded expectations
│   ├── evals/trigger_evals.json          # Should / shouldn't trigger queries
│   └── fixtures/
│       ├── NotesApp/                     # SwiftUI tab bar, grid & toolbar anti-patterns
│       ├── GalleryApp/                   # UIKit frame & custom toolbar anti-patterns
│       ├── Patterns/                     # One marked line per detection; all must be caught
│       └── Clean/                        # Correct look-alike code; must report nothing
├── .github/workflows/
│   ├── ci.yml                            # shellcheck + audit accuracy and output-size tests
│   └── hig-drift.yml                     # Weekly check for changes to Apple's HIG article
├── SECURITY.md
└── CHANGELOG.md
```

### Try with Your Agent:
Once installed, test the skill with prompts such as:

> *"We're getting our notes app ready for iPhone Duo. The code is in tests/fixtures/NotesApp/ — audit and refactor it so it adapts properly."*

> *"Our photo gallery screen (tests/fixtures/GalleryApp/GalleryViewController.swift) has a broken toolbar and hardcoded frames on iPhone Duo. Refactor it using native system bars."*

> *"Write an engineering spec for an iPad/iPhone recipe app adapting to the iPhone Duo in book pose."*

---

## 🙏 Attribution

The guidance summarized in `skills/iphone-duo-design/references/` comes from Apple's Human Interface Guidelines article [Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo). The reference file is an original condensation written for agents, not a copy of Apple's text. iPhone, iPhone Duo, and Dynamic Island are trademarks of Apple Inc. This project is not affiliated with Apple.

## 🤝 Contributing

Found an anti-pattern the audit misses, or an API Apple has added or renamed? Open an issue or PR. Keep `skills/iphone-duo-design/SKILL.md` under 150 lines (CI enforces it) so it stays cheap for agents to load; put long material in `references/`. Security issues: see [SECURITY.md](SECURITY.md).

## 📄 License

[MIT](LICENSE)
