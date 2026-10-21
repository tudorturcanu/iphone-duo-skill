# Cameras and scene accessories on iPhone Duo

Original summary of Apple's articles *Choosing a camera by the direction it faces* (AVKit) and *Registering a camera
capture accessory on iPhone Duo* (AVFoundation), plus tech talks 111464 (multiple displays and scenes) and 111465
(camera). Checked against Apple's docs on 2026-10-21. Read this only for apps that capture photos or video, or that
show content across both displays. Back to the [main reference](apple-hig-designing-for-iphone-duo.md).

Availability: `AVCaptureDeviceDirectionCoordinator`, `AVCaptureDeviceDescriptor`, `AVCaptureDeviceDirectionMap`, the
outer / inner ultra-wide device types, `CameraCaptureAccessory`, and `UISceneAccessory.cameraCapture(...)` are **iOS 27.1**
(final release in Xcode 27.1). `sceneAccessory(content:)`, `onAvailabilityChange(perform:)`, `UISceneAccessoryRegistration`, and
`registerSceneAccessory(_:)` are 27.0. Guard with `#available`. Simulator has no camera: test capture on a device.

## 1. Which way a camera faces

Each display has its own front camera. Opening or closing the device moves your app to the other display, so a camera
that faced the same way as your UI can now face the opposite way. `AVCaptureDevice.Position` says where a camera
**sits**, not which way it **points**.

- **Easiest path: the virtual front camera.** A `DiscoverySession` for `.builtInWideAngleCamera` /
  `.builtInUltraWideCamera` at `.front` returns it on iPhone Duo. It streams from the camera above the display your app is
  on and follows the app as the device opens and closes, so existing front-camera code works unchanged.
  `isVirtualDevice` is true; `activePrimaryConstituent` says which physical camera is streaming. It exposes only what
  both cameras can do.
- **Capture is the app's main job:** use `.builtInOuterUltraWideCamera` and `.builtInInnerUltraWideCamera` for
  everything each camera can do, and follow the direction yourself with `AVCaptureDeviceDirectionCoordinator`.

## 2. Following direction

```swift
@MainActor final class DirectionObserver {
    private var coordinator: AVCaptureDeviceDirectionCoordinator?
    func start(previewView: UIView) {
        coordinator = AVCaptureDeviceDirectionCoordinator(
            view: previewView,   // frame of reference only, it draws nothing
            deviceTypes: [.builtInOuterUltraWideCamera, .builtInInnerUltraWideCamera, .builtInDualWideCamera]
        ) { [weak self] directions in self?.didChange(directions) }
    }
}
```

- List every built-in camera you capture from, **including rear cameras** (a rear camera can face forward: a selfie).
  List the two physical front cameras instead of the virtual one. External, Continuity and Desk View cameras are ignored.
- Keep a strong reference for as long as the view is onscreen. One coordinator per view: a preview on each display
  needs two, and the same rear camera is forward-facing for one and backward-facing for the other.
- The handler runs on the main actor soon after creation and on every change; until then `deviceDirections` is empty.
  `AVCaptureDeviceDirectionMap` has `forwardFacingDeviceDescriptors` (same way as the view) and
  `backwardFacingDeviceDescriptors`. If your active camera isn't in the forward list, switch to one that is.
- Descriptors are `Sendable`: pass `AVCaptureDeviceDescriptor` (`uniqueID`) to the actor that owns the session, resolve
  it there with `AVCaptureDevice(uniqueID:)`, and handle `nil` (the camera set can change while you dispatch). Don't call
  AVFoundation from the handler.
- Replace the single video input (`beginConfiguration` / `commitConfiguration`), rather than connecting both cameras in
  a multicamera session; it's cheaper and covers most apps.
- While switching, frames from the old camera still arrive: mask the preview and unmask after the new device delivers frames.
- **Mirroring comes from the direction map, not `position`.** Mirror a forward-facing rear camera yourself; show a
  backward-facing front camera unmirrored. Set `automaticallyAdjustsVideoMirroring = false` before assigning
  `isVideoMirrored`, and check `isVideoMirroringSupported` (assigning otherwise raises an exception).
- Also handle preview aspect ratio, position, and rotation as the device opens and rotates (talk 111465).

## 3. Showing content on the outer display while capturing (scene accessory)

When the device is open and the rear camera is capturing, the outer display faces the subject. A camera capture
accessory shows content there (a teleprompter script, a countdown, a framing preview).

```swift
// SwiftUI: register on the view that shows the capture interface.
CameraPreview().sceneAccessory {
    CameraCaptureAccessory(isEnabled: $isScriptEnabled) { ScriptView(model: script) }
        .onAvailabilityChange { showsScriptControls = $0 }
}
// UIKit: keep the registration; unregister rather than hide.
let accessory = UISceneAccessory.cameraCapture(sceneConfiguration: configuration, userInfo: script)
registration = registerSceneAccessory(accessory)   // UISceneAccessoryRegistration: isAvailable, isEnabled
```

- Treat it as an **enhancement**: the system decides when and where to present it and can withdraw it any time. Presented
  only while the device is open, the app is in the foreground, and a capture session runs. The capture interface must
  work fully without it, and essential controls stay there. Hide outer-display controls when it isn't available.
- You declare a kind of content and pass no display, session, or camera; the system finds the capture session.
- Share state by giving both sides the same model object (SwiftUI closure capture, or `userInfo` read back from
  `connectionOptions.sceneAccessoryUserInfo` in the scene delegate). Hold a strong reference; keep persistent state in the model.
- `registration.isAvailable` is observable (read it in `updateProperties()`). Let people turn the content off with
  `isEnabled` (default on), don't unregister for that. The system shows the top-most registration of a kind, so
  navigating to a view that registers its own makes the previous one unavailable until you go back.
- Accessory scenes have no manifest entry; identify one by the session role `windowCameraCaptureAccessory`.
- Keep interaction minimal (a tap to focus suits it); the display accepts touch, but it isn't a second interface.
- Because the system can withdraw the content at any moment (device closes, app leaves the foreground, capture ends),
  make animations able to start, pause, and stop cleanly. For custom timing use `TimelineView` or `CADisplayLink`,
  as on any display (Apple DTS).
- Apps that don't capture can't draw on the outer display while the device is open: a scene accessory (or AlarmKit,
  see [system behaviors](system-behaviors.md)) is the only way in.

## 4. Other multi-display and multi-window notes (talk 111464)

- Handle dynamic window sizes, and request new scenes in side-by-side multitasking. The talk's summary doesn't name the
  APIs here: leave a marked `TODO` rather than guessing.
- Hinge angle: observe it for interactive effects only (`onHingeChange` / `UIHingeInteraction`); don't drive layout from it.
