# Duo Playground

A native SwiftUI learning app for the iPhone Duo simulator. Edit a note, change the actual simulator pose, and inspect the layout values the running app receives. Requires Xcode 27.1 and an installed iOS 27.1+ Duo simulator. No packages, account, signing team, camera access, or network service are required for simulator use.

## Run

Open `DuoPlayground.xcodeproj` in Xcode, select the **DuoPlayground** scheme and **iPhone Duo**, and press Run. Or, from the repository root:

```bash
bash apps/DuoPlayground/scripts/run.sh
```

An optional simulator UDID can be supplied as the first argument. The script builds and installs only this app. It does not erase or reset the simulator.

## Start with these experiments

1. **Workbench:** edit “Room to think.” In Device Hub, select Closed, then Open. Your draft and selected note stay in the model. Notes are saved locally across app launches.
2. **Inspect:** enable Region guides, then select Partially Open. Orange shows active division regions; purple shows occlusion regions actually returned by the system. This app does not start camera capture.
3. **Break it, then fix it:** turn on the fixed-width canvas in Inspect and close the device. Observe clipping; turn it off to restore the flexible editor. This intentionally broken comparison never replaces the draft model.
4. **Experiments → Let the container arrange:** open the sandbox. Compare Split and Overlay with the device flat and partially folded; rotate the device to compare fold axes. Use the slider or the labeled increase/decrease buttons to change the shared readout across arrangements. The controls retain a percentage readout when the other pane cannot fit.
5. **Follow the system controls:** compare the actual toolbar placement across outer, inner landscape, and inner portrait. The event trace records changes to `toolbarVerticalEdge`. Read the Swift patterns and answer the last experiment.

Progress is verified from specific app events, except the final multiple-choice exercise. “Verified” describes that observation, not full device readiness or a complete app audit. The arrangement experiment verifies that both styles were tried; you still need to inspect their behavior in different poses yourself.

Use **Restart progress** in the Experiments toolbar to repeat the lessons without deleting notes.

## What is real

- `GeometryProxy.size`, `safeAreaInsets`, actual horizontal size class, and `toolbarVerticalEdge` from the workspace.
- `reservedRegions(kind:options:)` queried in workspace coordinates, including inactive regions.
- `onHingeChange` status and angle. The angle is diagnostic and never chooses a layout.
- Actual `ArrangementView` split/overlay containers and container-owned toolbar items.
- A stable `@Observable` note model owned by `@State` above the tab and layout trees.
- Scene phase events, local note persistence, and a bounded event trace.

Workspace readings remain at their last value while another tab is visible. Safe-area values describe the measured content view, not the entire display. Region overlays do not intercept taps. A scrolling editor may cross the fold; do not infer that an arbitrary custom control can do the same. Hinge changes trigger region queries independently of size changes.

## Source map

| File | Try changing |
| --- | --- |
| `DuoPlaygroundApp.swift` | The stable model owner |
| `WorkbenchView.swift` | System toolbar groups and horizontal split arrangement |
| `NoteEditor.swift` | Flexible vs intentionally fixed-width canvas |
| `LayoutSnapshot.swift` | Geometry, size-class, toolbar, and region queries |
| `RegionOverlay.swift` | Coordinate-correct, noninteractive region visualization |
| `ArrangementSandbox.swift`, `ArrangementControls.swift` | Real split/overlay styles and overlay z-index |
| `LabModel.swift` | Persistence, evidence-based progress, and event logging |
| `Experiment.swift` | Instructions and Swift excerpts |

These APIs require the iOS 27.1 SDK; the project deliberately targets iOS 27.1 so the code does not hide the teaching APIs behind fallback implementations. Source examples in the app are excerpts; the Xcode project contains their compiled implementation.

See `Verification/RESULTS.md` for the checks performed on this machine.
