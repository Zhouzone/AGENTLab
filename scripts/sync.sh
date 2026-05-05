#!/usr/bin/env bash
set -euo pipefail

# AGENTLab — Daily sync: pull latest changes and re-install skills
# Usage: bash scripts/sync.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CODEX_HOME="$HOME/.codex"
CLAUDE_HOME="$HOME/.claude"
AGENTS_HOME="$HOME/.agents"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== AGENTLab Sync ===${NC}"
echo ""

# --- Step 1: Git pull ---
echo -e "${GREEN}[1/3]${NC} Pulling latest changes..."
cd "$REPO_DIR"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git pull --rebase 2>&1 | sed 's/^/  /'
else
    echo -e "  ${YELLOW}Not a git repo yet. Skipping git pull.${NC}"
fi

# --- Step 2: Re-sync skills ---
echo ""
echo -e "${GREEN}[2/3]${NC} Syncing skills..."

SKILLS_DIR="$REPO_DIR/lab/skills"
SYNCED=0

# Codex
if [ -d "$CODEX_HOME/skills" ]; then
    for skill_dir in "$SKILLS_DIR"/*/; do
        skill_name="$(basename "$skill_dir")"
        target="$CODEX_HOME/skills/$skill_name"
        if [ -L "$target" ]; then
            rm "$target"
            ln -s "$skill_dir" "$target"
        elif [ ! -d "$target" ]; then
            ln -s "$skill_dir" "$target"
        fi
        SYNCED=$((SYNCED + 1))
    done
    echo "  Codex: $SYNCED skills synced"
fi

# Claude Code
SYNCED=0
if [ -d "$CLAUDE_HOME" ]; then
    mkdir -p "$AGENTS_HOME/skills" "$CLAUDE_HOME/skills"
    for skill_dir in "$SKILLS_DIR"/*/; do
        skill_name="$(basename "$skill_dir")"
        agents_target="$AGENTS_HOME/skills/$skill_name"
        claude_target="$CLAUDE_HOME/skills/$skill_name"

        # Update ~/.agents/skills/ symlink
        [ -L "$agents_target" ] && rm "$agents_target"
        [ ! -d "$agents_target" ] && ln -s "$skill_dir" "$agents_target"

        # Update ~/.claude/skills/ symlink
        [ -L "$claude_target" ] && rm "$claude_target"
        [ ! -d "$claude_target" ] && ln -s "$agents_target" "$claude_target"

        SYNCED=$((SYNCED + 1))
    done
    echo "  Claude Code: $SYNCED skills synced"
fi

# --- Step 3: Re-sync INSTRUCTIONS.md ---
echo ""
echo -e "${GREEN}[3/3]${NC} Syncing lab instructions..."

if [ -d "$CODEX_HOME" ]; then
    cp "$REPO_DIR/lab/INSTRUCTIONS.md" "$CODEX_HOME/AGENTS.md"
    echo "  Updated: ~/.codex/AGENTS.md"
fi

if [ -d "$CLAUDE_HOME" ]; then
    cp "$REPO_DIR/lab/INSTRUCTIONS.md" "$CLAUDE_HOME/CLAUDE.md"
    echo "  Updated: ~/.claude/CLAUDE.md"
fi

echo ""
echo -e "${GREEN}Sync complete!${NC}"
