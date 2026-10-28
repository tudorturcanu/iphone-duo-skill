# iPhone Duo Design & Implementation Skill

[![skills.sh](https://skills.sh/b/tudorturcanu/iphone-duo-skill)](https://skills.sh/tudorturcanu/iphone-duo-skill)
[![Antigravity Skill](https://img.shields.io/badge/Antigravity-Skill-blue.svg)](https://antigravity.google)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-orange.svg)](https://anthropic.com)
[![Swift](https://img.shields.io/badge/Swift-6.0-green.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS%2027.1%20SDK-iPhone%20Duo-lightgrey.svg)](https://developer.apple.com/iphone-duo/)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

An agent skill that teaches AI pair programmers (**Google Antigravity**, **Claude Code**, and compatible agentic tools) how to design, audit, and adapt iOS apps for **iPhone Duo** — Apple's dual-display, hinged iPhone.

**Start here:** [Your first iPhone Duo audit](docs/TUTORIAL.md)—a hands-on walkthrough with a practice copy, two SwiftUI fixes, expected results, everyday tips, and a device-testing checklist.

**Run a native app:** [Duo Playground](apps/DuoPlayground/README.md)—an editable SwiftUI app with live geometry, hinge and reserved-region readings, real arrangement containers, and five experiments for the iPhone Duo simulator.

**Learn interactively:** [Open the developer lab](https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site/lab.html)—five guided experiments with layout controls, fragile/adaptive comparisons, Swift patterns, state continuity, and an event trace.

**Explore visually:** [Open the private Duo Field Guide](https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site) ([source](sites/duo-field-guide/README.md))—six interactive layouts, reserved regions, developer updates, and the tutorial.

---

## 📖 Overview

iPhone Duo introduces a dual-display form factor with a center hinge, dynamic device poses, reserved display regions, and side/vertical control bars.

This skill equips coding assistants to:
1. **Audit existing codebases for resize hostility** (fixed frames, `UIScreen.main.bounds`, homemade tab bars, manual spacers).
2. **Refactor layouts to use native system components** that automatically adapt to side placement, fold avoidance, and overflow.
3. **Use the real iPhone Duo APIs** (iOS 27.1, final in Xcode 27.1; also available in 27.2 RC; checked against Apple's docs): reserved regions (`reservedRegions(kind: .division)`), arrangement views (`ArrangementView`, `UIArrangementViewController`), and the side-bar APIs (`visibilityPriority`, `axisBehavior`, `toolbarVerticalCompressionBehavior`). Anything not in the skill gets a marked TODO instead of an invented name.
4. **Follow Apple Human Interface Guidelines (HIG)** for device poses (flat, book-style, standing) without designing fragmented "per-pose" code branches.
5. **Get the app into the store**: iPhone Duo screenshot and app preview sizes, and the April 2027 screenshot requirement, when you ask about submission.
6. **Handle cameras and the outer display**: the virtual front camera, `AVCaptureDeviceDirectionCoordinator`, and camera capture scene accessories, when the app captures photos or video.
7. **Answer questions beyond layout**: several windows of one app, Picture in Picture, Core Motion on two displays, Live Activities and widgets, web content, and accessibility, from Apple's Group Labs answers.

**How it relates to Apple's own skill.** Xcode 27.1's coding assistant ships an app resizability skill (ask it to "get my app ready for iPhone Duo", or export it for other agents with `xcrun agent skills export`). According to Apple's [Three steps](https://developer.apple.com/iphone-duo/prepare/) page, it scans for resize patterns: main-screen sizing, orientation and idiom checks, device-size comparisons, full-bleed media. This skill's audit covers those patterns too and adds what comes after resizing: side bars and overflow, the fold and reserved regions, arrangement views, cameras, and App Store assets. Use both.

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
| **Outer display (closed)** | `compact` | **On the side** (physical camera edge; unchanged in RTL) | Wider and shorter than classic iPhones; outer camera is always a reserved region |
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

The scanner reads both `.pbxproj` and Xcode 27.2's JSON `.xcproj` configuration. JSON projects need **Python 3** (standard library only). It handles project and target settings, conditional keys, string/array values, comments, and trailing commas, with source line numbers. Missing Python, malformed files, or unsupported JSON5 syntax exit `2`, never clean. Inherited values, target overrides, and external `.xcconfig` files still need review in the actual build.

It flags 20 categories of anti-pattern and one advisory category, grouped as:

| Group | Examples |
|---|---|
| Launch & resizing | a UIKit app delegate with no UIScene life cycle (won't launch with the iOS 27 SDK), `UIRequiresFullScreen` in `Info.plist` or build settings |
| Display-specific sizing | any `UIScreen.main`, `screen.bounds` / `nativeBounds`, hard-coded iPhone dimensions (including `bounds.height == 844` comparisons), fixed frames ≥ 300 pt, `userInterfaceIdiom` and device-model checks, layout branches on `UIDevice.current.orientation`, `statusBarOrientation`, or `interfaceOrientation` |
| Safe areas & reserved regions | blanket `.ignoresSafeArea()` / `(.container, edges: .all)`, `insets.left * 2` math, hard-coded status bar and home indicator insets |
| Bars & overflow | custom `UIToolbar` / `UITabBar` / `UINavigationBar` and homemade tab bars, `.fixedSpace`, `Spacer()` between toolbar items, several controls in one `ToolbarItem`, symbol-only items (SwiftUI and UIKit), custom `ellipsis` menus, hidden system tab bars, disabled side bars, deprecated `NavigationView` |
| The fold | odd column counts in `GridItem` arrays and compositional layouts, orientation locks |
| Wider displays (advisory) | aspect-fill media (`.scaleAspectFill`, `contentMode: .fill`, `.scaledToFill()`) that may crop important content. Aspect fill is usually correct (thumbnails), so these are listed with a `◦` and never change the exit code |

Every hit is a candidate, not a verdict. The agent reads each one in context before changing it.

---

## 🧪 Testing & Evals

Eight benchmark prompts live in `tests/evals/evals.json`, in the [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) format. Each has pass/fail `expectations` to grade against. `files` paths are relative to the repository root, not the skill folder. `tests/evals/trigger_evals.json` holds 28 queries (14 should trigger, 14 near misses such as Galaxy Fold, visionOS, or iPad Stage Manager) for tuning the description.

The prompts cover the SwiftUI fixture, the UIKit fixture, a design spec, already-clean code (no over-editing), the exact fold APIs, App Store submission, what an app built with an older SDK looks like and how to test without the Duo simulator, and Xcode 27.2 RC testing limitations. The new RC prompt has not yet been benchmarked. When running them, give the agent a copy of the fixture with `//` comment lines stripped (the `Clean` and `Patterns` headers describe the expected answer), and compare against a run without the skill. On the last benchmark (v1.3.1, fourth round, one run per prompt, no web access on either side) the skill passed 58 of 59 expectations (98%) against 28 of 59 (47%) without it. The biggest gaps were the fold API question (9/9 vs 2/9), App Store submission (6/6 vs 2/6), and the design spec (10/11 vs 5/11). Runs with the skill used about 29k more tokens and took about 40 seconds longer on average. Seven expectations that an answer with no iPhone Duo knowledge could pass were reworded after this round, so the next baseline will score lower.

CI validates the `SKILL.md` frontmatter (name, description length, `allowed-tools` syntax, version matching `CHANGELOG.md`) and the eval files, runs `shellcheck` on the audit script, and guards the script's accuracy in both directions, with `rg` and with `grep`:
- every line marked `// duo-bad` in `tests/fixtures/Patterns/` must be flagged, and nothing else;
- `tests/fixtures/Clean/` (correct code that looks similar) must report nothing.

Offline Python tests also exercise `.xcproj` detection with both search backends, including clean lookalikes, comments, conditional settings, disabled scene generation, excluded dependencies, parse failures, and missing Python. They verify that source files remain unchanged.

A weekly job (`hig-drift.yml`) fails when Apple changes the HIG article, so the reference gets re-checked. `tests/check_hig.py` keeps one hash per section of the article, so the report names the sections that changed (after reviewing, run `python3 tests/check_hig.py --update`). A third check (`tests/check_apple_sources.py`) compares a few facts from the launch news post, the App Store Connect screenshot and preview specs, the Xcode 27.1 and 27.2 RC release notes (including known/resolved issue status), and Apple's "Three steps" page, and flags new iPhone Duo news posts. Only hashes and section headings are stored, never Apple's text. The same job checks the 64 Apple APIs the skill names (`tests/apple-apis.tsv`) against Apple's docs and fails when one disappears or its availability changes, for example when the iOS 27.1 APIs leave beta. After reviewing a change, run `python3 tests/check_apple_apis.py --update`. Tip: Apple serves HIG and API pages as Markdown at `developer.apple.com/tutorials/data/<path>.md`, which is how the API names in `references/` were verified.

Only `skills/iphone-duo-design/` is installed. Tests and CI stay in the repo.

```text
├── skills/iphone-duo-design/             # ← what gets installed
│   ├── SKILL.md                          # Main instruction file
│   ├── scripts/
│   │   ├── audit_duo_readiness.sh        # Read-only audit script (capped output)
│   │   └── audit_xcproj.py              # Structured JSON project settings (Python 3)
│   └── references/
│       ├── apple-hig-designing-for-iphone-duo.md # Condensed HIG + developer guidance + API reference
│       ├── cameras-and-scene-accessories.md      # Camera direction, virtual front camera, outer-display accessories
│       ├── shipping.md                           # Launch dates, App Store screenshot and preview specs
│       └── system-behaviors.md                   # Windows, Picture in Picture, Core Motion, widgets, web, accessibility
├── tests/
│   ├── evals/evals.json                  # Benchmark evals with graded expectations
│   ├── evals/trigger_evals.json          # Should / shouldn't trigger queries
│   ├── apple-apis.tsv                    # Apple APIs the skill names + recorded availability
│   ├── check_apple_apis.py               # Weekly check of those APIs against Apple's docs
│   ├── check_hig.py                      # Weekly check of the HIG article, one hash per section
│   ├── hig-duo.sha256                    # Those hashes (no Apple text)
│   ├── check_apple_sources.py            # Weekly check of launch news, App Store specs, Xcode status
│   ├── test_apple_sources.py             # Offline release-note status regressions
│   ├── test_xcproj_audit.py              # JSON project audit integration tests
│   └── fixtures/
│       ├── NotesApp/                     # SwiftUI tab bar, grid & toolbar anti-patterns
│       ├── GalleryApp/                   # UIKit frame & custom toolbar anti-patterns
│       ├── Patterns/                     # One marked line per detection; all must be caught
│       └── Clean/                        # Correct look-alike code; must report nothing
├── .github/workflows/
│   ├── ci.yml                            # shellcheck + audit accuracy and output-size tests
│   └── hig-drift.yml                     # Weekly: HIG section hashes, API availability, launch sources
├── docs/TUTORIAL.md                     # Hands-on audit walkthrough and practical tips
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

Found an anti-pattern the audit misses, or an API Apple has added or renamed? Open an issue or PR. Keep `skills/iphone-duo-design/SKILL.md` at 160 lines or fewer (CI enforces it) so it stays cheap for agents to load; put long material in `references/`. Security issues: see [SECURITY.md](SECURITY.md).

## 📄 License

[MIT](LICENSE)
