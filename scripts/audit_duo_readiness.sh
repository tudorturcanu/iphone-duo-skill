#!/usr/bin/env bash
# audit_duo_readiness.sh - Scan iOS codebase for iPhone Duo layout anti-patterns

set -euo pipefail

TARGET_DIR="${1:-.}"

echo "========================================================"
echo "🔍 iPhone Duo Readiness Audit: Scanning '$TARGET_DIR'"
echo "========================================================"

ISSUES_FOUND=0

scan_pattern() {
    local title="$1"
    local pattern="$2"
    local desc="$3"

    echo ""
    echo "▶ Checking: $title"
    echo "  $desc"

    # Use ripgrep if available, otherwise grep
    local matches=""
    if command -v rg >/dev/null 2>&1; then
        matches=$(rg -n --glob '*.swift' "$pattern" "$TARGET_DIR" || true)
    else
        matches=$(grep -rn --include="*.swift" -E "$pattern" "$TARGET_DIR" || true)
    fi

    if [ -n "$matches" ]; then
        echo "  ❌ Found potential issues:"
        echo "$matches" | sed 's/^/     /'
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo "  ✅ Clean"
    fi
}

# 1. Screen bounds and fixed widths
scan_pattern \
    "UIScreen.main.bounds usage" \
    "UIScreen\.main\.bounds" \
    "Using UIScreen bounds breaks across Duo's compact outer and regular inner displays."

scan_pattern \
    "Hard-coded device frame dimensions" \
    "CGRect\(.*(390|844|375|812|414|896|428|926|430|932)" \
    "Hard-coded iPhone dimensions break on Duo's unique display aspect ratios."

# 2. Device idiom checks
scan_pattern \
    "Device idiom checks" \
    "userInterfaceIdiom\s*==\s*\.(phone|pad)" \
    "Idiom checks assume .phone is always compact. On Duo inner display, width is regular."

# 3. Ignored safe areas
scan_pattern \
    "Overly broad safe area ignoring" \
    "\.(ignoresSafeArea|edgesIgnoringSafeArea)\(\)" \
    "Content may collide with side toolbars, camera reserved regions, or the fold."

# 4. Manual toolbar spacing
scan_pattern \
    "Manual toolbar fixed spaces" \
    "(barButtonSystemItem:\s*\.fixedSpace|Spacer\(\)\.frame\(width:)" \
    "Fixed spacers prevent system from dynamically packing/overflowing side toolbars."

# 5. Homemade ellipsis overflow menus
scan_pattern \
    "Custom ellipsis overflow menus" \
    "systemName:\s*\"ellipsis\"" \
    "Custom ellipsis buttons conflict with Duo's native system overflow menu."

# 6. Odd grid column counts
scan_pattern \
    "Odd fixed grid column counts" \
    "Array\(repeating:\s*[^,]+,\s*count:\s*[357]\)" \
    "Odd column grids split items directly down the center folding region."

echo ""
echo "========================================================"
if [ "$ISSUES_FOUND" -gt 0 ]; then
    echo "⚠️  Audit completed with $ISSUES_FOUND anti-pattern category match(es)."
    echo "   Refer to SKILL.md for remediation patterns."
    exit 1
else
    echo "🎉 Audit passed! No common iPhone Duo layout anti-patterns detected."
    exit 0
fi
