# Designing for iPhone Duo — condensed reference

This is an original summary of Apple's Human Interface Guidelines article
*Designing for iPhone Duo* (first published September 9, 2026), written for AI coding
agents. It preserves the guidance and the developer-doc links but not Apple's text or
images. Read the source for exact wording and diagrams:

- HIG article: https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo
  (Markdown version: https://developer.apple.com/tutorials/data/design/human-interface-guidelines/designing-for-iphone-duo.md).
  Last checked against the source on 2026-09-13; the article's change log then had one entry (September 9, 2026).
- Related: [Designing for iOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios),
  [Layout](https://developer.apple.com/design/human-interface-guidelines/layout),
  [Split views](https://developer.apple.com/design/human-interface-guidelines/split-views),
  [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars),
  [Designing for games](https://developer.apple.com/design/human-interface-guidelines/designing-for-games),
  [Apple Design Resources](https://developer.apple.com/design/resources/#ios-apps)
- Tech Talks: `videos/play/tech-talks/111462`, `111463`, and `111466`

## 1. What the device is

- Two displays (outer and inner), each with its own front-facing camera, joined by a
  center hinge. People open, close, and half-fold it, and rest it in many poses.
- It is still an iPhone. All "Designing for iOS" guidance applies. Apps built from
  standard system components that already resize well adapt with little extra work.
- **Outer display:** used when closed. Wider and shorter than earlier iPhones. The
  system moves toolbars, tab bars, and navigation controls to the **side** to save
  vertical space. The outer camera sits in a corner, always visible, vertically aligned
  with those side controls.
- **Inner display:** used when open. Side controls stay in landscape (continuity with
  the outer display). Portrait keeps standard horizontal bars. The inner camera is
  hidden behind the display until it is active.
- **Poses** include partially folded like a book, laid flat, and standing on an edge.
  Don't design a layout per pose. Use size classes: a compact-width layout (outer) and
  a regular-width layout (inner) cover every pose. Let the existing layout expand
  instead of reinventing it at each size.

## 2. Best practices (the headline rules)

1. **Build to resize.** Two displays, many poses, and Split View multitasking mean many
   sizes. Lay out with size classes, layout margins, and safe-area insets. No fixed
   widths, no display-specific dependencies.
2. **Consistent experience across displays.** Same functionality and element state on
   both. Keep the information hierarchy; the larger inner display may show one extra
   level (Mail: list *or* message when closed, list *and* message when open).
3. **Same functionality in every pose.** Controls may overflow and content may move or
   resize, but everything stays reachable.
4. **Accept the system's vertical bar layout.** Standard components get it for free.
   Refine it, don't replace it.
5. **Games must be playable in every pose.** Orientation lock is allowed, but fill the
   screen as the pose changes. Keep text and control sizes steady. Prefer changing the
   aspect ratio to letterboxing or pillarboxing; if you must box, fill the padding with
   artwork.

## 3. Dynamic layouts

Use layout margins and safe-area insets everywhere.
Developer docs: SwiftUI `GeometryProxy.safeAreaInsets`, UIKit `UIView.safeAreaInsets`.

### Reserved regions

Areas content must not cover, or that components adapt around (like iPad window
controls). Three of them:

| Region | When present | Behavior |
|---|---|---|
| Outer front camera | Always | Expands into the Dynamic Island for Live Activities. Side controls account for it automatically. |
| Inner front camera | Only while the camera is active | Invisible when inactive; the UI shifts aside when it activates. |
| Folding region | Only while partially open | Splits the inner display into usable areas on either side of the center. |

- Alerts, context menus, and sheets move around the fold on their own. Split views
  rebalance column widths and margins to match the inner display's symmetry.
- Custom components use the **reserved region APIs** to move content away from these
  regions. (The HIG does not name the exact symbols. Verify in the SDK.)

### Adapting when the device folds

- Prefer containers that adapt automatically. Notes' split view widens or narrows each
  pane so both stay readable when folded (panes become equal width).
- Grids: use an **even** number of columns so items don't straddle the fold.
- Avoid extreme changes as the device folds. Move only what must move to stay visible
  and tappable. Small adjustments beat rearrangement, because controls that vanish or
  jump are hard to track.

### Split views

Expand on the inner display, collapse to one pane on the outer display, exactly like
regular ↔ compact on other iPhones. Built with standard components, they adapt to
reserved regions automatically.
Developer docs: SwiftUI `NavigationSplitView`, UIKit `UISplitViewController`.

### Arrangement views

A layout container holding a **primary** and a **secondary** view, organized by display
size, orientation, and reserved regions. Two kinds:

- **Split arrangement.** Divides its area between the two views. Horizontal split when
  wider than tall, vertical split when taller than wide. You can restrict which axes it
  may use.
- **Overlay arrangement.** Stacks primary over secondary. When partially folded, the
  views move to opposite sides of the fold. The secondary view can be collapsed.

Guidance:
- Use one when your layout already looks like one: `HStack` / `VStack` → split
  arrangement; `ZStack` → overlay arrangement.
- Arrangement views don't navigate. Wrap them in `NavigationSplitView` / `TabView`
  (or UIKit equivalents); never nest navigation inside them.
- The HIG does not name the arrangement-view API types. Verify in the SDK.

## 4. Vertical controls

Toolbars, tab bars, and navigation controls move to the side on the outer display and
on the inner display in landscape. Inner-display portrait keeps horizontal bars.

The side column holds, top to bottom: Dynamic Island, status bar, toolbar (including
navigation buttons), tab bar.

In Split View multitasking on the inner display, each app puts its controls on its
**outer** edge (left app → left edge, right app → right edge).

Side controls stay aligned with the hardware: same position relative to the outer
camera, and the same physical side in right-to-left languages.

Rules:

- **Account for asymmetry.** Content space is lopsided. Use safe areas so controls,
  including the other app's controls on the opposite edge in Split View, never cover
  content.
- **Keep controls consistent across poses.** Not every pose has side controls or the
  same space. Keep relative positions as stable as possible.
- **Standard placement order** on the vertical axis: primary navigation (Back, Close)
  at the top, then prominent actions (Done), then the remaining items in their original
  groups. The system inserts space between items that came from the top bar and items
  that came from the bottom bar.
- **Prioritize frequently used items.** Items overflow bottom-to-top by default. Assign
  visibility priority to whole groups first, then to individual items for finer control.
  Keep frequent actions (Compose, New Note) and status-bearing items (badges) visible
  longest.
  Developer docs: SwiftUI `ToolbarItemVisibilityPriority`, UIKit `UIBarButtonItemVisibilityPriority`.
  Set it with SwiftUI `.visibilityPriority(_:)` on any `ToolbarContent`, including a `ToolbarItemGroup`
  (`.automatic`, `.low`, `.high`, or `init(higherThan:)`/`init(lowerThan:)`), or UIKit
  `UIBarButtonItem.visibilityPriority` (`.high`, `.standard`, `.low`, or a raw `Int`).
- **Don't override default bar placement.** Side placement is a core iPhone Duo pattern.
- **Full-width layouts** are fine for immersive, non-scrolling interfaces if nothing
  collides with the Dynamic Island or status bar. Calculator goes from 4 columns × 5
  rows on iPhone 16 to 5 columns × 4 rows on the Duo outer display. A full-width
  background or header with inset scrolling content also works.
- **Group items, don't space them manually.** Groups provide and adapt spacing.
  Developer docs: SwiftUI `ToolbarItemGroup`, UIKit `UIBarButtonItemGroup`.
- **Keep controls near the content they affect.** Controls for the leading pane (Mail's
  list controls) stay above that pane; only trailing-pane controls go to the side.
- **Title and symbol on every non-text item.** The system chooses the representation
  and uses the title in overflow menus and expanded forms.
  Developer docs: SwiftUI `Label`, UIKit `UIBarButtonItem`.
- **Minimize text-only buttons.** Text labels stay in a horizontal bar; prefer symbols.
- **When space is limited, choose what to keep:**
  - Navigation-focused view → toolbar items go to the overflow menu, tab bar stays.
    This is the default compression behavior.
  - Task-oriented view → minimize the tab bar, keep the toolbar (mirrors the minimized
    tab bar on other iPhones).
- **Use the system overflow menu.** Move any custom overflow actions into it. Reserve
  the ellipsis symbol for overflow; give other menus a distinct symbol.
  Developer docs: SwiftUI `ToolbarOverflowMenu`, UIKit `UINavigationItem.additionalOverflowItems`.

## 5. API names

Confirmed by the HIG: `NavigationSplitView`, `UISplitViewController`, `ToolbarItemGroup`,
`UIBarButtonItemGroup`, `ToolbarItemVisibilityPriority`, `UIBarButtonItemVisibilityPriority`,
`ToolbarOverflowMenu`, `UINavigationItem.additionalOverflowItems`, `Label`,
`UIBarButtonItem`, `GeometryProxy.safeAreaInsets`, `UIView.safeAreaInsets`.

Confirmed in the developer docs (checked 2026-09-13):
- SwiftUI `ToolbarContent.visibilityPriority(_:)`, e.g. `ToolbarItem { … }.visibilityPriority(.high)`.
- UIKit `UIBarButtonItem.visibilityPriority`. No group-level property is documented on `UIBarButtonItemGroup`;
  set it on each item.
- SwiftUI `ToolbarOverflowMenu { … }` inside `.toolbar`. UIKit `additionalOverflowItems` is a
  `UIDeferredMenuElement?`; setting it shows the overflow button, and the system adds items that don't fit.

**Not confirmed** (look up in the SDK, never guess):
- Reserved-region APIs. The HIG compares them to iPad window controls. The documented API for those is UIKit
  `UIView.LayoutRegion` (`layoutGuide(for:)`, `edgeInsets(for:)`, `.safeArea(cornerAdaptation:)`,
  `.margins(cornerAdaptation:)`), but its docs don't yet mention the fold or cameras.
- Arrangement-view types and any pose or fold-state query API. No public docs found.
