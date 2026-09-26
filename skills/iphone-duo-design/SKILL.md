---
name: iphone-duo-design
description: Adapts, builds, and reviews SwiftUI and UIKit apps for iPhone Duo, Apple's dual-display hinged iPhone (the folding, book-style iPhone with an outer and inner display). Use whenever the user mentions iPhone Duo, a foldable or dual-screen iPhone, the hinge or fold, half-folded, book or tabletop poses, reserved regions, arrangement views, side or vertical toolbars and tab bars on iPhone, or wants an iOS app audited, fixed, or specced for iPhone Duo. Not for Android foldables (Galaxy Z Fold or Flip), Surface Duo, visionOS, external displays, or general iPad multitasking.
license: MIT
compatibility: Needs bash; ripgrep optional (falls back to grep). Verifying on a simulator needs Xcode 27.1 beta (27.2 beta lacks the Duo SDK). No network.
metadata:
  version: "1.2.2"
  author: tudorturcanu
allowed-tools: Read Grep Glob Bash(bash ${CLAUDE_SKILL_DIR}/scripts/audit_duo_readiness.sh *) Bash(xcrun simctl list devicetypes*)
---

# iPhone Duo design & implementation

iPhone Duo is still an iPhone; all iOS guidance applies. New: two displays, a hinge, many poses,
reserved regions, and bars that move to the side. Make the app **adapt**. Don't build a "Duo mode."

Scope: no installs or network; the audit script is read-only. Change only the app code the user asked about.
`<skill-dir>` is this file's folder (`${CLAUDE_SKILL_DIR}` in Claude Code). For API signatures, rationale, and
doc links, read [the reference](references/apple-hig-designing-for-iphone-duo.md) when a rule isn't enough.

## Mental model

| Surface | Width | Bars |
|---|---|---|
| Outer display (closed) | compact | **side**, on the camera's physical side (not "trailing": it doesn't flip for RTL) |
| Inner, landscape | regular | **side** |
| Inner, portrait | regular | standard horizontal (the one exception) |
| Inner, partially folded | regular | book pose = landscape (side bars); tabletop = portrait (horizontal bars) |
| Inner, Split View | varies | each app on its **outer** edge (left app → left edge) |

Don't design per pose: a compact plus a regular layout, built on size classes, covers all of them. Reserved regions:
outer camera (always; grows into the Dynamic Island), inner camera (while active), fold (while partially folded).
Build with the iOS 27.1 SDK: older builds get no side bars and sit beside the status bar and camera.

## Workflow

