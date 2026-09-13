---
name: iphone-duo-design
description: Adapt, build, and review SwiftUI/UIKit apps for iPhone Duo, Apple's dual-display hinged iPhone. Use for foldable or dual-screen iPhone work, device poses, the fold or hinge, reserved regions, arrangement views, side/vertical toolbars and tab bars, or iPhone Duo readiness audits.
license: MIT
allowed-tools: Read, Grep, Glob
---

# iPhone Duo design & implementation

iPhone Duo is still an iPhone; all iOS guidance applies. New: two displays, a hinge, many poses,
reserved regions, and bars that move to the side. Make the app **adapt**. Don't build a "Duo mode."

Scope: instructions only, no installs or network. `scripts/audit_duo_readiness.sh` is read-only.
Change only the app code the user asked about.

For rationale, examples, and doc links, read `references/apple-hig-designing-for-iphone-duo.md`
only when a rule below isn't enough.

## Mental model

| Surface | Width | Bars |
|---|---|---|
| Outer display (closed) | compact | **side** (trailing, aligned with the always-present outer camera) |
| Inner, landscape | regular | **side** |
| Inner, portrait | regular | standard horizontal (the one exception) |
| Inner, partially folded | regular | by orientation; the **folding region** splits the display |
| Inner, Split View | varies | each app on its **outer** edge (left app → left edge) |

Don't design per pose: a compact layout plus a regular layout, built on size classes, covers all of them.
Reserved regions to avoid: outer camera (always; grows into the Dynamic Island), inner camera (only
while active; UI shifts aside), folding region (only while partially folded).

## Workflow

1. **Audit.** Run `bash scripts/audit_duo_readiness.sh <app-path> -s` for counts (it also checks Info.plist and
   build settings for `UIRequiresFullScreen`, which blocks all resizing: fix that first), then
   `bash scripts/audit_duo_readiness.sh <app-path> -q` for up to 5 matches per category (`-n 0` for all).
   Read each match in context: a fixed width on an icon is fine, on a container it isn't. Also look for
   what grep can't see: custom bars pinned to the top or bottom, controls far from their content.
2. **Prefer system components.** Standard bars, split views, sheets, alerts, and menus get side placement,
   fold avoidance, and overflow for free.
3. **Apply the rules** below to whatever custom UI remains.
4. **Verify** with the checklist. Use an iPhone Duo simulator if installed
   (`xcrun simctl list devicetypes | grep -i duo`); otherwise say so and approximate with iPad Split View /
   Stage Manager and iPhone landscape.
5. **Report** what changed, what you verified, and what you couldn't.

> **API accuracy** (checked against Apple's docs, 2026-09-13). Confirmed: `NavigationSplitView`/`UISplitViewController`,
> `ToolbarItemGroup`/`UIBarButtonItemGroup`, `ToolbarOverflowMenu`/`UINavigationItem.additionalOverflowItems`,
> `Label`/`UIBarButtonItem`, `safeAreaInsets`. Visibility priority: SwiftUI `.visibilityPriority(.high)` on any
> `ToolbarContent` (`.automatic`/`.low`/`.high`); UIKit `UIBarButtonItem.visibilityPriority` (`.high`/`.standard`/`.low`).
> **Unconfirmed:** reserved regions (closest documented API is UIKit `layoutGuide(for: .safeArea(cornerAdaptation:))`,
> not yet documented for the fold or cameras), arrangement-view types, pose/fold-state queries. Never guess these.
> Check the SDK; if you can't, leave a marked `TODO` and tell the user.

## Rules

**Layout**
- Size from size classes, layout margins, and safe-area insets. No `UIScreen.main.bounds`, fixed device
  sizes, `userInterfaceIdiom` layout branches, or magic status-bar / Dynamic Island padding.
- Ignore safe areas only on specific edges, and only for backgrounds, never scrolling or interactive content.
- Expand the same layout as space grows. Inner display may add one hierarchy level (list + detail).
- Same features and state on both displays and in every pose. Overflow is fine; missing features aren't.
- Games may lock orientation but must fill every pose: change aspect ratio, don't letterbox (if forced,
  fill bars with artwork). Keep text and control sizes stable.

