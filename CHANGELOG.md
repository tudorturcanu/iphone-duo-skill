# Changelog

All notable changes to this skill are listed here. Versions follow [Semantic Versioning](https://semver.org).

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
