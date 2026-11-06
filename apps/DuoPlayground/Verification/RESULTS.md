# Verification · 27 October 2026

Built with Xcode 27.1 (27A9275), the iPhoneSimulator27.1 SDK, and Swift 6 language mode. Ran the app on the installed iPhone Duo / iOS 27.1 simulator through Device Hub.

## Passed

- Final Xcode build: **BUILD SUCCEEDED**, no Swift compiler errors or warnings. The build emits the standard App Intents metadata-extraction warning because this app has no App Intents dependency.
- `scripts/run.sh`: executed successfully, selected the existing Duo simulator, built, installed, and launched the app. Shell syntax check also passed.
- Xcode project plist validation passed. No external packages were installed.
- Native startup: system navigation and tabs, editable notes, and live inspector rendered on the inner display.
- Draft continuity: entered `Test` using the simulator’s actual on-screen keyboard. That exact draft remained after opening the closed device and after rebuilding/relaunching the app.
- Local persistence: note contents and experiment completion survived app replacement/relaunch.
- Outer/inner adaptation: observed compact outer workspace and regular inner workspace; the inspector pane collapses when the horizontal arrangement cannot fit, with Inspect still available as a system action.
- Region queries: observed active and inactive divisions and occlusions supplied by the system. With guides enabled, the horizontal fold and status/camera region were visibly outlined. Flat/partially-open changes were exercised without relying on an app-owned hinge threshold.
- Portrait/tabletop: workspace reported **669 × 786 pt**, regular width, horizontal/no vertical toolbar edge, 128° partially-open hinge; active division frame **x 0, y 373, 669 × 40 pt**.
- Inner landscape: workspace reported **867 × 553 pt**, regular width, trailing toolbar edge; hinge reported 128° partially open and 180° fully open in the respective poses.
- Asymmetric insets: inner landscape reported leading 0 and trailing 84 pt. The inspector reports each side independently.
- Fragile comparison: enabling the fixed-width editor produced the warning and a 680 pt canvas on a compact display. Inspector remained reachable. The toggle was read back as enabled; see `compact-fragile.png`.
- Arrangement sandbox: verified the full-screen presentation with native split and overlay styles on outer, inner landscape, and inner portrait/tabletop displays. In tabletop overlay, the readout visibly sits above the horizontal fold and controls below it. The actual overlay environment reading is displayed.
- Readout controls: Increase value changed the shared readout and native slider from 35% to 55%. The 55% value survived split/overlay switches, closing, reopening, and rotation. The compact controls include their own percentage readout and labeled increment/decrement buttons.
- Keyboard Done: tapping the keyboard toolbar’s checkmark ended editing and restored workspace height from 505 to 553 pt.
- Final exercise: the incorrect hinge-threshold choice displayed corrective feedback. The stable-model/regions choice displayed the correct explanation and completed the fifth experiment.
- Progress: observed 5/5 verified after running the five learning experiments.
- Restart progress: opened the confirmation, selected Restart progress, and observed 0/5 verified with all five lessons available again. The simulator was left on that fresh Experiments screen. Device Hub keyboard capture was restored to off.

## Readiness scanner

The read-only audit flags two teaching-text matches in this app:

1. `Experiment.swift` includes `UIScreen.main` inside a string explaining what to avoid. The app does not call it.
2. `ExperimentDetail.swift` includes “Go to Workbench” and `selectedTab` on a button line, which matches the scanner’s homemade-tab-bar heuristic. The actual tab bar is a native `TabView`.

The fixed 680 pt editor is an intentional, user-controlled broken comparison, isolated from navigation and persistence. This is documented rather than presented as production-ready layout code.

## Verification limits

Testing resumed after the Mac was unlocked. The full-screen sandbox, quiz feedback, keyboard Done action, and native readout buttons were then exercised. Direct slider dragging through the automation bridge did not change the value and remains unverified; the standard SwiftUI slider reflects binding changes correctly, and the explicit increase/decrease controls provide a verified input path. Relaunching restored the fragile toggle to its adaptive default and the normal editor was observed again.

Not tested: physical hardware, Split View as both apps, RTL, VoiceOver, largest accessibility text, active camera capture, outer-display Live Activities, or hardware-camera behavior. No claim of full app readiness is made from this learning sample. These remain separate device-validation exercises.

## Screenshots

- `tabletop.png`: native portrait/tabletop workspace with actual region guides.
- `compact-fragile.png`: intentionally fixed-width editor on the outer display.
- `arrangement-tabletop.png`: verified full-screen overlay sandbox with 55% shared readout above the fold and controls below it.

The latest successful build/install/launch is recorded in `run.log`; `build.log` records the preceding successful build. Workspace screenshots precede the final readout buttons; `arrangement-tabletop.png` shows those buttons in the latest build.