**The fold**
- Prefer self-adapting containers; standard split views balance panes when folded.
- Grids: **even** column counts so the fold falls between items.
- Custom elements the system won't move: keep them out of the center with the reserved-region APIs.
- On fold, move only what would be hidden or hard to tap. Don't rearrange.

**Split & arrangement views**
- Split views expand on the inner display and collapse on the outer, like regular ↔ compact.
- Arrangement view = primary + secondary. *Split*: side by side when wide, stacked when tall (axes can be
  limited). *Overlay*: views on either side of the fold when partially folded, else stacked; secondary can collapse.
- `HStack`/`VStack` shapes → split arrangement; `ZStack` shapes → overlay.
- Arrangement views don't navigate: put `NavigationSplitView`/`TabView` **around** them, never inside.

**Side controls**
- Keep the system's bar placement. Don't force bars back to top or bottom.
- Content space is lopsided: inset with safe areas, including the other app's controls in Split View.
- Order from the top: back/close → prominent action (Done) → remaining items in their original groups.
- Group items (`ToolbarItemGroup`/`UIBarButtonItemGroup`); never fixed spacers.
- Items overflow bottom-up. Set `visibilityPriority` on groups, then items, so frequent actions (Compose) and badges stay visible.
- Every non-text item gets **title + symbol** (`Label("Compose", systemImage: "square.and.pencil")`);
  the title appears in overflow. Avoid text-only buttons.
- Out of space: navigation-focused view → items overflow, tab bar stays (default). Task-focused view →
  minimize the tab bar, keep the toolbar.
- Use the **system** overflow menu (`ToolbarOverflowMenu`/`additionalOverflowItems`); move custom "…"
  actions into it. The ellipsis symbol means overflow only.
- Keep controls with their content: list controls stay above the list; only trailing-pane controls go to the side.
- Full-width, bar-free layouts are fine for immersive non-scrolling screens (Calculator 4×5 → 5×4) if they
  avoid the Dynamic Island and status bar. So is a full-width background with inset scrolling content.
- Keep control positions consistent across poses.

## Code shape

```swift
// SwiftUI: controls stay with their pane; groups + labels let the system place and overflow them.
NavigationSplitView {
    MailboxList().toolbar { ToolbarItemGroup { FilterButton(); SortButton() } }
} detail: {
    MessageView().toolbar {
        ToolbarItemGroup(placement: .primaryAction) {
            Button(action: compose) { Label("Compose", systemImage: "square.and.pencil") }
        }
        .visibilityPriority(.high)                      // Compose outlasts Archive when space runs out
        ToolbarItemGroup {
            Button(action: archive) { Label("Archive", systemImage: "archivebox") }
        }
    }
}
```

```swift
// UIKit: title + image, groups instead of spacers, extras in the system overflow.
let compose = UIBarButtonItem(title: "Compose", image: UIImage(systemName: "square.and.pencil"),
                              primaryAction: UIAction { [weak self] _ in self?.compose() }, menu: nil)
compose.visibilityPriority = .high
navigationItem.trailingItemGroups = [UIBarButtonItemGroup(barButtonItems: [compose], representativeItem: nil)]
navigationItem.additionalOverflowItems = UIDeferredMenuElement.uncached { done in
    done([UIAction(title: "Print", image: UIImage(systemName: "printer")) { _ in }])
}
// Root: UISplitViewController(style: .doubleColumn). Lay out from safe area, never UIScreen.main.bounds.
```

## Verification checklist

Mark each row verified, fixed, or not verifiable.

- [ ] Outer display, portrait & landscape: bars on the side, nothing under the outer camera
- [ ] Inner portrait: horizontal bars, extra hierarchy level if appropriate
- [ ] Inner landscape: bars stay on the side
- [ ] Partially folded: no text or tap targets in the fold, panes balanced, even grid columns
- [ ] Inner camera active: UI moves aside
- [ ] Live Activity on outer display: Dynamic Island doesn't cover content
- [ ] Split View as left and right app: controls on the outer edge, content inset from both edges
- [ ] Outer ↔ inner transition keeps state (scroll, selection, drafts)
- [ ] Narrowest size: key actions visible, the rest in the system overflow menu
- [ ] Every toolbar item has title + symbol; no custom ellipsis menu
- [ ] Right-to-left: side controls stay on the hardware side
- [ ] Games: screen filled in every pose, no plain black letterbox
