#!/usr/bin/env bash
# audit_duo_readiness.sh - Scan an iOS codebase for iPhone Duo layout anti-patterns.
# Read-only: searches Swift, Info.plist, and project files and prints matches. Never modifies your files; no network.
#
# Usage: audit_duo_readiness.sh [path] [-s|--summary] [-q|--quiet] [-n|--max N]
#   path          Directory to scan (default: current directory)
#   -s            Counts per category only (run this first)
#   -q            Hide clean categories
#   -n N          Matches shown per category (default 5, 0 = all)
#
# Exit codes: 0 = clean, 1 = anti-patterns found, 2 = bad arguments, nothing to scan, or search error
# AUDIT_NO_RG=1 forces the grep fallback.
#
# Every match is a candidate. Read the surrounding code before changing it.

set -euo pipefail

TARGET_DIR="."
QUIET=0
SUMMARY=0
MAX=5

while [ $# -gt 0 ]; do
    case "$1" in
        -q|--quiet)   QUIET=1 ;;
        -s|--summary) SUMMARY=1; QUIET=1 ;;
        -n|--max)
            [ $# -ge 2 ] && [[ "$2" =~ ^[0-9]+$ ]] || { echo "Error: $1 needs a number" >&2; exit 2; }
            MAX="$2"; shift ;;
        -h|--help)    sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)           echo "Unknown option: $1" >&2; exit 2 ;;
        *)            TARGET_DIR="$1" ;;
    esac
    shift
done

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a directory" >&2
    exit 2
fi

N='([^0-9.]|$)'   # end of a number
GRID='GridItem\(([^()]|\([^()]*\))*\)'

