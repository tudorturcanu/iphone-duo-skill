#!/usr/bin/env bash
# audit_duo_readiness.sh - Scan an iOS codebase for iPhone Duo layout anti-patterns.
#
# Usage: audit_duo_readiness.sh [path] [-q|--quiet]
#   path      Directory to scan (default: current directory)
#   -q        Only print categories with matches and the summary
#
# Exit codes: 0 = clean, 1 = anti-patterns found, 2 = bad arguments
#
# Every match is a *candidate*. Read the surrounding code before changing it:
# a fixed width on an icon is fine, a fixed width on a container is not.

set -euo pipefail

TARGET_DIR="."
QUIET=0

for arg in "$@"; do
    case "$arg" in
        -q|--quiet) QUIET=1 ;;
        -h|--help)
            sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        -*) echo "Unknown option: $arg" >&2; exit 2 ;;
        *)  TARGET_DIR="$arg" ;;
    esac
done

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a directory" >&2
    exit 2
fi

# Directories that are never app code.
EXCLUDES=(Pods Carthage .build DerivedData node_modules .git .swiftpm '*.xcodeproj' '*.xcworkspace')

echo "========================================================"
echo "🔍 iPhone Duo Readiness Audit: Scanning '$TARGET_DIR'"
echo "========================================================"

ISSUES_FOUND=0
MATCH_TOTAL=0

search() {
    local pattern="$1"
    if command -v rg >/dev/null 2>&1; then
        local args=(-n --glob '*.swift')
        for e in "${EXCLUDES[@]}"; do args+=(--glob "!$e"); done
        rg "${args[@]}" -e "$pattern" "$TARGET_DIR" || true
    else
        local args=(-rn --include='*.swift')
        for e in "${EXCLUDES[@]}"; do args+=(--exclude-dir="$e"); done
        grep "${args[@]}" -E "$pattern" "$TARGET_DIR" || true
    fi
}

scan_pattern() {
    local title="$1" pattern="$2" desc="$3"
    local matches
    matches=$(search "$pattern")

    if [ -n "$matches" ]; then
        local count
        count=$(printf '%s\n' "$matches" | wc -l | tr -d ' ')
        echo ""
        echo "▶ $title  ($count)"
        echo "  $desc"
        printf '%s\n' "$matches" | sed 's/^/     /'
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        MATCH_TOTAL=$((MATCH_TOTAL + count))
    elif [ "$QUIET" -eq 0 ]; then
        echo ""
        echo "▶ $title"
        echo "  ✅ Clean"
    fi
}

# --- Display-specific sizing --------------------------------------------------

scan_pattern \
    "UIScreen.main.bounds usage" \
    "UIScreen\.main\.bounds" \
    "Screen bounds tie layout to one display. Use safe-area insets, layout margins, or GeometryReader."

scan_pattern \
    "Hard-coded iPhone frame dimensions" \
    "CGRect\(.*(390|844|375|812|414|896|428|926|430|932|393|852|402|874)" \
    "Fixed device sizes break on Duo's outer/inner aspect ratios. Use Auto Layout or safe areas."

scan_pattern \
    "Fixed width/height on SwiftUI frames (review: containers bad, icons fine)" \
    "\.frame\((width|height|minWidth|maxWidth):\s*[0-9]{3,}" \
    "Three-digit fixed dimensions usually mean a container sized for one display."

scan_pattern \
    "Device idiom checks used for layout" \
    "userInterfaceIdiom\s*==\s*\.(phone|pad)" \
    "On the Duo inner display an iPhone has a regular width class. Branch on size class, not idiom."

# --- Safe areas & reserved regions -------------------------------------------

scan_pattern \
    "Blanket safe-area ignoring" \
    "\.(ignoresSafeArea|edgesIgnoringSafeArea)\((\.all)?\)" \
    "Content can slide under side bars, the camera region, or the fold. Ignore only specific edges, and only for backgrounds."

scan_pattern \
    "Hard-coded Dynamic Island / notch padding" \
    "(\.padding\(\.(top|bottom|vertical),\s*(44|47|48|54|59)\)|(padding|inset|top)[A-Za-z]*\s*[:=]\s*(44|47|48|54|59)\b)" \
    "Magic-number status-bar padding is wrong on both Duo displays. Use safeAreaInsets."

# --- Bars, toolbars, overflow -------------------------------------------------

scan_pattern \
    "Manual toolbar fixed spaces" \
    "(barButtonSystemItem:\s*\.fixedSpace|barButtonSystemItem:\s*\.flexibleSpace|Spacer\(\)\.frame\(width:|UIBarButtonItem\.fixedSpace\()" \
    "Fixed spacers block the system from packing and overflowing side toolbars. Use ToolbarItemGroup / UIBarButtonItemGroup."

scan_pattern \
    "Custom ellipsis overflow menus" \
    "systemName:\s*\"ellipsis(\.circle)?\"" \
    "Custom '…' menus compete with the system overflow. Move actions to ToolbarOverflowMenu / additionalOverflowItems."

scan_pattern \
    "Hidden system tab bar (often paired with a homemade one)" \
    "(tabBar\.isHidden\s*=\s*true|\.toolbar\(\.hidden,\s*for:\s*\.tabBar\)|UITabBar\.appearance\(\)\.isHidden)" \
    "A custom tab bar won't move to the side or minimize. Prefer TabView / UITabBarController."

scan_pattern \
    "Symbol-only toolbar buttons (no title for overflow)" \
    "UIBarButtonItem\(image:[^,]+,\s*style:" \
    "Items need both a title and an image; the title appears in the overflow menu. Use init(title:image:primaryAction:menu:)."

scan_pattern \
    "Deprecated NavigationView (no split-view behavior)" \
    "\bNavigationView\s*\{" \
    "NavigationView doesn't expand to two columns on the inner display. Use NavigationSplitView or NavigationStack."

# --- The fold -----------------------------------------------------------------

scan_pattern \
    "Odd fixed grid column counts" \
    "(Array\(repeating:\s*[^,]+,\s*count:\s*[3579]\)|columns:\s*\[\s*(GridItem\([^)]*\),?\s*){3}\s*\])" \
    "Odd column counts put an item on the fold. Use an even count or adaptive columns."

scan_pattern \
    "Orientation lock (games: must still fill every pose)" \
    "supportedInterfaceOrientations" \
    "Locking is allowed, but the game must fill the screen in every pose. Avoid bare letterboxing."

echo ""
echo "========================================================"
if [ "$ISSUES_FOUND" -gt 0 ]; then
    echo "⚠️  $MATCH_TOTAL candidate(s) in $ISSUES_FOUND categor$( [ "$ISSUES_FOUND" -eq 1 ] && echo y || echo ies )."
    echo "   Review each in context. Remediation patterns are in SKILL.md."
    exit 1
else
    echo "🎉 No common iPhone Duo layout anti-patterns detected."
    echo "   Still walk the verification checklist in SKILL.md; the fold and side bars need a visual check."
    exit 0
fi
