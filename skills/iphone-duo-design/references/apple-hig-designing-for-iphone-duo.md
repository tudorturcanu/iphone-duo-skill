# Designing for iPhone Duo — condensed reference

This is an original summary of Apple's Human Interface Guidelines article
*Designing for iPhone Duo* (first published September 9, 2026), the developer article
*Preparing your app for iPhone Duo*, and Apple's iPhone Duo tech talks, written for AI
coding agents. It preserves the guidance and the developer-doc links but not Apple's
text or images. Read the sources for exact wording and diagrams:

- HIG article: https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo
  (Markdown version: https://developer.apple.com/tutorials/data/design/human-interface-guidelines/designing-for-iphone-duo.md).
  Last checked against the source on 2026-09-26. Its content changed after 2026-09-13 (tracked by hash in
  `tests/hig-duo.sha256`) while its change log still lists only September 9; it now names the reserved-region,
  arrangement-view, and compression APIs.
- Developer article: https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo
- Related: [Designing for iOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios),
  [Layout](https://developer.apple.com/design/human-interface-guidelines/layout),
  [Split views](https://developer.apple.com/design/human-interface-guidelines/split-views),
  [Toolbars](https://developer.apple.com/design/human-interface-guidelines/toolbars),
  [Designing for games](https://developer.apple.com/design/human-interface-guidelines/designing-for-games),
  [Apple Design Resources](https://developer.apple.com/design/resources/#ios-apps)
- Tech Talks (`developer.apple.com/videos/play/tech-talks/<id>`): 111461 *Prepare your app*, 111462 *Raise the bar*,
  111463 *Strike a pose* (adaptive layouts), 111464 *Multiple displays and scenes*, 111465 *Camera*, 111466 *Design for iPhone Duo*.
- Testing: [Device Hub](https://developer.apple.com/documentation/xcode/device-hub) in Xcode previews poses.
  The iPhone Duo SDK and simulator ship in Xcode 27.1 beta.

## Contents

1. [What the device is](#1-what-the-device-is)
2. [Best practices](#2-best-practices-the-headline-rules)
3. [Dynamic layouts](#3-dynamic-layouts): reserved regions, folding, split and arrangement views
4. [Vertical controls](#4-vertical-controls)
5. [Beyond the HIG](#5-beyond-the-hig-developer-article-and-tech-talks): SDK, screens, bars, displacement, scenes, testing
6. [API reference](#6-api-reference): exact names and signatures
7. [Code patterns](#7-code-patterns): UIKit bars, fold-aware layout, even-column grids

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

- Alerts, context menus, and sheets move around the fold on their own (Apple DTS: folded, sheets move to the
  leading edge; flat, they're centered). Split views rebalance column widths and margins to match the inner
  display's symmetry. No traits or safe-area insets come from the fold by default.
- Custom components use the reserved-region APIs to keep important elements clear:
  SwiftUI `ReservedRegion` (from `GeometryProxy.reservedRegions(kind:options:layoutDirectionBehavior:)`),
  UIKit `UIView.ReservedRegion` (from `UIView.reservedRegions(kind:options:)`). Kinds: `.division` (the fold)
  and `.occlusion` (a camera, including the Dynamic Island). See §6.

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
- **Overlay arrangement.** Places the primary view atop the secondary. When partially
  folded, the views move to opposite sides of the fold (primary to the trailing or bottom
  side, secondary to the leading or top side). The secondary view can be collapsed.

Guidance:
- Use one when your layout already looks like one: `HStack` / `VStack` → split
  arrangement; `ZStack` → overlay arrangement.
- Split fits main/detail; overlay fits foreground/background (a player over its queue).
- Arrangement views don't navigate. Put a `NavigationStack` / `TabView` (or a
  `UINavigationController`) around them. The developer article says not to place one inside a
  `NavigationSplitView`, `List`, or `ScrollView`, where part of it could become unreachable. (The HIG names
  navigation split views among the containers to put around one; if you do, keep the arrangement fully reachable.)
- Developer docs: SwiftUI `ArrangementView`, UIKit `UIArrangementViewController`. See §6.

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
  `UIBarButtonItem.visibilityPriority` (`.high`, `.standard`, `.low`, `init(higherThan:)`/`init(lowerThan:)`,
  or `init(rawValue:)`).
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
    tab bar on other iPhones). Developer docs: SwiftUI `ToolbarVerticalCompressionBehavior`
    (`.toolbarVerticalCompressionBehavior(.prefersToolbarItems)`), UIKit `UIVerticalBarCompressionBehavior`
    (`navigationItem.verticalBarCompressionBehavior = .prefersBarItems`).
- **Use the system overflow menu.** Move any custom overflow actions into it. Reserve
  the ellipsis symbol for overflow; give other menus a distinct symbol.
  Developer docs: SwiftUI `ToolbarOverflowMenu`, UIKit `UINavigationItem.additionalOverflowItems`.

## 5. Beyond the HIG: developer article and tech talks

**Build and screens**
- Build with the latest Xcode (iOS 27.1 SDK). Older builds don't extend under the status bar and camera, and
  don't get side bars.
- `UIScreen.main` is deprecated since iOS 26.0 and ambiguous on a two-display device (talk 111461 still says
  "will be deprecated"; the API docs list it as deprecated). Use the view or scene bounds,
  `window?.windowScene?.screen`, and `traitCollection.displayScale`.
- `UIRequiresFullScreen` is still honored, but the app resizes anyway when the device opens or closes.
- Orientation locks: talk 111461 says both that the inner display doesn't honor supported orientations and that
  locked apps are scaled there. Either way, don't rely on the lock. Don't branch
  layout on `userInterfaceIdiom` or interface orientation. Use size classes with automatic trait tracking.
- Safe-area insets differ per side. Use `bounds.inset(by: safeAreaInsets)`, not `width - insets.left * 2`.
- Corners: `ConcentricRectangle` (SwiftUI) and `UICornerConfiguration` (UIKit) follow the new screen shapes.

**Bars**
- Only bars owned by a container go vertical: SwiftUI `.toolbar` on content inside `NavigationStack`,
  `NavigationSplitView`, or `TabView`; UIKit items on a view controller inside a `UINavigationController` /
  `UITabBarController`. Content of a custom `UIToolbar`, `UINavigationBar`, or `UITabBar` is ignored.
- Split views: only the detail column's bars go vertical; sidebar and content columns stay horizontal.
  Inspectors stay horizontal. Sheets on the outer display go vertical by default. On the inner display, only
  trailing sheets do (`presentationPlacement(_:)` / `UISheetPresentationController.preferredPlacement`).
- Top of the side bar: custom Back/Close as `ToolbarItem(placement: .cancellationAction)` or UIKit
  `leadingItemGroups` with `leftItemsSupplementBackButton = false`; prominent actions (Done) as
  `.topBarPinnedTrailing` or `UINavigationItem.pinnedTrailingGroup`.
- The side bar uses the icon; horizontal bars prefer the icon; overflow uses icon and title. Title-only
  items and custom views stay horizontal unless opted in with `axisBehavior(.verticalPreferred)`. Use
  `.horizontalOnly` for items whose text carries meaning (a cart total, a Select/Done toggle).
- Flexible spacers are zero-size vertically; fixed spacers keep their size. Don't add spacing.
- Show counts with `.badge(_:)` / `UIBarButtonItem.badge = .count(n)`.
- Under Reduce Transparency the side bar gets a background; keep custom content legible.
- Disable side bars (`.toolbarVerticalBehavior(.disabled)` / override `preferredVerticalBarBehavior` to return
  `.disabled`) only for immersive single-purpose UIs such as a calculator, a full-screen player, or a sheet with a
  single button. Treat it as a fixed choice, not something that toggles with view state.
- Custom views that must adapt to the side bar read `@Environment(\.toolbarVerticalEdge)` (`HorizontalEdge?`) or
  `traitCollection.verticalBarEdge` (`.leading`, `.trailing`, `.unspecified`).
- Hero or background images extend under the side bar with `backgroundExtensionEffect()` / `UIBackgroundExtensionView`.
- Information-dense apps can show the tab bar as a sidebar on the inner display:
  `TabView { … }.tabViewStyle(.sidebarAdaptable).defaultTabBarPlacement(.sidebar)` (27.0; takes an
  `AdaptableTabBarPlacement`) / `tabBarController.sidebar.preferredPlacement = .sidebar`.

**Displacement and poses**
- When the fold would cover something, move the smallest meaningful scope and move related elements together.
- Continuous scrolling content (feeds, articles, lists) doesn't need to avoid the fold.
- Grids: query inactive divisions (`options: .includeInactive`) to prefer an even column count whenever a fold
  exists (talk 111463). Apple DTS doesn't recommend making scrolling grids avoid the fold; there's no automatic fold
  avoidance in `UICollectionView`. Adjust only sections that don't scroll across the fold, from the collection
  view's reserved regions.
- Poses: the inner display is wider than tall when opened like a book, so **book pose (vertical fold) is landscape**
  with side bars, and **tabletop / laptop pose (horizontal fold) is portrait** with horizontal bars.
- Book pose: displaced alerts go to the trailing side. Tabletop pose: the top half suits content viewed from a
  distance, the bottom half suits controls. A tabletop layout is optional and keeps the same controls.
- Audit centered layouts: they're what the fold cuts through.
- Hinge state (`onHingeChange` / `UIHingeInteraction`) is for interactions, such as using the hinge angle as an input.
  Don't drive layout from it.

**Scenes and state**
- Built with the SDK after iOS 26, an app that hasn't adopted the UIScene life cycle won't launch (TN3187). SwiftUI
  `App`s already use scenes; UIKit apps need a `UIApplicationSceneManifest` or `configurationForConnecting`.
- Opening or closing doesn't change `scenePhase` for a full-screen app: the scene just resizes through size-class
  and trait changes. With two windows on the inner display, closing keeps the most recent one active and moves the
  other to inactive, then background (Apple DTS). Keep UI state in the model so it survives resizes.
- `ArrangementView` shows only one view when its split axes can't fit the aspect ratio, pose, or compact size
  class: the one with the higher `.layoutPriority`, else the primary (Apple DTS). Observe `\.splitArrangementAxis`
  and keep the hidden view's actions reachable elsewhere.
- `toolbarVerticalBehavior` is resolved per window or presentation (a `NavigationStack` uses its top view, a
  `TabView` its selected tab), so disabling it for one immersive screen belongs on a full-screen cover or sheet.

**Testing**
- iPhone Duo SDK and simulator: Xcode 27.1 beta only (the 27.2 beta notes say to use 27.1). Poses come from Device
  Hub; Xcode Previews have a "Display" override for the outer display.
- Simulator known issues (Xcode 27.1 notes): StandBy unavailable, most app extensions (widgets, Live Activities)
  can't run or be debugged. Verify those on a device.
- Screenshots: `xcrun simctl io <device> enumerate` lists displays; pass `screenshot --display=<id>` to capture the
  one in use.

**Camera and other topics** (outside this skill's layout focus): see *Choosing a camera by the direction it
faces* (AVKit) and *Registering a camera capture accessory on iPhone Duo* (AVFoundation), and tech talks 111464–111465.
Don't hard-code "Face ID" in UI text; read `LAContext().biometryType`.

## 6. API reference

Checked against Apple's developer docs on 2026-09-26. **iOS 27.1, beta** unless noted. Guard with
`if #available(iOS 27.1, *)` when the deployment target is lower.

**Reserved regions**
- SwiftUI: `GeometryProxy.reservedRegions(kind: ReservedRegion.Kind, options: ReservedRegion.QueryOptions = [],
  layoutDirectionBehavior: LayoutDirectionBehavior = .mirrors) -> [ReservedRegion]`, called inside a `GeometryReader`.
- UIKit: `UIView.reservedRegions(kind: UIView.ReservedRegion.Kind, options: UIView.ReservedRegion.QueryOptions = [])
  -> [UIView.ReservedRegion]`.
- Region properties: `frame` (includes margins), `margins`, `isActive`, `kind`, `id`. Kinds: `.division`,
  `.occlusion`. Options: `.includeInactive` (active regions only by default, per `QueryOptions` and talk 111463;
  the `ReservedRegion` overview's "regardless of whether they are currently active" contradicts both). The fold is
  active only while partially folded; when flat it's inactive with zero width.

**Arrangement views**
- SwiftUI: `ArrangementView<Primary, Secondary>`, written `ArrangementView { Primary() } secondary: { Secondary() }`.
  Style with `.arrangementViewStyle(_:)`: `.automatic` (resolves to split), `.split`, `.overlay`; limit axes with
  `.split.axes(.horizontal)` / `.overlay.axes(_:)`. Custom styles conform to `ArrangementViewStyle`.
- Split sizing: `.splitArrangementLayoutRatio(_:)`, `.splitArrangementLayoutSize(minWidth:…)`,
  `.splitArrangementFixedLayoutSize(horizontal:vertical:)`. Overlay: `.overlayArrangementEdge(_:)` picks the
  horizontal edge a view takes when side by side.
- Environment: `\.overlayArrangementZIndex` (`Int`; greater than 0 means this view is drawn on top, so it can
  collapse itself, as talk 111463 does with an Up Next queue placed in the primary slot), `\.splitArrangementAxis`.
- UIKit: `UIArrangementViewController()`; `setViewController(_:for: .primary / .secondary, animated:)`;
  `updateArrangement(_:animated:)` with `UISplitArrangement` (default) or `UIOverlayArrangement`, e.g.
  `.split.axes(.horizontal)`; `state(for:)` returns a `ViewState?` with `isHidden`, `splitAxis`, `zIndex`.

**Hinge**
- SwiftUI: `.onHingeChange(isEnabled:_:)` with `(DeviceHingeContext, DeviceHingeContext)`; `context.hinge` is a
  `DeviceHinge?` (nil without a hinge) with `angle` and `status` (`.closed`, `.partiallyOpen`, `.fullyOpen`).
- UIKit: `UIHingeInteraction(updateHandler:)` added with `addInteraction(_:)`; `update.hinge` is a `UIHinge?` with
  `angle` (radians) and `status` (adds `.unknown`).

**Bars**
| Purpose | SwiftUI | UIKit |
|---|---|---|
| Overflow order | `ToolbarContent.visibilityPriority(_:)` (27.0) | `UIBarButtonItem.visibilityPriority` (27.0) |
| Explicit overflow items | `ToolbarOverflowMenu { … }` (27.0) | `UINavigationItem.additionalOverflowItems` (16.0) |
| Vertical eligibility | `ToolbarContent.axisBehavior(_:)`: `.automatic`, `.horizontalOnly`, `.verticalPreferred` | `UIBarButtonItem.axisBehavior` (same cases) |
| Tab bar vs items | `.toolbarVerticalCompressionBehavior(_:)`: `.automatic`, `.prefersTabBar`, `.prefersToolbarItems` | `UINavigationItem.verticalBarCompressionBehavior`: `.automatic`, `.prefersTabBar`, `.prefersBarItems` |
| Opt out of side bars | `.toolbarVerticalBehavior(_:)`: `.automatic`, `.disabled` | `UIViewController.preferredVerticalBarBehavior` (override) |
| Which edge | `EnvironmentValues.toolbarVerticalEdge` | `UITraitCollection.verticalBarEdge` |
| Pinned prominent action | `ToolbarItemPlacement.topBarPinnedTrailing` (27.0) | `UINavigationItem.pinnedTrailingGroup` (16.0) |
| Sheet placement | `.presentationPlacement(_:)` (27.0) | `UISheetPresentationController.preferredPlacement` (27.0) |

No group-level visibility priority is documented on `UIBarButtonItemGroup`; set it on each item.
`additionalOverflowItems` is a `UIDeferredMenuElement?`; setting it shows the overflow button.

Also confirmed by the HIG: `NavigationSplitView`, `UISplitViewController`, `ToolbarItemGroup`,
`UIBarButtonItemGroup`, `Label`, `UIBarButtonItem`, `GeometryProxy.safeAreaInsets`, `UIView.safeAreaInsets`.
Anything else Duo-specific: look it up in the SDK and never guess.

## 7. Code patterns

Uncompiled sketches built only from the APIs in §6. Adapt names to the project.

**UIKit bars.** Title + image, groups instead of spacers, extras in the system overflow. Bottom-bar actions stay
toolbar items (`toolbarItems`); top-bar actions stay navigation items.

```swift
// UIKit: title + image, groups instead of spacers, extras in the system overflow.
let compose = UIBarButtonItem(title: "Compose", image: UIImage(systemName: "square.and.pencil"),
                              primaryAction: UIAction { [weak self] _ in self?.compose() }, menu: nil)
compose.visibilityPriority = .high
navigationItem.trailingItemGroups = [UIBarButtonItemGroup(barButtonItems: [compose], representativeItem: nil)]
navigationItem.additionalOverflowItems = UIDeferredMenuElement.uncached { done in
    done([UIAction(title: "Print", image: UIImage(systemName: "printer")) { _ in }])
}
let arrangement = UIArrangementViewController()   // root of a UINavigationController; .secondary works the same
arrangement.setViewController(PlayerViewController(), for: .primary)
```

**Fold-aware custom layout (UIKit).** Regions are in this view's coordinates. Re-read them on every layout pass;
no change callback is documented.

```swift
override func layoutSubviews() {
    super.layoutSubviews()
    let safe = bounds.inset(by: safeAreaInsets)
    var target = safe                                          // where the palette group may sit
    if #available(iOS 27.1, *) {
        // Active fold only: nothing moves while the device is flat.
        // Filter isActive too: one doc overview says inactive regions can be returned by default.
        if let fold = reservedRegions(kind: .division).first(where: \.isActive)?.frame {
            if fold.height >= fold.width {                     // vertical fold (book pose): use the trailing half
                target = CGRect(x: fold.maxX, y: safe.minY, width: safe.maxX - fold.maxX, height: safe.height)
            } else {                                           // horizontal fold (tabletop): controls go below
                target = CGRect(x: safe.minX, y: fold.maxY, width: safe.width, height: safe.maxY - fold.maxY)
            }
        }
    }
    palette.center = CGPoint(x: target.midX, y: target.midY)  // move the whole group together
    // Also keep `palette.frame` clear of reservedRegions(kind: .occlusion) (cameras) the same way.
}
```

**Even-column grid (UIKit compositional layout).**

```swift
func columnCount(for width: CGFloat, minItemWidth: CGFloat = 100, spacing: CGFloat = 2) -> Int {
    var count = max(1, Int((width + spacing) / (minItemWidth + spacing)))
    if #available(iOS 27.1, *),
       !collectionView.reservedRegions(kind: .division, options: .includeInactive).isEmpty,
       count > 1, count % 2 == 1 {
        count += 1                                            // the fold falls between two columns
    }
    return count
}
// Width: collectionView.bounds.inset(by: collectionView.safeAreaInsets).width, per side, never left * 2.
// Rebuild the layout when the width or size class changes (viewDidLayoutSubviews / registerForTraitChanges).
// The grid scrolls, so it doesn't need to avoid the fold: even columns are enough (Apple DTS).
```

**SwiftUI.** Read regions inside a `GeometryReader` (`proxy.reservedRegions(kind: .division)`) or pass them to a
custom `Layout`; they're mirrored for right-to-left by default (`layoutDirectionBehavior: .fixed` to opt out).
