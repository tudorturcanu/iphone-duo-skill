# iPhone Duo Design & Implementation Skill

[![skills.sh](https://skills.sh/b/tudorturcanu/iphone-duo-skill)](https://skills.sh/tudorturcanu/iphone-duo-skill)
[![Antigravity Skill](https://img.shields.io/badge/Antigravity-Skill-blue.svg)](https://antigravity.google)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-orange.svg)](https://anthropic.com)
[![Swift](https://img.shields.io/badge/Swift-6.0-green.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-18%2B-lightgrey.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

An agent skill that teaches AI pair programmers (**Google Antigravity**, **Claude Code**, and compatible agentic tools) how to design, audit, and adapt iOS apps for **iPhone Duo** — Apple's dual-display, hinged iPhone.

---

## 📖 Overview

iPhone Duo introduces a dual-display form factor with a center hinge, dynamic device poses, reserved display regions, and side/vertical control bars.

This skill equips coding assistants to:
1. **Audit existing codebases for resize hostility** (fixed frames, `UIScreen.main.bounds`, homemade tab bars, manual spacers).
2. **Refactor layouts to use native system components** that automatically adapt to side placement, fold avoidance, and overflow.
3. **Avoid API hallucinations** by strictly adhering to confirmed Apple APIs (`NavigationSplitView`, `UIBarButtonItemGroup`, `additionalOverflowItems`) and leaving marked TODOs rather than inventing speculative APIs.
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

<details>
<summary>Manual install with git clone</summary>

| Agent | Scope | Command |
|---|---|---|
| Claude Code | global | `git clone https://github.com/tudorturcanu/iphone-duo-skill.git ~/.claude/skills/iphone-duo-design` |
| Claude Code | project | `git clone https://github.com/tudorturcanu/iphone-duo-skill.git .claude/skills/iphone-duo-design` |
| Antigravity | global | `git clone https://github.com/tudorturcanu/iphone-duo-skill.git ~/.gemini/config/skills/iphone-duo-design` |
| Antigravity | workspace | `git clone https://github.com/tudorturcanu/iphone-duo-skill.git .agents/skills/iphone-duo-design` |
| Any other agent | — | Clone anywhere and point the agent at `SKILL.md`. It is plain Markdown with a `name`/`description` frontmatter, the format used by Claude Code, Antigravity, Codex, Cursor, and other skill-aware tools. |

To update a manual install, run `git pull` inside the cloned folder.
</details>

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

Run the scanner against any iOS codebase. It works with `rg` or plain `grep`, skips `Pods`, `.build`, `DerivedData`, and `node_modules`, and exits `1` when it finds candidates so you can wire it into CI.

```bash
./scripts/audit_duo_readiness.sh path/to/ios/project        # full report
./scripts/audit_duo_readiness.sh path/to/ios/project -q     # only categories with hits
```

It flags 13 categories of anti-pattern, grouped as:

| Group | Examples |
|---|---|
| Display-specific sizing | `UIScreen.main.bounds`, hard-coded iPhone frames, three-digit fixed `.frame(width:)`, `userInterfaceIdiom` layout branches |
| Safe areas & reserved regions | blanket `.ignoresSafeArea()`, magic-number Dynamic Island padding |
| Bars & overflow | `.fixedSpace` and manual `Spacer()`s, custom `ellipsis` menus, hidden system tab bars, image-only `UIBarButtonItem`s, deprecated `NavigationView` |
| The fold | odd grid column counts, orientation locks |

Every hit is a candidate, not a verdict. The agent reads each one in context before changing it.

---

## 🧪 Testing & Evals

Three benchmark prompts with realistic fixtures live in `evals/evals.json`. They are prompts plus expected outcomes, not an automated harness; run them with your agent and grade the result against `expected_output`.

```text
├── SKILL.md                          # Main instruction file
├── scripts/
│   └── audit_duo_readiness.sh        # Fast bash audit tool
├── references/
│   └── apple-hig-designing-for-iphone-duo.md # Condensed HIG reference + confirmed API names
├── evals/
│   └── evals.json                    # Benchmark evals (SwiftUI, UIKit, and Spec)
└── fixtures/
    ├── NotesApp/
    │   ├── NotesRootView.swift       # SwiftUI tab bar anti-pattern fixture
    │   └── NotesListView.swift       # SwiftUI grid & toolbar anti-pattern fixture
    └── GalleryApp/
        └── GalleryViewController.swift # UIKit frame & custom toolbar fixture
```

### Try with Your Agent:
Once installed, test the skill with prompts such as:

> *"We're getting our notes app ready for iPhone Duo. The code is in fixtures/NotesApp/ — audit and refactor it so it adapts properly."*

> *"Our photo gallery screen (fixtures/GalleryApp/GalleryViewController.swift) has a broken toolbar and hardcoded frames on iPhone Duo. Refactor it using native system bars."*

> *"Write an engineering spec for an iPad/iPhone recipe app adapting to the iPhone Duo in book pose."*

---

## 🙏 Attribution

The guidance summarized in `references/` comes from Apple's Human Interface Guidelines article [Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo). The reference file is an original condensation written for agents, not a copy of Apple's text. iPhone, iPhone Duo, and Dynamic Island are trademarks of Apple Inc. This project is not affiliated with Apple.

## 🤝 Contributing

Found an anti-pattern the audit misses, or an API the HIG now names? Open an issue or PR. Keep `SKILL.md` under ~200 lines so it stays cheap for agents to load; put long material in `references/`.

## 📄 License

[MIT](LICENSE)