# title | regex | fix. One row per category, most severe first. Regexes are POSIX ERE.
# Lines tagged "[...]" at the end come from the context passes below.
CHECKS=(
    "App opts out of resizing|\[UIRequiresFullScreen\]$|Remove UIRequiresFullScreen; the app must resize across displays and Split View."
    "Screen bounds or main screen used|(UIScreen\.main([^A-Za-z]|$)|[Ss]creen\??\.(bounds|nativeBounds))|Size from the view or scene; use traitCollection.displayScale. UIScreen.main is ambiguous with two displays."
    "Hard-coded iPhone dimensions|CG(Rect|Size)\(.*[^0-9.](390|844|375|812|414|896|428|926|430|932|393|852|402|874)$N|Use Auto Layout or safe areas."
    "Large fixed frame (>= 300 pt)|\.frame\([^)]*(^|[^A-Za-z])(width|height|minWidth|minHeight):[[:space:]]*([3-9][0-9]{2}|[1-9][0-9]{3,})$N|Let containers size from available space; maxWidth caps are fine."
    "Device idiom or model checks used for layout|(userInterfaceIdiom[[:space:]]*==[[:space:]]*\.(phone|pad)|utsname|\"iPhone[0-9]+,[0-9]+\")|Branch on size class; the inner display is regular width."
    "Device orientation used for layout|(UIDevice\.current\.orientation|interfaceOrientation\.is(Landscape|Portrait))|Poses and the fold don't map to orientation. Use size classes and available size."
    "Symmetric safe-area assumption|safeAreaInsets\.(left|right|top|bottom)[[:space:]]*\*[[:space:]]*2|Insets differ per side (side bars, cameras). Use bounds.inset(by: safeAreaInsets)."
    "Blanket safe-area ignoring|\.(ignoresSafeArea|edgesIgnoringSafeArea)\(((\.all|\.container)?|((\.all|\.container),[[:space:]]*)?edges:[[:space:]]*\.all)\)|Ignore specific edges, and only for backgrounds."
    "Hard-coded status bar / home indicator insets|(\.padding\(\.(top|vertical),[[:space:]]*(44|47|59)\)|\.padding\(\.bottom,[[:space:]]*34\)|top:[[:space:]]*(47|59)$N|(statusBar|notch|safeArea|topInset|bottomInset)[A-Za-z]*[[:space:]]*[:=][[:space:]]*(20|34|44|47|59)$N)|Use safeAreaInsets."
    "Manual toolbar spacers|(barButtonSystemItem:[[:space:]]*\.(fixedSpace|flexibleSpace)|Spacer\(\)\.frame\(width:|UIBarButtonItem\.(fixedSpace|flexibleSpace)\(|\[inside toolbar\]$)|Use ToolbarItemGroup / UIBarButtonItemGroup."
    "Custom ellipsis overflow menus|(systemName|systemImage):[[:space:]]*\"ellipsis(\.circle)?(\.fill)?\"|Use ToolbarOverflowMenu / additionalOverflowItems."
    "Custom bar instead of a system-managed one|((UIToolbar|UITabBar|UINavigationBar)\((frame:|\))|(class|struct)[[:space:]]+[A-Za-z0-9_]+[[:space:]]*:[[:space:]]*(UIToolbar|UITabBar|UINavigationBar)([^A-Za-z]|$)|(class|struct)[[:space:]]+[A-Za-z0-9_]*(TabBar|Toolbar|NavBar)[[:space:]]*:[[:space:]]*(some[[:space:]]+)?(View|UIView)([^A-Za-z]|$)|(Button|onTapGesture).*\{[[:space:]]*(self\.)?(selected|current|active)[A-Za-z]*(Tab|Index|Page)[A-Za-z]*[[:space:]]*=[^=])|Only container-managed bars move to the side. Use TabView / UITabBarController and .toolbar / navigation-controller items."
    "Hidden system tab bar|(tabBar\??\.isHidden[[:space:]]*=[[:space:]]*true|\.toolbar(Visibility)?\(\.hidden,[[:space:]]*for:[[:space:]]*\.tabBar\)|UITabBar\.appearance\(\)\.isHidden)|Use TabView / UITabBarController."
    "Toolbar item without a title|(UIBarButtonItem\(image:|\[symbol-only toolbar item\]$)|Give every item title + symbol: Label(\"Title\", systemImage:) / UIBarButtonItem(title:image:...)."
    "Several controls in one ToolbarItem|\[stack inside ToolbarItem\]$|A custom view never moves to the side bar. Use ToolbarItemGroup with one item per control."
    "Side bars disabled|(toolbarVerticalBehavior\(\.disabled\)|preferredVerticalBarBehavior)|Only for immersive single-purpose UIs (Calculator, full-screen player). Keep the system's side placement otherwise."
    "Deprecated NavigationView|(^|[^A-Za-z])NavigationView[[:space:]]*\{|Use NavigationSplitView or NavigationStack."
    "Odd fixed grid column counts|((repeating:[[:space:]]*(GridItem|\.init)[^,]*,|NSCollectionLayoutGroup.*)[[:space:]]*count:[[:space:]]*[3579]$N|\[[[:space:]]*($GRID[[:space:]]*,[[:space:]]*){2}($GRID[[:space:]]*,[[:space:]]*){0,2}$GRID[[:space:]]*,?[[:space:]]*\])|Use an even count or adaptive columns."
    "Orientation lock (games must fill every pose)|supportedInterfaceOrientations|Fill the screen in every pose; no bare letterboxing."
)

SWIFT=$(mktemp); EXTRA=$(mktemp); ALL_MATCHES=$(mktemp); CAT=$(mktemp); LIST=$(mktemp); FILES=$(mktemp)
trap 'rm -f "$SWIFT" "$EXTRA" "$ALL_MATCHES" "$CAT" "$LIST" "$FILES"' EXIT

ALL=()
for c in "${CHECKS[@]}"; do
    rest="${c#*|}"; ALL+=("${rest%|*}")
done
COMBINED=$(IFS='|'; echo "${ALL[*]}")

PRUNE=(Pods Carthage .build DerivedData node_modules .git .swiftpm)

# A wrong path must not look like a clean app.
PRUNE_EXPR=()
for d in "${PRUNE[@]}"; do PRUNE_EXPR+=(-name "$d" -o); done
if [ -z "$(find "$TARGET_DIR" \( "${PRUNE_EXPR[@]}" -false \) -prune -o \( -name '*.swift' -o -name project.pbxproj \) -type f -print 2>/dev/null | head -1)" ]; then
    echo "Error: no Swift files or Xcode projects under '$TARGET_DIR'. Pass the app's source folder." >&2
    exit 2
