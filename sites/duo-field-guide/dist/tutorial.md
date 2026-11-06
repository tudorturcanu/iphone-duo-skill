# Your first iPhone Duo audit

Use this walkthrough to run the scanner, fix two common SwiftUI patterns, and decide what still needs device testing. You will work on a temporary copy of the bundled Notes example. The original fixtures stay unchanged.

Prefer a quick reference? Jump to [everyday tips](#everyday-tips) or [troubleshooting](#troubleshooting).

## Before you start

- Open a terminal in this repository's root—the folder containing `README.md`, `skills/`, and `tests/`.
- The audit needs Bash. Ripgrep is optional; it falls back to grep. JSON `.xcproj` files also need Python 3, with no extra packages.
- You can run the audit without Xcode. Building the examples and checking Duo behavior requires a suitable Xcode SDK and simulator or device.
- This lab's code assumes an **iOS 27.1 deployment target**. In an existing app, preserve its deployment target and add availability guards or fallbacks for newer APIs. Building with a newer SDK does not require raising your app's minimum OS version.

The fixtures are Swift source examples, **not complete runnable Xcode projects**. Installing just the skill does not install `tests/`; use this repository copy for the walkthrough. See the [README](https://github.com/tudorturcanu/iphone-duo-skill#-quick-install) for normal skill installation.

Checked October 26, 2026: the commands produced the intermediate results below, and the edited Swift files typechecked with Swift 6 and the iOS 27.1 simulator SDK in Xcode 27.1. This verifies the source examples, not their appearance on a simulator or device.

## 1. Make a practice copy and run the audit

Run this in one terminal session; later commands reuse these variables:

```bash
DUO_AUDIT="$PWD/skills/iphone-duo-design/scripts/audit_duo_readiness.sh"
DUO_LAB="$(mktemp -d "${TMPDIR:-/tmp}/duo-tutorial.XXXXXX")"
cp -R tests/fixtures/NotesApp "$DUO_LAB/NotesApp"
printf 'Practice folder: %s\n' "$DUO_LAB/NotesApp"

if bash "$DUO_AUDIT" "$DUO_LAB/NotesApp" -s; then
    DUO_STATUS=0
else
    DUO_STATUS=$?
fi
printf 'Audit exit code: %s\n' "$DUO_STATUS"
```

The current fixture reports:

```text
11 line(s) flagged in 9 categories. Review each in context.
Audit exit code: 1
```

That is the expected result. The audit found candidates to review; it did not crash.

| Exit code | Meaning | Next action |
|---|---|---|
| `0` | No blocking patterns found; advisory items may still appear | Build and test the UI. A clean scan is not a readiness certificate. |
| `1` | One or more potential anti-patterns | Read the reported lines and their surrounding code. |
| `2` | Incomplete audit: bad input, missing dependency, unsupported JSON, or a search error | Resolve the error before trusting the result. |

Now show the source locations:

```bash
bash "$DUO_AUDIT" "$DUO_LAB/NotesApp" -q
```

This also exits `1`. `-q` hides clean categories and shows up to five matches per category. Use `-q -n 0` when you need every match. One line can trigger several categories, so category counts are not a count of independent bugs.

## 2. Replace the homemade tab bar

Open `NotesRootView.swift` **inside the practice folder printed above**. The original uses screen-wide sizing, a hard-coded top inset, and an `HStack` of buttons for navigation. These bypass the container that can place the tab bar for the current display.

Replace that file with:

```swift
import SwiftUI

struct NotesRootView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Notes", systemImage: "note.text", value: 0) {
                NotesListView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: 1) {
                Text("Search View")
            }
            Tab("Settings", systemImage: "gearshape", value: 2) {
                Text("Settings View")
            }
        }
    }
}
```

All three destinations and the selected-tab state remain. The system now owns tab placement and safe-area handling; the fixed screen width and manual insets are gone. `Tab` requires iOS 18 or later. See Apple's [Tab documentation](https://developer.apple.com/documentation/swiftui/tab).

Rerun the audit:

```bash
bash "$DUO_AUDIT" "$DUO_LAB/NotesApp" -q
```

Expected: **5 lines flagged in 5 categories**, all in `NotesListView.swift`. The root-view findings should be gone. Do not move on if a different file was edited by mistake.

## 3. Give the toolbar separate, labeled actions

In the practice copy of `NotesListView.swift`, replace the entire `.toolbar { ... }` modifier with this one. Keep the surrounding `NavigationStack`, scrolling content, and `.navigationTitle`:

```swift
.toolbar {
    ToolbarItemGroup(placement: .topBarTrailing) {
        Button("Compose", systemImage: "square.and.pencil", action: {})
    }
    .visibilityPriority(.high)

    ToolbarOverflowMenu {
        Button("Sort by Date", systemImage: "calendar", action: {})
        Button("Select Notes", systemImage: "checkmark.circle", action: {})
        Button("Settings", systemImage: "gearshape", action: {})
    }
}
```

The fixture already uses empty action closures; they remain empty here to focus on layout. In a real app, move each existing action into its matching button—do not replace working actions with these placeholders.

Compose gets priority, every action has a title and symbol, and the three secondary actions remain reachable through the system overflow menu. There is no manual spacer or group of buttons hidden inside one toolbar item. The overflow title also stays available when the system changes an item's presentation. These toolbar APIs require iOS 27.0 or later; see [ToolbarOverflowMenu](https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu).

```bash
bash "$DUO_AUDIT" "$DUO_LAB/NotesApp" -q
```

Expected: **1 line flagged in 1 category**—the fixed three-column grid. Exit `1` is still correct.

### Why leave the grid for a separate layout decision?

Changing `count: 3` to another fixed number can silence this particular warning without making the layout adapt. Decide how many readable cards fit in the view's available width, and account for a division region when a fold is present. A bare `.adaptive` grid can still produce an odd count.

Use the [fold and grid guidance](https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site/references/apple-hig-designing-for-iphone-duo.html#3-dynamic-layouts) and [code patterns](https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site/references/apple-hig-designing-for-iphone-duo.html#7-code-patterns) for that next step. Scrolling grids and stationary controls need different treatment; inspect the actual screen rather than adding hinge-angle layout branches.

For comparison, this repository's clean fixture should exit `0`:

```bash
bash "$DUO_AUDIT" tests/fixtures/Clean -q
```

That demonstrates a clean scan, not a tested shipping app.

## 4. Apply the workflow to your app

Replace the example path below with your app's source folder, including its project configuration:

```bash
DUO_APP="/absolute/path/to/Your App"
bash "$DUO_AUDIT" "$DUO_APP" -s
bash "$DUO_AUDIT" "$DUO_APP" -q
```

Fix launch and scene-lifecycle problems first, then sizing and safe-area assumptions, then bars and fold-related layout. Rerun the audit after each focused change and explain any hits you keep. A fixed-width icon, for example, has a different purpose from a fixed-width page container.

If you use an agent, give it a bounded task:

> Use the iphone-duo-design skill to audit the app at [my app path]. Start with a summary, then inspect each finding in context. Fix launch blockers and layout problems while preserving existing actions, state, and the deployment target. Build with my app's scheme if available. Report remaining findings and identify which display and pose checks still need a simulator or device. Do not claim the app is ready based only on a clean scan.

For the local unreleased changes, point the agent at this checkout's `skills/iphone-duo-design/SKILL.md`; a previously installed copy can be older.

### JSON project settings

The audit also reads `.xcproj` files inside `.xcodeproj` bundles. It checks project and target `build-settings` objects, including conditional keys such as:

```json
{
  "build-settings": {
    "INFOPLIST_KEY_UIRequiresFullScreen[config=Release]": "YES"
  }
}
```

This is a **settings excerpt**, not a complete project. It produces a full-screen opt-out candidate. The scanner accepts strings, arrays of strings, comments, and trailing commas as Xcode emits them. It does not evaluate inherited values, target overrides, or external `.xcconfig` files. Confirm effective settings for each configuration in Xcode before changing them.

## 5. Verify what the scanner cannot see

Build your real app with the iOS 27.1 SDK or later. Then walk this short checklist in Device Hub and, where needed, directly on hardware:

| Try this | Look for this |
|---|---|
| Close the device; rotate the outer display | Side bars fit, and the camera region covers no important content. |
| Open in landscape, then portrait | Side bars in inner landscape; horizontal bars in inner portrait. |
| Partially fold in book and tabletop poses | Important stationary text and controls stay clear of the fold; movement is modest. |
| Switch between displays while editing | Selection, drafts, and scroll position survive. |
| Use Split View on either side; try a right-to-left language | Content respects the hardware edge and asymmetric safe areas. |
| Use the smallest window and larger Dynamic Type | Actions remain reachable; text can reflow or scroll. |
| Use VoiceOver directly on a device | Labels, reading order, and focus work across layouts. |

The full [verification checklist](https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site/references/skill.html#verification-checklist-mark-each-row-verified-fixed-or-not-verifiable) also covers active cameras and Live Activities. Mark each check **verified**, **needs work**, or **not tested**.

A useful report is specific: “Audit: one grid finding remains. Build: passed with the iOS 27.1 SDK. Outer-display rotation: tested. Fold and VoiceOver: not tested.” Never copy that example as a result without doing those checks.

## Everyday tips

- **Size from the view, not the phone model.** Available space changes while the app is running.
- **Let containers own the bars.** Use `TabView`, navigation containers, and toolbar items; avoid drawing a replacement tab bar.
- **Keep actions near their content.** List-level controls belong with the list, not automatically in the detail pane's side bar.
- **Prefer small adjustments around the fold.** Use reserved regions for layout; use hinge angle for interactions that actually need it.
- **Give icon actions names.** Titles are useful in overflow menus and for accessibility even when only symbols are visible.
- **Review advisory cropping hits.** Aspect fill can be right for a thumbnail and wrong for a diagram; the scanner cannot decide that from syntax.
- **Keep the audit output useful.** Start with `-s`, inspect with `-q`, and use `-n 0` only when you need every location.

## Troubleshooting

| Symptom | What to do |
|---|---|
| The audit exits `1` | Review the candidates. This is the normal result for the unmodified Notes fixture. |
| “No Swift files or Xcode projects” | Check the path. A folder containing only a plist is not enough. |
| A JSON project exits `2` | Check Python 3 and the reported file. Unsupported JSON5 syntax, duplicate keys, and malformed input are explicit errors; do not treat them as clean. |
| A screenshot is black | Check the selected display and allow startup time. Xcode 27.2 RC documents temporarily black captures after boot. |
| Device Hub cannot expose Duo content to VoiceOver | Xcode 27.2 RC has a documented limitation. Test directly on hardware. |
| The audit is clean but the screen still looks wrong | Inspect view behavior, safe areas, overflow, state, and effective build settings. Static pattern matching cannot verify them all. |

Tool limitations are version-specific. Check the maintained [testing notes](https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site/references/apple-hig-designing-for-iphone-duo.html#5-beyond-the-hig-developer-article-and-tech-talks) and [Apple's Xcode release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27_2-release-notes) when your Xcode version changes.

For submission assets, use the [shipping guide](https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site/references/shipping.html). For capture and the outer display, use the [camera guide](https://duo-field-guide-tudor.scopeworker-2245.chatgpt.site/references/cameras-and-scene-accessories.html).
