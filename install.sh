#!/usr/bin/env bash
# install.sh - Install iphone-duo-design skill for Antigravity and Claude Code

set -euo pipefail

REPO_URL="https://github.com/tudorturcanu/iphone-duo-skill.git"
SKILL_NAME="iphone-duo-design"

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --global, -g     Install globally for Antigravity (~/.gemini/config/skills/$SKILL_NAME) [default]"
    echo "  --workspace, -w  Install in current workspace (.agents/skills/$SKILL_NAME)"
    echo "  --claude-global  Install globally for Claude Code (~/.claude/skills/$SKILL_NAME)"
    echo "  --claude-local   Install in current project for Claude Code (.claude/skills/$SKILL_NAME)"
    echo "  --help, -h       Show this help message"
    exit 0
}

TARGET_TYPE="global"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --global|-g)
            TARGET_TYPE="global"
            shift
            ;;
        --workspace|-w)
            TARGET_TYPE="workspace"
            shift
            ;;
        --claude-global)
            TARGET_TYPE="claude-global"
            shift
            ;;
        --claude-local)
            TARGET_TYPE="claude-local"
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

case "$TARGET_TYPE" in
    global)
        DEST="$HOME/.gemini/config/skills/$SKILL_NAME"
        ;;
    workspace)
        DEST="./.agents/skills/$SKILL_NAME"
        ;;
    claude-global)
        DEST="$HOME/.claude/skills/$SKILL_NAME"
        ;;
    claude-local)
        DEST="./.claude/skills/$SKILL_NAME"
        ;;
esac

if [ "$TARGET_TYPE" = "global" ] && [ $# -eq 0 ]; then
    echo "No target given; defaulting to Antigravity global. For Claude Code pass --claude-global or --claude-local."
fi
echo "=========================================================="
echo "📦 Installing '$SKILL_NAME' to:"
echo "   $DEST"
echo "=========================================================="

mkdir -p "$(dirname "$DEST")"

# Install from a local checkout when run from one; otherwise clone.
# BASH_SOURCE is empty when piped (curl ... | bash), so fall back to cloning.
SCRIPT_SRC="${BASH_SOURCE[0]:-}"
SCRIPT_DIR=""
if [ -n "$SCRIPT_SRC" ] && [ -f "$SCRIPT_SRC" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SRC")" && pwd)"
fi
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/SKILL.md" ]; then
    echo "Installing from local source repository..."
    rm -rf "$DEST"
    mkdir -p "$DEST"
    cp -R "$SCRIPT_DIR/SKILL.md" "$SCRIPT_DIR/references" "$SCRIPT_DIR/scripts" "$DEST/"
    if [ -d "$SCRIPT_DIR/evals" ]; then cp -R "$SCRIPT_DIR/evals" "$DEST/"; fi
    if [ -d "$SCRIPT_DIR/fixtures" ]; then cp -R "$SCRIPT_DIR/fixtures" "$DEST/"; fi
else
    echo "Cloning from $REPO_URL..."
    if [ -d "$DEST/.git" ]; then
        echo "Updating existing installation..."
        git -C "$DEST" pull --rebase
    else
        rm -rf "$DEST"
        git clone --depth 1 "$REPO_URL" "$DEST"
    fi
fi

echo "=========================================================="
echo "✅ Successfully installed $SKILL_NAME!"
echo ""
echo "How to use:"
echo "  Start a conversation with your agent and ask:"
echo "  - 'Audit this app for iPhone Duo readiness'"
echo "  - 'Make this SwiftUI view adapt to the Duo hinge and sidebars'"
echo "  - 'Review our UIKit toolbars for iPhone Duo overflow behavior'"
echo "=========================================================="
