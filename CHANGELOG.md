# Changelog

All notable changes to this skill are listed here. Versions follow [Semantic Versioning](https://semver.org).

## [1.3.2] - 2026-10-21

Prompted by the final release of Xcode 27.1 / iOS 27.1, the App Store Connect screenshot specifications
update, and Apple's confirmation of the "optimized for iPhone Duo" App Store product page badge.

### Added
- App Store product page badge: Apple's official [Three steps](https://developer.apple.com/iphone-duo/prepare/)
  page now confirms that when you submit iPhone Duo screenshots in App Store Connect, your App Store product
  page displays an "optimized for iPhone Duo" badge. Moved from "Not confirmed" to confirmed in `references/shipping.md`.
- `tests/check_apple_sources.py` now verifies the "display a badge" confirmation on the prepare page alongside the
  other launch facts.

### Changed
- Xcode 27.1 and iOS 27.1 status: updated from Release Candidate (RC) to final release in `SKILL.md`,
  `references/apple-hig-designing-for-iphone-duo.md`, `references/shipping.md`, and `README.md`.
- iOS 27.1 APIs out of beta: all 35 iOS 27.1 APIs in `tests/apple-apis.tsv` (ReservedRegion, ArrangementView,
  UIArrangementViewController, onHingeChange, UIHingeInteraction, vertical bar behaviors and edges,
  AVCaptureDeviceDirectionCoordinator, CameraCaptureAccessory, etc.) are now out of beta in Apple's documentation
  metadata. `apple-apis.tsv` updated via `tests/check_apple_apis.py --update`.
- Screenshot specifications page: the App Store Connect specifications page now officially documents the April
  2027 requirement ("Starting in April 2027, screenshots will be required for any app using the iOS 27.1 SDK or
  later"). Updated `references/shipping.md`, `tests/check_apple_sources.py`, and Eval 6 in `tests/evals/evals.json`.
- HIG article drift check: section hashes in `tests/hig-duo.sha256` updated via `tests/check_hig.py --update` after
  re-reading the full article; every design guidance point in `references/apple-hig-designing-for-iphone-duo.md`
  remains verified and accurate.

## [1.3.1] - 2026-10-07

Prompted by Apple's [Three steps to make your app shine on iPhone Duo](https://developer.apple.com/iphone-duo/prepare/)
page and [Hello Developer: October 2026](https://developer.apple.com/news/?id=gv788oj6) (2026-10-06).

### Added
- Audit: three detections from Apple's list of resize patterns. Comparisons with known iPhone sizes
  (`bounds.height == 844`), `statusBarOrientation` and any `.interfaceOrientation` read (including
  `effectiveGeometry.interfaceOrientation`), and an advisory category for aspect-fill media that may crop on the
  wider displays (`.scaleAspectFill`, `contentMode: .fill`, `.scaledToFill()`). Aspect fill is usually correct, so
  advisory matches are listed with a `◦` and never change the exit code (CI tests this). 7 new marked fixture lines
  and look-alike clean lines.
- `references/system-behaviors.md`, from Apple's written highlights of the iPhone Duo Group Labs: several windows of
  one app (inner display only), state across folds, Picture in Picture, Core Motion with `deviceMotionBody`, AlarmKit
  and the outer display, Live Activities and widget families, `UITabAccessory`, experimental web APIs, and
  accessibility. Its 7 API names join the weekly check (64 in all); the Core Motion sample typechecks against the
  iOS 27.0 SDK. The main reference gains three points from the same source: touches in a reserved region may not
  register, `toolbarVerticalEdge` is the signal for vertical bars, and hinge update rate is system policy.
- What each SDK gets on iPhone Duo (iOS 26: centered with empty space; 27.0: most of the inner display; 27.1: full
  display with side bars), in `SKILL.md` and as a table in the reference.
- Testing without the iPhone Duo simulator: the resizable simulator in Device Hub and iPhone Mirroring on macOS 27
  replace the old "approximate with iPad Split View" advice.
- Reference §5: re-read sizes on every change (`viewWillTransition(to:with:)`, `UIWindow(windowScene:)`), regular
  width no longer means iPad, full-bleed media, and how Apple's app resizability skill in Xcode 27.1
  (`xcrun agent skills export`) relates to this one. The README says the same.
- `shipping.md`: what "optimized" means (iOS 27.1 SDK), featuring nominations, the creative assets specifications
  and Asset Library, Group Labs on October 13 and 15. It marks the product page badge reported by the press as not
  confirmed: Apple's post and the pages it links don't mention one.
- `tests/check_hig.py`: the HIG drift check now stores one hash per section, so a change report names the sections
  to re-read. `tests/check_apple_sources.py` also checks six facts on the "Three steps" page.
- Eval 7: an app built with an older SDK, and testing without the Duo simulator.

### Changed
- Benchmark (fourth round, all 7 evals, one run each, no web access on either side): 58/59 expectations with the
  skill vs 28/59 without (98% vs 47%). Eval 7 scored 6/6 vs 3/6, eval 6 6/6 vs 2/6.
- Tabletop rule: the one miss with the skill put a timer readout below the fold, because the rule said only
  "content on top". It now says what counts: what's read from afar (text, video, a timer readout).
- Evals: seven expectations that an answer with no iPhone Duo knowledge could pass are reworded ("nothing invented"
  now requires a Duo API to be used; preview sizes must be given for iPhone Duo; "check Apple's pages" must be about
  the April 2027 requirement). They apply from the next round.
- HIG article: its hash changed again between 2026-10-06 and 2026-10-07 with no change-log entry. Re-read in full;
  every point the reference summarizes still matches. With only a whole-article hash stored, what changed couldn't
  be identified, which is why the check is now per section.
- Xcode 27.1 is still a release candidate (27A9275) and the 57 APIs recorded before this release are unchanged,
  the iOS 27.1 ones still marked beta (2026-10-07).
- README counts corrected (28 trigger queries, 7 evals).

## [1.3.0] - 2026-10-06

Prompted by Apple's news post [Prepare and submit your apps for iPhone Duo](https://developer.apple.com/news/?id=kkphp5qo)
(2026-10-05).

### Added
- `references/shipping.md`: iPhone Duo is available October 23, 2026 (running iOS 27.1); from April 2027 every
  submission needs iPhone Duo screenshots. Screenshot sizes (outer 1398 × 2034, inner 2007 × 2853, plus landscape),
  app preview specs, product page assets, the App Store Connect preview tool, and the Figma and Sketch design kits,
  checked against the raw App Store Connect pages. It notes that the screenshot specifications page doesn't list
  the April 2027 requirement yet.
- `references/cameras-and-scene-accessories.md`: the virtual front camera, following camera direction with
  `AVCaptureDeviceDirectionCoordinator` (mirroring, descriptors, one coordinator per view), and camera capture scene
  accessories for the outer display. The 18 APIs it names join the weekly check (57 in all).
- `tests/check_apple_sources.py`, run weekly (`hig-drift.yml`, job `sources`): compares facts from the launch news
  post, the screenshot and preview specs, and the Xcode 27.1 release notes, and flags new iPhone Duo news posts.
- Workflow step 5 (only if asked) points to both files; the description now triggers on submission and camera
  questions. An eval (id 6) and two trigger queries cover submission questions.

### Changed
- Xcode 27.1 is now a release candidate, no longer a beta. The iOS 27.1 APIs are still marked beta in Apple's docs.
- HIG article re-checked: guidance is unchanged; it now links the screenshot specifications. Hash updated.
- The submission and camera material lives in their own files, so `SKILL.md` stays at 158 lines and loads them on demand.

## [1.2.2] - 2026-09-26

### Added
- Weekly CI check of the 39 Apple APIs the skill names (`tests/apple-apis.tsv`, `tests/check_apple_apis.py`): it
  fails when one disappears or its availability changes, for example when the iOS 27.1 APIs leave beta.

### Changed
- Reserved regions: going from flat to half-folded may not resize the view. Agents now test whether layout reruns
  and fall back to `setNeedsLayout()` from a `UIHingeInteraction`, instead of claiming it does.
- Evals: sharper expectations (even columns on fold devices, `#available` guards, bar placement in explanations,
  default query behavior split in two, tabletop palettes, state across folds).
- Benchmark (v1.2.1, third round): 41/42 expectations with the skill vs 26/42 without (97% vs 61%).

## [1.2.1] - 2026-09-26

A claim-by-claim fact-check of both files against Apple's docs, tech talks, and Apple forum answers, plus a
review of community resources and other iPhone Duo skills.

### Fixed
- Poses: the book pose (vertical fold) is landscape with side bars; the tabletop / laptop pose (horizontal fold) is
  portrait with horizontal bars and controls in the bottom half. 1.2.0 had tabletop as landscape.
- `UIScreen.main` is already deprecated (iOS 26.0), and on iPhone Duo its bounds keep the outer display's size.
- Grids: Apple DTS doesn't recommend making scrolling grids avoid the fold. The unsourced "widen the gap at the
  fold" advice is gone; even column counts stay.
- The Duo SDK and simulator ship only in Xcode 27.1 beta (27.2 beta doesn't include them).
- `overlayArrangementZIndex > 0` marks the view drawn on top, which is the one that collapses itself.
- `.defaultTabBarPlacement(.sidebar)` needs `.tabViewStyle(.sidebarAdaptable)`.
- Orientation locks and `UIRequiresFullScreen` wording now matches what Apple actually says.
- The fold-aware sample filters `isActive`, since one doc overview contradicts the default active-only query.
- Audit: file names with colons no longer make the script fail.

### Added
- Audit check: a UIKit app delegate without the UIScene life cycle won't launch with the iOS 27 SDK (TN3187).
- Scenes and state (folding is a resize, not a `scenePhase` change), `ArrangementView` collapsing to one view,
  sheets moving to the leading edge when folded, `toolbarVerticalBehavior` resolving per window or presentation.
- Testing: simulator known issues, capturing the right display with `simctl io … --display`, Previews "Display".
- CI: a regression test for paths with spaces and colons.

### Changed
- SKILL.md limit raised from 150 to 160 lines for the launch-blocker and verification guidance.

## [1.2.0] - 2026-09-26

Two rounds of benchmarking (5 evals, with vs without the skill, graded by independent agents) drove these changes.
Pass rate with the skill: 96%, without: 63%.

### Added
- Reference §7 "Code patterns": UIKit bar items, fold-aware `layoutSubviews`, and an even-column grid helper.
- Workflow: build or typecheck changed files when Xcode is available; guidance for design specs (plain behavior,
  API names in a short notes section) and scope (move actions, never drop them; add nothing unrequested).
- 6 harder trigger queries (paraphrases without "Duo", visionOS / Galaxy Z Flip / external-display near misses).

### Changed
- Grids: compute the column count and round to even whenever a fold can exist; `.adaptive` columns alone can be odd.
- Reserved regions: frames are in the queried view's coordinates, no change callback is documented, read them
  during layout.
- Bars: keep each action in the bar it came from (bottom-bar actions become toolbar items). Text actions such as
  Done may stay text-only.
- The outer display's side bar is on the camera's physical side, not "trailing" (it doesn't flip for RTL). Tabletop
  is a landscape pose, so bars stay on the side.
- Arrangement views: only overlay moves its views to either side of the fold; split adjusts around it.
- Availability: `visibilityPriority`, `ToolbarOverflowMenu`, `.topBarPinnedTrailing` are iOS 27.0; the rest 27.1.
- Description names paraphrases (folding, book-style iPhone) and excludes visionOS, external displays, Galaxy Z Flip.
- Evals: sharper expectations; fixture comments that gave answers away removed; the gallery's "…" menu now has
  real actions to preserve.

## [1.1.0] - 2026-09-26

Apple revised the HIG article after 1.0.0 (without a change-log entry) and published the iPhone Duo APIs
in the iOS 27.1 beta docs. The skill now uses them instead of telling agents to leave TODOs.

### Added
- Documented APIs (iOS 27.1 beta, checked against Apple's docs): reserved regions (`reservedRegions(kind:options:)`,
  `.division` / `.occlusion`), arrangement views (`ArrangementView`, `UIArrangementViewController`), hinge state
  (`onHingeChange`, `UIHingeInteraction`), and bar APIs (`axisBehavior`, `toolbarVerticalCompressionBehavior` /
  `verticalBarCompressionBehavior`, `toolbarVerticalBehavior` / `preferredVerticalBarBehavior`, `toolbarVerticalEdge` /
  `verticalBarEdge`, `.topBarPinnedTrailing` / `pinnedTrailingGroup`).
- Guidance from *Preparing your app for iPhone Duo* and tech talks 111461–111466: only container-managed bars go
  vertical, where bars stay horizontal (split-view sidebars, inspectors, some sheets), displacement rules for the
  fold, tabletop layouts, grid spacing at the fold, per-side safe-area insets, `UIScreen.main` deprecation.
- `references/`: table of contents, a "Beyond the HIG" section, and an API reference with signatures and availability.
- Audit detections: custom `UIToolbar` / `UITabBar` / `UINavigationBar` and homemade tab bars, symbol-only SwiftUI
  toolbar buttons, several controls stacked in one `ToolbarItem`, `UIBarButtonItem(image:)` without a title,
  `.ignoresSafeArea(.container, edges: .all)`, symmetric safe-area math (`insets.left * 2`), any `UIScreen.main`
  use, and disabled side bars. The audit now misses none of the NotesApp eval's anti-patterns (it missed 3 of 9).
- `expectations` for every eval, two new evals (no over-editing on clean code; exact fold API names), and
  `tests/evals/trigger_evals.json` with 10 should-trigger and 10 near-miss queries.
- CI: frontmatter validation (name, description length, `allowed-tools` syntax, `metadata.version` matches this
  changelog, links resolve) and eval well-formedness.
- `compatibility` and `metadata` (`version`, `author`) frontmatter.

### Changed
- Description rewritten in the third person with the terms users type and exclusions for near misses
  (Android foldables, Galaxy Z Fold, Surface Duo, iPad multitasking).
- Script paths are given relative to the skill folder (`${CLAUDE_SKILL_DIR}` in Claude Code), so they resolve
  from the user's project.
- `allowed-tools` uses the documented space-separated syntax and pre-approves only the read-only audit script and
  `xcrun simctl list devicetypes`. It pre-approves; it never restricted edits.
- Verification needs Xcode 27.1 beta; poses are changed from Device Hub.
- The audit exits `2` when the path holds no Swift files or Xcode project, instead of reporting a clean app.

### Fixed
- `UIRequiresFullScreen` doesn't block resizing: the app still resizes when the device opens or closes.
- Overlay arrangements place the primary view atop the secondary, not the reverse.
- `tests/hig-duo.sha256` updated to the revised article.

## [1.0.0] - 2026-09-13

### Added
- `SECURITY.md` describing what the skill does and how to report issues.
- CI: `shellcheck` on the audit script and a regression test against `tests/fixtures/`.
- "Scope & safety" section and `allowed-tools` / `license` frontmatter in `SKILL.md`.
- Audit script flags: `-s` (counts only) and `-n N` (matches per category).
- CI checks that audit output stays capped and that `rg` and `grep` give identical results.
- Audit detections: `UIRequiresFullScreen` (Info.plist and build settings), `screen.bounds` / `nativeBounds`, device orientation and model checks, `GridItem` array literals and compositional layouts with odd column counts, `.toolbarVisibility(.hidden, for: .tabBar)`, `Spacer()` between toolbar items, SwiftUI `systemImage: "ellipsis"` menus, and hard-coded home indicator insets.
- `tests/fixtures/Patterns/` (every marked line must be flagged) and `tests/fixtures/Clean/` (must report nothing), enforced in CI for both `rg` and `grep`.
- Weekly `hig-drift.yml` workflow that fails when Apple's HIG article changes.
- Verified API names from Apple's developer docs: SwiftUI `.visibilityPriority(_:)` and UIKit `UIBarButtonItem.visibilityPriority`, now used in the code examples. `UIView.LayoutRegion` noted as the closest documented reserved-region API, marked unconfirmed.

### Changed
- The skill now lives in `skills/iphone-duo-design/`, so installs contain only `SKILL.md`, `references/`, `scripts/`, and `LICENSE`.
- Evals and fixtures moved to `tests/`.
- `SKILL.md` cut from 195 to about 140 lines (~36% fewer tokens) by removing rules and anti-pattern lists repeated in `references/` and the audit script. Description shortened from 392 to 280 characters.
- Audit script searches the tree once instead of 13 times, caps output at 5 matches per category, sorts results, and prints paths relative to the scanned folder. On a 9,000-file test tree: 4.3 s with `grep`, 1.4 s with `rg`, 5.8 KB of output instead of several MB.
- Audit script exits `2` if the search tool fails, instead of reporting a clean result.
- Fewer false positives: device dimensions need number boundaries (`1390` no longer matches `390`), fixed frames are flagged only at 300 pt and up (`maxWidth` caps are ignored), and inset checks skip common spacing values like 48.
- Totals count flagged lines once, even when a line matches several categories.
- The reference cites the Markdown source of the HIG article and lists all three tech talks.
- README installs only through `npx skills add`.

### Removed
- `install.sh` and the `curl | bash` / manual `git clone` install instructions.
