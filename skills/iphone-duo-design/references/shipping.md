# Shipping an iPhone Duo app to the App Store

Source: Apple's news post [Prepare and submit your apps for iPhone Duo](https://developer.apple.com/news/?id=kkphp5qo)
(2026-10-05), its [Three steps](https://developer.apple.com/iphone-duo/prepare/) checklist, and the App Store
Connect help pages, checked 2026-10-07. Read this only when the user asks about submission. Back to the [main reference](apple-hig-designing-for-iphone-duo.md).

- **Dates.** iPhone Duo is available to customers from **October 23, 2026**. Apps and games optimized for it can be
  submitted in App Store Connect now. **Starting April 2027, every submitted app or game must include iPhone Duo
  screenshots.** The screenshot specifications page doesn't list that requirement yet and doesn't mark Duo as
  required (iPhone with Dynamic Island and, for iPad apps, iPad 13-inch are); the news post is the newer source,
  so plan for it and re-check both before a submission.
- **Build.** The device runs iOS 27.1 at launch. Recompile with Xcode 27.1, which adds iPhone Duo development support
  (updated SDKs and a simulator with the new poses and orientations). "Optimized for iPhone Duo" means built with
  the iOS 27.1 SDK or later; older builds still run, in less of the display (table in the main reference, §5).
  Figma and Sketch design kits are in [Apple Design Resources](https://developer.apple.com/design/resources/). Use
  Device Hub to see every pose and orientation. Apple runs in-person iPhone Duo workshops (more cities added in October) and online Group Labs
  (October 13 and 15, 2026; earlier sessions are on demand).
- **Screenshots** (`.jpeg`, `.jpg`, `.png`; 1 to 10 per device size). Outer display 1398 × 2034 portrait or
  2034 × 1398 landscape; inner display 2007 × 2853 portrait or 2853 × 2007 landscape. Capture them from the right
  display: `simctl io <device> enumerate`, then `screenshot --display=<id>`, and use the pose each screenshot is meant
  to show (outer for the compact layout, inner landscape for list + detail).
- **App previews** (15 to 30 seconds; up to 3 per device size and language; `.mov`, `.m4v`, `.mp4`, H.264; 500 MB
  max). Accepted sizes 886 × 1920 portrait or 1920 × 886 landscape. Device resolutions are 2034 × 1398 and
  2853 × 2007 (19.5:9).
- **Product page.** There are new product page header and search-result assets, and templates and guidance at
  [asset best practices](https://developer.apple.com/app-store/asset-best-practices/). Their sizes aren't
  Duo-specific: see the [creative assets specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications).
  App Store Connect has a preview tool that shows how screenshots, headers, and other metadata look on iPhone Duo
  (with Dark Mode and orientations), and an Asset Library for uploading assets ahead of use.
- **Featuring.** Submit a featuring nomination in App Store Connect; its Helpful Details section lets you say the app
  is optimized for iPhone Duo, including support for all device poses.
- **Not confirmed.** Press coverage of the launch post says product pages show an "optimized for iPhone Duo" badge for
  Xcode 27.1 builds. Apple's post and the pages it links don't mention one (checked 2026-10-07): don't promise it.
- Capture screenshots from the adapted layout (not a scaled iPhone screenshot), with real content and nothing
  under the camera or fold.
- Links: [screenshot specs](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications),
  [app preview specs](https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications),
  [manage assets](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets),
  [submitting](https://developer.apple.com/app-store/submitting/).
