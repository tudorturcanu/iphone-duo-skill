# iPhone Duo Design & Implementation Skill

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

### Universal Agent Install (Recommended)

Works across **Antigravity**, **Claude Code**, **Cursor**, **Codex**, and 20+ agents using `npx skills` ([skills.sh](https://skills.sh)):

```bash
# In your iOS project
npx skills add tudorturcanu/iphone-duo-skill

# Or globally on your Mac
npx skills add tudorturcanu/iphone-duo-skill -g
```

### One-Line Shell Install

```bash
curl -fsSL https://raw.githubusercontent.com/tudorturcanu/iphone-duo-skill/main/install.sh | bash
```

### Or Install via Git

#### Antigravity (Workspace / Project-Level)
Installs into your current iOS repository so your entire team shares the skill:
```bash
git clone https://github.com/tudorturcanu/iphone-duo-skill.git .agents/skills/iphone-duo-design
```

#### Antigravity (Global)
Installs across all workspaces on your machine:
```bash
git clone https://github.com/tudorturcanu/iphone-duo-skill.git ~/.gemini/config/skills/iphone-duo-design
```

#### Claude Code
```bash
# Global
git clone https://github.com/tudorturcanu/iphone-duo-skill.git ~/.claude/skills/iphone-duo-design

# Workspace
git clone https://github.com/tudorturcanu/iphone-duo-skill.git .claude/skills/iphone-duo-design
```

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

### 1. Automated Readiness Audit Script
Run the automated scanner against any iOS codebase to detect common iPhone Duo anti-patterns:

```bash
./scripts/audit_duo_readiness.sh path/to/ios/project
```

Detects:
- ❌ Hardcoded frames (`CGRect(x: 0, y: 0, width: 390, ...)`)
- ❌ `UIScreen.main.bounds` dependencies
- ❌ `.userInterfaceIdiom == .phone` branching for layout size
- ❌ Blanket `.ignoresSafeArea()` calls
- ❌ Fixed toolbar spaces (`.fixedSpace`, manual Spacers)
- ❌ Custom ellipsis overflow menus (`systemName: "ellipsis"`)
- ❌ Odd column grid layouts that split down the fold

---

## 🧪 Testing & Evals

The repository includes a complete evaluation suite with realistic test fixtures:

```text
├── SKILL.md                          # Main instruction file
├── install.sh                        # Installer script
├── scripts/
│   └── audit_duo_readiness.sh        # Fast bash audit tool
├── references/
│   └── apple-hig-designing-for-iphone-duo.md # Complete Apple HIG reference
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

## 📄 License

[MIT](LICENSE)
