# Duo Field Guide

A buildless, responsive developer guide with a six-chapter interactive introduction. `dist/` is the deployable site; its pose explorer and tutorial steps work entirely in the browser. The guide keeps only its own demo state in browser storage; it does not send demo messages or collect analytics.

## Start here: the interactive introduction

`dist/index.html` is the entry point. Six chapters introduce the device, available space, reserved regions, system controls, state continuity, and a first implementation. Each chapter pairs an animated diagram with a focused experiment, changing layout signals, and an expandable Swift pattern. The final chapter includes three knowledge-check questions and links to the lab, tutorial, and examples.

Desktop keeps the complete chapter list visible. Mobile uses a labeled chapter selector; previous and next actions work at every size. Shared navigation and topic search (`⌘K` / `Ctrl+K`) connect all ten pages. Search links within the introduction preserve its in-memory draft and selection. Exercise checkpoints and the last chapter are stored in `duo-intro-progress-v2` in localStorage. Visiting a chapter does not complete it. A return visit offers Resume; Reset progress clears checkpoints. Demo drafts remain in memory and clear on reload. The Enlarge control opens the same interactive preview in a keyboard-accessible dialog without replacing its state. Motion starts only on request, stops after one tour, and respects reduced-motion preferences.

Source files: `dist/index.html`, `intro.css`, `intro.js`, `learning-progress.js`, `navigation.js`, and `guide-nav.css`. Reference pages include the shared navigation through `scripts/render-docs.py`.

## Interactive developer lab

Open `lab.html` for five guided experiments: resizing, reserved regions, system bars, state continuity, and a combined challenge. Compare intentionally fragile and adaptive implementations, edit a demo note, inspect Swift patterns, and follow an illustrative event trace. Progress and drafts are held only in browser memory; restarting or reloading clears them.

The pane budget and dimensions are teaching choices, not device measurements, Swift execution, or inferred iOS traits. Source files: `dist/lab.html`, `dist/lab.css`, and `dist/lab.js`.

## Preview

From this folder, run `python3 -m http.server 4173 --directory dist`, then open `http://localhost:4173`.

## Edit

- `dist/index.html`, `intro.css`, and `intro.js`: guided introduction and animated diagrams.
- `dist/navigation.js` and `guide-nav.css`: navigation and topic search shared by every page.
- `styles.css` and `refinement.css`: existing lab and reference styles; `app.js` is the previous explorer implementation.
- `content/`: documentation snapshots copied from the parent skill project for a self-contained hosted site.
- `scripts/render-docs.py`: render the tutorial, source notes, and references using `requirements.txt`. Run after changing the content snapshots. It needs Python and Markdown only at authoring time.
- `.openai/hosting.json`: private Site identity and static output directory.

The explorer is a conceptual diagram, not a simulator. Apple documentation sources and methodology are in `content/sources.md`. No third-party code or media is embedded.

## Validation (27 October 2026)

Verified in the in-app browser at desktop and 390px mobile widths: all five experiment completions; fragile/adaptive comparison; region and camera controls; draft continuity; challenge feedback; clipboard copying; event trace; and keyboard inspector navigation. Internal asset and page links are checked separately. The lab is a JavaScript teaching model; it does not execute Swift or replace device testing.

## Introduction validation (27 October 2026)

Browser QA covers chapter selection, direct links, previous/next navigation, pose transitions, fixed/adaptive resizing, camera and fold guides, system overflow, note selection and draft continuity, all three quiz answers, Swift copying, and filtered topic search. Responsive checks use 1440px, 390px, and 320px viewports. Shared navigation is checked in the lab, examples, tutorial, and API reference. The diagrams teach layout behavior; native Swift behavior is not verified by these browser checks.

Run `python3 scripts/check-site.py` to check all local pages, assets, and reference anchors. Run `node scripts/check-learning.cjs` to verify checkpoint sequences, reset and persistence behavior, and draft privacy. Syntax-check changed JavaScript with `node --check`.

## Native starter and learning update (28 October 2026)

The final chapter compares iOS 26, 27.0, and 27.1+ build SDK layouts, then offers a complete SwiftUI Xcode project in `dist/downloads/DuoNotesStarter.zip`. Its source lives in `starter/DuoNotes/`. Run `python3 scripts/package-starter.py` after editing the starter. The project has no dependencies, targets iOS 26+, and uses Swift 6 with Main Actor default isolation.

The starter compiled successfully for a generic iOS Simulator destination using Xcode 27.1 and the iOS 27.1 SDK. The Duo readiness scan found no common anti-patterns. These checks do not verify simulator runtime or hardware behavior; the starter README includes the manual transition and accessibility checks.

Browser checks cover exercise completion order, incomplete navigation, preview expansion and Escape focus restoration, unchanged drafts across folding, SDK comparisons, resume, and responsive layout.

## Color palette (28 October 2026)

The shared `dist/palette.css` uses surface, text, and action values inspected on [Apple’s iPhone Duo page](https://www.apple.com/iphone-duo/): white `#ffffff`, light gray `#f5f5f7`, ink `#1d1d1f`, secondary text `#6e6e73`, action blue `#0071e3`, and link blue `#0066cc`. Pale blue selection and illustration tints support the guide. Semantic fold, camera, and warning overlays remain distinguishable. All pages load the palette; stylesheet version keys refresh cached styles after this update.

## Interface design

The lab uses a lesson sidebar and a shared preview/inspector workspace. On narrow screens the lesson navigation scrolls horizontally, and the inspector follows the preview. The overview and generated reference pages share `dist/refinement.css`; `dist/lab.css` owns the workspace and diagram layout. Preserve the existing DOM IDs used by `lab.js` when editing the markup.

## Standalone examples

`dist/examples.html`, `examples.css`, and `examples.js` are original interactive Mail, Notes, Media, and Layout examples. Mail supports selection, search, stars, archive, and a local Sent folder. Notes supports editing and checklists. Media synthesizes a small WAV loop locally on the first Play gesture and supplies playback, seeking, and track variations. Layout measures its real web viewport with ResizeObserver; its 620 CSS pixel pane budget is a teaching choice, not an iOS size class.

Open `examples.html` directly. Demo notes, selections, and messages are saved under `duo-studio-examples-v1` in localStorage and synchronized between same-origin browser tabs. No sample email is transmitted.
