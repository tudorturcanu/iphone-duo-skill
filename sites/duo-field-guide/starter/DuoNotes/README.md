# Duo Notes starter

A complete, dependency-free SwiftUI app from the Duo Field Guide. It demonstrates adaptive navigation, container-managed system actions, and a stable editing model.

## Run

1. Open `DuoNotes.xcodeproj` in **Xcode 27.1 or later with the iOS 27.1+ SDK**.
2. Select the `DuoNotes` scheme and an iPhone Duo simulator, then Run.
3. For a physical device, select your own development team under Signing & Capabilities. You may need to change the sample bundle identifier.

The app's minimum deployment target is iOS 26. The **build SDK** enables the full Duo display and side bars; it is separate from the minimum supported OS version. The project uses Swift 6 and Main Actor default isolation for the observable UI models. It has no external packages and uses the SwiftUI scene life cycle.

## Find your way through the source

- `DuoNotesApp.swift` owns one notebook above the adaptive interface.
- `Notebook.swift` holds notes and selection. Resizing never replaces it.
- `Note.swift` gives each editable note stable identity.
- `NotesView.swift` uses `NavigationSplitView`, selection, and labeled system toolbar actions.
- `NoteEditor.swift` binds text fields directly to the selected note and uses Dynamic Type fonts.

## Exercise the app

- Edit the first note. Open and close the device. Verify the selected note and text survive.
- Select the other note, edit it, then return to the first. Verify both drafts are intact.
- Rotate the inner display. Check system bar placement and that New Note remains reachable.
- Try Book pose. Check native split-view balancing and the fold area.
- Narrow the app with Split View. Navigate from the list to the detail, edit, then return.
- Increase Dynamic Type and test VoiceOver on hardware.

The app relies on system containers for adaptive navigation and region handling. It does not implement a custom tabletop arrangement or camera interface. See the guide's region chapter and native Duo Playground for those APIs.

## State and privacy

Notes live only in memory during the app session. Relaunching resets the sample. No notes leave the app. Production persistence, sync, and conflict handling are outside this starter's scope.

## Build from Terminal

```bash
xcodebuild -project DuoNotes.xcodeproj -scheme DuoNotes \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

A successful simulator build verifies compilation; the interactive checks above still require running the app.

Independent sample. Not affiliated with Apple. MIT license; see LICENSE.