fi
GREP_EXCLUDES=()
for d in "${PRUNE[@]}"; do GREP_EXCLUDES+=(--exclude-dir="$d"); done

# One pass over the Swift files. Also returns toolbar and Spacer() lines so the toolbar pass knows which files to read.
search_swift() {
    if [ -z "${AUDIT_NO_RG:-}" ] && command -v rg >/dev/null 2>&1; then
        local globs=(--glob '*.swift')
        for d in "${PRUNE[@]}"; do globs+=(--glob "!$d"); done
        rg -n --no-heading --color never "${globs[@]}" -e "$COMBINED" -e 'Spacer\(\)|[.]toolbar|ToolbarItem' .
    else
        # Fixed-string prefilter first: a long regex alternation is slow in BSD grep.
        grep -rnF --include='*.swift' "${GREP_EXCLUDES[@]}" --exclude-dir='*.xcodeproj' --exclude-dir='*.xcworkspace' \
             -e creen -e CGRect -e CGSize -e '.frame(' -e userInterfaceIdiom -e utsname -e '"iPhone' -e rientation \
             -e SafeArea -e safeArea -e statusBar -e notch -e Inset -e padding -e 'top:' \
             -e fixedSpace -e flexibleSpace -e 'Spacer()' -e ellipsis -e tabBar -e TabBar -e 'UIBarButtonItem(image:' \
             -e NavigationView -e 'count:' -e GridItem -e oolbar -e Bar -e elected -e urrent -e ctive . \
            | grep -E -- "$COMBINED|Spacer\(\)|[.]toolbar|ToolbarItem"
    fi
}

