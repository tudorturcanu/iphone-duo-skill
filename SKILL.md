---
name: iphone-duo-design
description: Design, build, and review iOS apps so they adapt correctly to iPhone Duo (Apple's dual-display, hinged iPhone announced September 2026). Use whenever the user mentions iPhone Duo, foldable/dual-screen iPhone, device poses, the fold or hinge, reserved regions, arrangement views, side/vertical toolbars and tab bars, or auditing an iOS app for iPhone Duo adaptation. Covers SwiftUI and UIKit.
---

# iPhone Duo design & implementation

iPhone Duo is still an iPhone. Everything in "Designing for iOS" applies. What's new:
two displays, a hinge, many device poses, reserved regions, and bars that move to the side.
Your job as the agent is to make an app **adapt** to all of that. You should not build a
separate "Duo mode."

A condensed reference of Apple's HIG article is in `references/apple-hig-designing-for-iphone-duo.md`.
Read it when you need the full rule set, the list of confirmed API names, or links to the
developer docs. The original article is at
https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo

## Mental model

| Surface | Width class | Bars | Notes |
|---|---|---|---|
| Outer display (closed) | compact | **on the side** (trailing edge, aligned with camera) | Wider and shorter than other iPhones; the outer camera is always a reserved region |
| Inner display, landscape | regular | **on the side** | Kept on the side for continuity with the outer display |
| Inner display, portrait | regular | standard horizontal bars | The one exception |
| Inner display, partially folded | regular | depends on orientation | **Folding region** splits the display; keep content out of the center |
| Inner display, Split View multitasking | varies | each app puts bars on its **outer** edge | Left app → left edge. Account for controls on both edges |

Poses include book-style half-folded, flat on a table, and standing on an edge. **Don't design
per pose.** A compact layout (outer) plus a regular layout (inner), both built on size classes,
covers every pose.

Reserved regions are areas content must avoid:
1. **Outer camera.** Always present. Grows into the Dynamic Island for Live Activities.
2. **Inner camera.** Only there while the camera is active. The UI shifts aside when it is.
3. **Folding region.** Only there while partially folded. It splits the inner display.

## Workflow

When asked to make, check, or fix an app for iPhone Duo:

1. **Audit for resize-hostility first.** Run the helper script `scripts/audit_duo_readiness.sh <path>` or search the code for:
   - fixed frame widths or heights on containers (`.frame(width:`, `CGRect(x:0, y:0, width: 390`, hard-coded screen sizes)
   - `UIScreen.main.bounds` and device-model or `userInterfaceIdiom` checks that pick layouts
   - ignored safe areas (`.ignoresSafeArea()` on scrollable or interactive content, `edgesIgnoringSafeArea`)
   - custom tab bars or toolbars drawn as views pinned to top or bottom instead of system `toolbar` / `TabView` / `UIToolbar` / `UITabBarController`
   - a homemade "…" overflow menu
   - hard-coded manual spacers between toolbar items
   - image-only `UIBarButtonItem`s (no title for the overflow menu) and `NavigationView` (no split behavior)
   - hard-coded status-bar / Dynamic Island padding instead of safe-area insets
   - orientation locks with no fill strategy (games)
2. **Move to system components where possible.** Standard bars, split views, sheets, alerts, and
   menus get side placement, fold avoidance, and overflow behavior for free.
3. **Apply the rules below** to anything custom that stays.
4. **Check every configuration** in the checklist at the end. Test on an iPhone Duo simulator
   if one is installed (`xcrun simctl list devicetypes | grep -i duo`). If not, say so, and
   approximate by resizing: iPad Split View / Stage Manager, and iPhone landscape.
5. **Report** what changed, what you verified, and what you couldn't verify.

> **API accuracy:** iPhone Duo APIs are new. The HIG names these symbols:
> `NavigationSplitView` / `UISplitViewController`, `ToolbarItemGroup` / `UIBarButtonItemGroup`,
> `ToolbarItemVisibilityPriority` / `UIBarButtonItemVisibilityPriority`,
> `ToolbarOverflowMenu` / `UINavigationItem.additionalOverflowItems`, `Label` / `UIBarButtonItem`,
> and `safeAreaInsets`. It does **not** give exact names for the reserved-region APIs or
> arrangement-view types. **Never guess those names.** Look them up in the SDK headers or
> the developer documentation. If you can't, leave a clearly marked TODO and tell the user.

## Rules

### Layout & resizing
- Build layouts from size classes, layout margins, and safe-area insets. Never tie a layout to a specific display.
- When the app gets bigger, let the same layout **expand**. Don't reinvent the app per size.
- Keep the same features and state on both displays. On the inner display you *may* show one extra level of hierarchy (e.g., list + detail side by side, where the outer display shows only one).
- Every pose must reach the same controls and content. Overflow is fine; missing features are not.
- Games: you may lock orientation, but fill the screen in every pose. Change the aspect ratio rather than letterboxing. If you must letterbox, fill the bars with artwork. Keep text and control sizes stable.

### The fold
- Prefer containers that adapt on their own. Standard split views even out their panes when folded.
- Grids: use an **even** number of columns so the fold falls between items.
- Custom elements the system doesn't move: use the reserved-region APIs to keep them out of the center.
- On fold, make **small adjustments**. Move only what the fold would hide or make hard to tap. Don't rearrange.

### Split views & arrangement views
- A split view expands on the inner display and collapses to one pane on the outer display. It works like the usual regular ↔ compact behavior.
- **Arrangement view** = a container with a primary and a secondary view.
  - *Split*: side by side when wider than tall, stacked when taller than wide. You can limit which axes it uses.
  - *Overlay*: when partially folded, the two views sit on either side of the fold. Otherwise primary sits on top of secondary. The secondary can collapse.
- HStack/VStack-shaped layouts map to a split arrangement. ZStack-shaped layouts map to an overlay arrangement.
- Arrangement views don't navigate. Put `NavigationSplitView` / `TabView` **around** them, never inside.

### Vertical (side) controls
- Keep the system's default bar placement. Don't force bars back to the top or bottom.
- Content space is lopsided. Inset with safe areas, including against a second app's controls on the opposite edge in Split View.
- Order from the top of the side bar: back/close navigation → prominent action (Done) → remaining items in their original groups.
- Group toolbar items with `ToolbarItemGroup` / `UIBarButtonItemGroup`. Don't add fixed spacers.
- Items overflow **bottom-up** by default. Give priorities so frequent actions (Compose, New Note) and status items (badges) stay visible longest. Set priority on groups first, then individual items.
- Give every non-text item **both a title and a symbol** (`Label("Compose", systemImage: "square.and.pencil")`). The title shows up in overflow menus.
- Avoid text-only buttons. Text labels stay in a horizontal bar.
- When space runs out:
  - **Navigation-focused view** → toolbar items go into overflow and the tab bar stays (default).
  - **Task-focused view** → minimize the tab bar and keep the toolbar.
- Use the **system** overflow menu (`ToolbarOverflowMenu` / `additionalOverflowItems`). Move custom "…" actions into it. Use the ellipsis symbol only for overflow.
- Keep controls with the content they act on. List controls stay on top of the list pane. Only controls for the trailing content go to the side.
- Full-width, bar-free layouts are fine for immersive, non-scrolling screens (e.g., Calculator switching from 4×5 to 5×4). They must not collide with the Dynamic Island or status bar. A full-width background with inset scrolling content is also fine.
- Keep the relative position of controls consistent across poses so people don't have to relearn them.

## Minimal SwiftUI shape

```swift
NavigationSplitView {
    MailboxList()
        .toolbar {                       // controls for the list stay with the list
            ToolbarItemGroup { FilterButton(); SortButton() }
        }
} detail: {
    MessageView()
        .toolbar {                       // system places these on the side on iPhone Duo
            ToolbarItemGroup(placement: .primaryAction) {
                Button { compose() } label: { Label("Compose", systemImage: "square.and.pencil") }
            }
            ToolbarItemGroup {
                Button { archive() } label: { Label("Archive", systemImage: "archivebox") }
                Button { move() }    label: { Label("Move", systemImage: "folder") }
            }
            // Set visibility priority (ToolbarItemVisibilityPriority) so Compose outlasts Archive/Move.
            // Verify the exact modifier name against the current SDK before using it.
        }
}
```

## Minimal UIKit shape

```swift
final class MessageViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Title + image on every item: the image shows in the side bar, the title in overflow.
        let compose = UIBarButtonItem(title: "Compose", image: UIImage(systemName: "square.and.pencil"),
                                      primaryAction: UIAction { [weak self] _ in self?.compose() }, menu: nil)
        let archive = UIBarButtonItem(title: "Archive", image: UIImage(systemName: "archivebox"),
                                      primaryAction: UIAction { [weak self] _ in self?.archive() }, menu: nil)
        let move    = UIBarButtonItem(title: "Move", image: UIImage(systemName: "folder"),
                                      primaryAction: UIAction { [weak self] _ in self?.move() }, menu: nil)

        // Groups instead of fixed spacers; the system spaces and overflows them per pose.
        navigationItem.trailingItemGroups = [
            UIBarButtonItemGroup(barButtonItems: [compose], representativeItem: nil),
            UIBarButtonItemGroup(barButtonItems: [archive, move], representativeItem: nil),
        ]
        // Set UIBarButtonItemVisibilityPriority so Compose outlasts Archive/Move —
        // new with iPhone Duo; verify the property name in the current SDK.

        // Extra actions go into the *system* overflow menu, not a custom "…" button.
        navigationItem.additionalOverflowItems = UIDeferredMenuElement.uncached { completion in
            completion([UIAction(title: "Print", image: UIImage(systemName: "printer")) { _ in /* … */ }])
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Lay out custom content from safe area / layout margins, never UIScreen.main.bounds.
    }
}

// Root: UISplitViewController(style: .doubleColumn) — expands on the inner display,
// collapses to one column on the outer display, and balances columns at the fold.
```

Anti-patterns to flag in review:

```swift
.frame(width: UIScreen.main.bounds.width)          // display-specific width
HStack { ... }.frame(height: 83).ignoresSafeArea() // homemade bottom tab bar
Menu { ... } label: { Image(systemName: "ellipsis") } // custom overflow competing with the system one
LazyVGrid(columns: Array(repeating: .init(), count: 3)) // odd column count splits items at the fold
view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)  // UIKit: hard-coded device size
UIBarButtonItem(barButtonSystemItem: .fixedSpace, ...)     // UIKit: manual spacing instead of groups
if UIDevice.current.userInterfaceIdiom == .phone { compactLayout() } // idiom ≠ available size
```

## Verification checklist

Go through every row. Mark each as verified, fixed, or not verifiable.

- [ ] Outer display, portrait & landscape: bars on the side, nothing under the outer camera, content not covered
- [ ] Inner display, portrait: standard horizontal bars, extra hierarchy level if appropriate
- [ ] Inner display, landscape: bars stay on the side
- [ ] Partially folded: no text or tap targets in the folding region, split panes balanced, even grid columns
- [ ] Inner camera active: UI moves aside correctly
- [ ] Live Activity on the outer display: Dynamic Island expansion doesn't cover content
- [ ] Split View multitasking as both left and right app: controls on the outer edge, content inset from both edges
- [ ] Outer ↔ inner transition keeps state (scroll position, selection, drafts)
- [ ] Narrowest size: important actions still visible, the rest reachable via the system overflow menu
- [ ] Every toolbar item has a title + symbol; no custom ellipsis menu
- [ ] Right-to-left language: side controls stay on the hardware side
- [ ] Games: screen filled in every pose, no plain black letterbox
