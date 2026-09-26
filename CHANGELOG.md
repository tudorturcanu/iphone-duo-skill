# Changelog

All notable changes to this skill are listed here. Versions follow [Semantic Versioning](https://semver.org).

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