# Checks that need to know whether a line sits inside a .toolbar { } / ToolbarItem(Group) { } block.
# Brace context, so grep can't do them: stray Spacer()s, symbol-only items, and stacks of controls in one ToolbarItem.
toolbar_context() {
    { grep -E 'Spacer\(\)|[.]toolbar|ToolbarItem' "$SWIFT" || [ $? -eq 1 ]; } | cut -d: -f1 | uniq | tr '\n' '\0' > "$LIST"
    [ -s "$LIST" ] || return 0
    xargs -0 awk '
        function depth_at(s, p,   pre) { pre = substr(s, 1, p - 1); return depth + gsub(/[{]/, "{", pre) - gsub(/[}]/, "}", pre) }
        FNR == 1 { depth = 0; n = 0 }
        {
            line = $0
            if (line ~ /([.]toolbar|ToolbarItem(Group)?)[ \t]*([(][^{]*[)])?[ \t]*[{]/) {
                st[++n] = depth
                ty[n] = (line ~ /ToolbarItem[ \t]*[({]/) ? (line ~ /[.]principal/ ? "principal" : "item") : "bar"
            }
            if (n > 0) {
                principal = 0
                for (i = 1; i <= n; i++) if (ty[i] == "principal") principal = 1
                p = index(line, "Spacer()")
                if (p > 0 && line !~ /Spacer[(][)][.]frame[(]width:/ && depth_at(line, p) == st[n] + 1)
                    print FILENAME ":" FNR ":" $0 "  [inside toolbar]"
                p = index(line, "Image(systemName:")
                if (p > 0 && !principal && line !~ /(Label|Text)[(]/)
                    print FILENAME ":" FNR ":" $0 "  [symbol-only toolbar item]"
                if (match(line, /[HV]Stack[ \t]*[({]/) && ty[n] == "item" && depth_at(line, RSTART) == st[n] + 1)
                    print FILENAME ":" FNR ":" $0 "  [stack inside ToolbarItem]"
            }
            opens = gsub(/[{]/, "{", line); closes = gsub(/[}]/, "}", line); depth += opens - closes
            while (n > 0 && depth <= st[n]) n--
        }' < "$LIST"
}

# UIRequiresFullScreen set to true in an Info.plist or in Xcode build settings.
full_screen_opt_out() {
    find . \( -name Pods -o -name Carthage -o -name .build -o -name DerivedData -o -name node_modules -o -name .git -o -name .swiftpm \) -prune \
        -o \( -name '*.plist' -o -name project.pbxproj \) -type f -print0 > "$FILES" 2>/dev/null || true
    [ -s "$FILES" ] || return 0
    # xargs exits 123 when some grep call found nothing; only higher codes are errors.
    xargs -0 grep -lF --null UIRequiresFullScreen < "$FILES" > "$LIST" || { rc=$?; [ "$rc" -eq 1 ] || [ "$rc" -eq 123 ] || return 2; }
    [ -s "$LIST" ] || return 0
    xargs -0 awk '
        FNR == 1 { key = 0 }
        /INFOPLIST_KEY_UIRequiresFullScreen[ \t]*=[ \t]*YES/ { print FILENAME ":" FNR ": " $0 "  [UIRequiresFullScreen]"; next }
        index($0, "<key>UIRequiresFullScreen</key>") { key = FNR; if (index($0, "<true/>")) print FILENAME ":" FNR ":" $0 "  [UIRequiresFullScreen]"; next }
        key && FNR == key + 1 { if (index($0, "<true/>")) print FILENAME ":" key ": <key>UIRequiresFullScreen</key> <true/>  [UIRequiresFullScreen]"; key = 0 }
    ' < "$LIST"
}

# Exit 1 from rg/grep means "no matches"; anything higher is a real error.
set +e
(
    cd "$TARGET_DIR" || exit 2
    set -o pipefail
    search_swift > "$SWIFT"; rc=$?; [ "$rc" -le 1 ] || exit "$rc"
    toolbar_context || exit 2
    full_screen_opt_out || exit 2
    exit 0
) > "$EXTRA"
rc=$?
set -e
if [ "$rc" -gt 1 ]; then
    echo "Error: search failed (exit $rc)" >&2
    exit 2
fi
{ grep -E -- "$COMBINED" "$SWIFT" || [ $? -eq 1 ]; cat "$EXTRA"; } \
    | sed -E 's#^\./##; s#^([^:]+:[0-9]+:)[[:space:]]*#\1 #' | sort -t: -k1,1 -k2,2n | uniq > "$ALL_MATCHES"

echo "iPhone Duo readiness audit: $TARGET_DIR"

ISSUES_FOUND=0

for c in "${CHECKS[@]}"; do
    title="${c%%|*}"; rest="${c#*|}"; regex="${rest%|*}"; fix="${rest##*|}"
    # One entry per line, even when a tagged copy of it also matches.
    { grep -E -- "$regex" "$ALL_MATCHES" || [ $? -eq 1 ]; } | awk -F: '!seen[$1 FS $2]++' > "$CAT"
    count=$(wc -l < "$CAT" | tr -d ' ')

    if [ "$count" -gt 0 ]; then
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        echo "▶ $title ($count) — $fix"
        if [ "$SUMMARY" -eq 0 ]; then
            if [ "$MAX" -eq 0 ] || [ "$count" -le "$MAX" ]; then
                cut -c1-160 "$CAT" | sed 's/^/    /'
            else
                sed -n "1,${MAX}p" "$CAT" | cut -c1-160 | sed 's/^/    /'
                echo "    … and $((count - MAX)) more (-n 0 shows all)"
            fi
        fi
    elif [ "$QUIET" -eq 0 ]; then
        echo "✓ $title"
    fi
done

if [ "$ISSUES_FOUND" -gt 0 ]; then
    lines=$(cut -d: -f1,2 "$ALL_MATCHES" | uniq | wc -l | tr -d ' ')
    echo "$lines line(s) flagged in $ISSUES_FOUND categor$( [ "$ISSUES_FOUND" -eq 1 ] && echo y || echo ies ). Review each in context."
    exit 1
fi
echo "No common iPhone Duo anti-patterns found. Still walk the verification checklist in SKILL.md."
exit 0
