# Changelog

All notable changes to this skill are listed here. Versions follow [Semantic Versioning](https://semver.org).

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