1. **Audit.** Run `bash <skill-dir>/scripts/audit_duo_readiness.sh <app-path> -s` for counts, then `-q` for up to
   5 matches per category (`-n 0` for all). Exit 2 means a bad path or nothing to scan, not a clean app. Fix
   launch blockers first: without the UIScene life cycle, an app built with the iOS 27 SDK won't launch (TN3187).
   Read each match in context (a fixed width on an icon is fine, on a container it isn't), then look for what
   grep can't see: controls far from their content, views that jump when the device folds.
2. **Prefer system components** (container-managed bars, split and arrangement views, sheets, menus): they get side
   placement, fold avoidance, and overflow for free. **Apply the rules** below to whatever custom UI remains.
3. **Verify.** If Xcode is installed, build the project (`xcodebuild … build`) or at least typecheck the changed
   files (`xcrun --sdk iphonesimulator swiftc -typecheck`); iOS 27.1 APIs need that SDK. Then walk the checklist
   on the iPhone Duo simulator (`xcrun simctl list devicetypes | grep -i duo`; poses from Device Hub; a black
   screenshot means the other display: `simctl io <device> enumerate`, then `screenshot --display=`). Widgets, Live
   Activities, and most extensions don't run there. No simulator: say so, approximate with iPad Split View.
4. **Report** what changed, what you verified, and what you couldn't.

Scope: fix what breaks on iPhone Duo. Move actions, never drop them, and don't add features, actions, or data
sources nobody asked for. React Native / Flutter bars drawn in JS or Dart never move to the side. **Design specs** (no code): describe what people see in each pose in plain words, keep
it short, and put API names in a brief "Implementation notes" section at the end.

> **APIs** (checked against Apple's docs, 2026-09-26). Every API named in this file exists. Fold, arrangement, hinge,
> and vertical-bar APIs are **iOS 27.1 beta**; `visibilityPriority`, `ToolbarOverflowMenu`, `.topBarPinnedTrailing` are
> 27.0. Guard with `#available` below the deployment target. Signatures are in the reference; anything named in
> neither: don't guess, leave a marked `TODO`.

## Rules

**Layout**
- Size from size classes, layout margins, and safe-area insets. No `UIScreen.main` (deprecated; its bounds keep the outer size after unfolding;
  use the view's bounds, `window?.windowScene?.screen`, `traitCollection.displayScale`), fixed device sizes,
  `userInterfaceIdiom` or orientation branches, or magic status-bar / Dynamic Island padding.
- Insets differ per side: use `bounds.inset(by: safeAreaInsets)`, never `width - insets.left * 2`. Ignore safe
  areas only on specific edges, and only for backgrounds, never scrolling or interactive content.
- `UIRequiresFullScreen` is honored but the app still resizes on open/close, so it saves no work; plan to drop it.
  Don't rely on orientation locks either: locked apps are scaled on the inner display. Fix the layout instead.
- Expand the same layout as space grows. Inner display may add one hierarchy level (list + detail) or show the
  tab bar as a sidebar in information-dense apps (`.tabViewStyle(.sidebarAdaptable)` + `.defaultTabBarPlacement(.sidebar)`).
- Same features and state on both displays and in every pose. Overflow is fine; missing features aren't. Folding
  is a resize, not a life-cycle event (`scenePhase` doesn't change full screen), so keep state in the model.
- Games may lock orientation but must fill every pose: change aspect ratio, don't letterbox (if forced,
  fill bars with artwork). Keep text and control sizes stable.

**The fold**
- Prefer self-adapting containers; standard split views balance panes when folded.
- Custom views: read `reservedRegions(kind: .division)` (fold) and `.occlusion` (cameras) and keep text and tap
  targets out of each region's `frame`, which is in the queried view's coordinates. No change callback is
  documented, so read them where layout happens (`layoutSubviews`, `viewDidLayoutSubviews`, `GeometryReader`,
  `onGeometryChange`). Flat → half-folded may not resize the view, so don't claim layout reruns: test it, and if it
  doesn't, call `setNeedsLayout()` from a `UIHingeInteraction`. Flat, the fold is inactive with zero width. Only active regions return by default; `options: .includeInactive`
  also returns the fold while the device is flat, so you can plan ahead.
- Grids: compute columns from the width and round up to **even** whenever a division exists (active or not); `.adaptive`
  alone can be odd. Scrolling grids needn't avoid the fold (Apple DTS); adjust only non-scrolling sections around it.
- On fold, move the smallest meaningful group, and move related elements together. Don't rearrange.
  Scrolling content (lists, feeds, articles) doesn't need to avoid the fold.
- Tabletop (laptop pose, horizontal fold) layouts are optional: content on top, controls below. Hinge angle is for interactions only.

**Arrangement views**
- Primary + secondary container. *Split*: side by side when wide, stacked when tall, adjusted around the fold
  (limit with `.split.axes(.horizontal)`). *Overlay*: primary atop secondary; only when partially folded do the two
  move to either side of the fold, so it's the one that gives tabletop "content above, controls below". The view
  on top can collapse itself when `\.overlayArrangementZIndex > 0` (UIKit: `state(for:)?.zIndex`).
- `HStack`/`VStack` shapes → split (main/detail); `ZStack` shapes → overlay (foreground/background). When its axes
  can't fit (compact width, some poses) it shows one view: the higher `.layoutPriority`, else the primary.
- Put navigation **around** them (`NavigationStack`, `TabView`). Apple's developer docs warn against a `List`,
  `ScrollView`, or `NavigationSplitView` column around one, where part of it can become unreachable.

**Side controls**
- Only container-managed bars go to the side: `.toolbar` inside `NavigationStack`/`NavigationSplitView`/`TabView`,
  or items on a navigation / tab bar controller. Replace custom `UIToolbar`/`UITabBar`/`UINavigationBar` and homemade bars,
  keeping each action in the bar it came from: bottom-bar actions become toolbar items (`.bottomBar`,
  `toolbarItems`), top-bar actions navigation items. The system merges both into the side bar and keeps them apart.
- Split views put only the detail column's bar on the side; inspectors stay horizontal; sheets on the outer
  display go vertical, and on the inner display only when trailing (`presentationPlacement`, fixed across poses;
  folded, sheets move to the leading edge).
- Keep the system's placement. Turn side bars off (`.toolbarVerticalBehavior(.disabled)`) only for immersive,
  single-purpose screens (Calculator 4×5 → 5×4, full-screen player). It applies per window or presentation, so put
  it on a full-screen cover or sheet, and never toggle it with view state. To just hide bars, use `toolbarVisibility`.
- Order from the top: back/close (`.cancellationAction`) → prominent action (`.topBarPinnedTrailing` /
  `pinnedTrailingGroup`) → remaining items in their original groups.
- Group items (`ToolbarItemGroup`/`UIBarButtonItemGroup`), one item per control; never fixed spacers or an
  `HStack` of buttons in one `ToolbarItem`. Flexible spacers collapse to zero on the side.
- Items overflow bottom-up: set `visibilityPriority` on groups, then items, to keep frequent actions; counts go in `.badge()`.
- Every icon item gets **title + symbol** (`Label("Compose", systemImage: "square.and.pencil")`); the title shows in
  overflow. Keep text-only items rare (HIG); like custom-view items, they stay horizontal: opt a custom view in with `axisBehavior(.verticalPreferred)`; use
  `.horizontalOnly` when the text matters (a cart total, a Select/Done toggle).
- Out of space: navigation-focused view → items overflow, tab bar stays (default). Task-focused view →
  `.toolbarVerticalCompressionBehavior(.prefersToolbarItems)` / `verticalBarCompressionBehavior = .prefersBarItems`.
- Move custom "…" actions into the **system** overflow (`ToolbarOverflowMenu`/`additionalOverflowItems`); ellipsis means overflow only.
- Keep controls with their content (list controls stay above the list) and in consistent positions across poses.
- Custom views that react to the side bar read `\.toolbarVerticalEdge` / `verticalBarEdge`; hero images extend under it (`backgroundExtensionEffect()`).

## Code shape

```swift
// SwiftUI: navigation around the arrangement; grouped, labeled items the system can place and overflow.
NavigationStack {
    ArrangementView { PlayerView() } secondary: { UpNextView() }
        .arrangementViewStyle(.split.axes(.horizontal))       // stacked views would be too short
        .toolbar {
            ToolbarItem(placement: .topBarPinnedTrailing) { Button("Done", action: done) }
            ToolbarItemGroup {
                Button(action: queue) { Label("Queue", systemImage: "text.badge.plus") }
            }
            .visibilityPriority(.high)                          // last to overflow when space runs out
            ToolbarOverflowMenu { Button("Share", systemImage: "square.and.arrow.up", action: share) }
        }
}
```

UIKit versions of this, a fold-aware `layoutSubviews`, and an even-column grid: [reference §7](references/apple-hig-designing-for-iphone-duo.md#7-code-patterns).

## Verification checklist (mark each row verified, fixed, or not verifiable)

- [ ] Built with the iOS 27.1 SDK; no `UIRequiresFullScreen`; audit re-run and remaining hits explained
- [ ] Outer display, portrait & landscape: bars on the side, nothing under the outer camera
- [ ] Inner portrait: horizontal bars, extra hierarchy level if appropriate; inner landscape: bars on the side
- [ ] Partially folded: no text or tap targets in the fold, panes balanced, even grid columns, minimal movement
- [ ] Inner camera active, and a Live Activity on the outer display: nothing important is covered
- [ ] Split View as left and right app, and right-to-left: controls on the outer / hardware edge, content inset
- [ ] Outer ↔ inner transition keeps state (scroll, selection, drafts)
- [ ] Narrowest size: key actions visible, the rest in the system overflow menu
- [ ] Every toolbar item has title + symbol; no custom ellipsis menu; no custom bars
- [ ] Games: screen filled in every pose, no plain black letterbox
