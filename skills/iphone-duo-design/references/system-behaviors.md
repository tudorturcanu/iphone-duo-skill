# System behaviors on iPhone Duo: windows, media, motion, widgets, web

Original summary of Apple's written highlights of the iPhone Duo Group Labs
([forum thread 847644](https://developer.apple.com/forums/thread/847644), posted by an Apple DTS engineer in September
2026; [sessions on demand](https://developer.apple.com/videos/play/meet-with-apple/285)), read 2026-10-07. API names
and availability were checked against Apple's docs the same day. These are engineers' answers in a Q&A, not reference
documentation: they can change, so test on a device before relying on one. Read this only when the question is about
one of these topics. Back to the [main reference](apple-hig-designing-for-iphone-duo.md).

Availability: `CMBodyIdentifiable`, `CMMotionManager.deviceMotionBody`, and `WidgetFamily.systemExtraLargePortrait`
are iOS 27.0; `UITabAccessory` and AlarmKit are 26.0; the rest is older. Guard with `#available`.

## 1. Windows and multitasking

- iPhone Duo is the first iPhone that runs several instances of an app's UI, with iPad's scene model: each instance
  is its own `UIScene`. New windows can be created only on the inner display.
- `UserDefaults` and `@AppStorage` are app-wide, so every instance shares them. Keep per-window state in the scene.
- Two apps share the inner display in Split View. There is no Stage Manager and no free-form drag-to-resize: an app's
  size changes with the pose and with Split View only.
- There is no iPad-app compatibility mode (unlike Apple Vision Pro). How much of the display an iPhone app gets
  depends on the SDK it was built with (table in the main reference, §5).

## 2. State across folds

- Opening or closing is a size-class and trait change in the same scene; the process stays alive. Text being edited,
  the keyboard, and scroll position generally carry over, even when a `LazyVGrid` changes its column count, so
  there's usually no need to manage `scrollPosition(id:anchor:)` for this transition.
- For state that must survive a real scene disconnect and reconnect, save an `NSUserActivity` from
  `stateRestorationActivity(for:)`.
- The hinge angle's update rate and precision are system policy and can change: don't build game mechanics that
  depend on either.

## 3. Media

- Picture in Picture (`AVPlayerViewController` or `AVPictureInPictureController`): open in landscape, people can pin
  the video to the top while the current app resizes vertically into the rest. Partially folded, the video grows to
  fill half the screen, so the app's height changes live. Picture in Picture moves to the outer display only when the
  device closes, and the system controls that move.
- With several instances, the active audio or video session belongs to the one that most recently started playback.

## 4. Core Motion

Each display faces a different way, so raw attitude doesn't match the UI. `UIView` conforms to `CMBodyIdentifiable`:

```swift
motionManager.deviceMotionBody = view          // nil = the device's hardware coordinate frame
motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { motion, _ in
    guard let attitude = motion?.attitude else { return }   // already relative to `view` and the display it's on
}
```

- Core Motion transforms orientation, rotation rate, gravity, and user acceleration to match that view, and keeps
  doing so as it rotates or moves to the other display. Use one motion manager per view when two views need their
  own frame.
- Sources disagree about Split View: the Group Labs answer says that when the scene isn't full screen, body-relative
  orientation isn't available and data arrives in the device's default frame, while the `CMBodyIdentifiable` docs
  describe it working in Split View. Test both cases on a device before relying on either.
- You don't need to work out which face is up to lay out the UI: size classes and traits cover that.

## 5. Outer display, Live Activities, widgets

- An app can't draw on the outer display while the device is open. The ways in are system-controlled: a camera
  capture scene accessory ([cameras](cameras-and-scene-accessories.md)), or AlarmKit, where the system presents the
  alert through AlarmKit, StandBy, or the Dynamic Island. For AlarmKit, make the alarm-management scenes resize for
  every size class and design the countdown Live Activity well.
- Live Activities: the outer camera's region grows into the Dynamic Island. Implement every presentation in
  `ActivityConfiguration` (`compactLeading`, `compactTrailing`, `minimal`, the expanded regions, the Lock Screen).
- Widget families: `systemSmall`, `systemMedium`, `systemLarge`, `systemExtraLargePortrait`, and the accessory
  families (`accessoryCircular`, `accessoryRectangular`, `accessoryInline`).
- Custom content beside the tab bar (a mini player, a status dot): attach a `UITabAccessory` through
  `UITabBarController.bottomAccessory` instead of drawing a custom tab bar, which never moves to the side. It lays
  out regular or inline, reported by `UITabAccessory.Environment`.

## 6. Web content

- Safari has the Viewport Segments and Device Posture APIs, but in iOS 27.1 both are experimental and off by default
  (Settings > Apps > Safari > Advanced > Feature Flags). Don't ship web content that depends on them.
- There is no device-detection API for iPhone Duo. Use responsive layout, as for any screen size.

## 7. Accessibility

- Dynamic Type behaves the same on both displays (`preferredContentSizeCategory`). On a fixed, one-screen layout,
  holding text at the largest standard size instead of letting it reflow or scale can fail the accessibility
  guidelines, and the short outer display makes this more likely: let content scroll.
- VoiceOver order follows standard containers and grouping. A custom layout that spans the fold may need explicit
  accessibility containers or sort priorities.
- Test Dynamic Type and contrast in each pose. Test VoiceOver directly on a device: Xcode 27.2 RC's Device Hub has an
  accessibility inspection limitation; see [testing](apple-hig-designing-for-iphone-duo.md#5-beyond-the-hig-developer-article-and-tech-talks).
