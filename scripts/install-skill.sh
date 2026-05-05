#!/usr/bin/env bash
set -euo pipefail

# AGENTLab — Install a skill from any location in the repo
# Usage:
#   bash scripts/install-skill.sh lab/skills/paper-notes          # install a lab skill
#   bash scripts/install-skill.sh members/alice/skills/my-skill   # install someone's personal skill

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CODEX_HOME="$HOME/.codex"
CLAUDE_HOME="$HOME/.claude"
AGENTS_HOME="$HOME/.agents"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SKILL_PATH="${1:-}"

if [ -z "$SKILL_PATH" ]; then
    echo "Usage: bash scripts/install-skill.sh <path-to-skill>"
    echo ""
    echo "Examples:"
    echo "  bash scripts/install-skill.sh lab/skills/paper-notes"
    echo "  bash scripts/install-skill.sh members/alice/skills/my-skill"
    exit 1
fi

FULL_PATH="$REPO_DIR/$SKILL_PATH"

if [ ! -d "$FULL_PATH" ]; then
    echo -e "${RED}Error: Skill directory not found: $SKILL_PATH${NC}"
    exit 1
fi

if [ ! -f "$FULL_PATH/SKILL.md" ]; then
    echo -e "${RED}Error: No SKILL.md found in $SKILL_PATH${NC}"
    exit 1
fi

SKILL_NAME="$(basename "$FULL_PATH")"

echo -e "Installing skill: ${GREEN}$SKILL_NAME${NC} from $SKILL_PATH"

# Install for Codex
if [ -d "$CODEX_HOME/skills" ]; then
    target="$CODEX_HOME/skills/$SKILL_NAME"
    [ -L "$target" ] && rm "$target"
    if [ ! -d "$target" ]; then
        ln -s "$FULL_PATH" "$target"
        echo -e "  ${GREEN}Codex:${NC} linked"
    else
        echo -e "  ${YELLOW}Codex:${NC} exists (manual install, skipping)"
    fi
fi

# Install for Claude Code
if [ -d "$CLAUDE_HOME" ]; then
    mkdir -p "$AGENTS_HOME/skills" "$CLAUDE_HOME/skills"
    agents_target="$AGENTS_HOME/skills/$SKILL_NAME"
    claude_target="$CLAUDE_HOME/skills/$SKILL_NAME"

    [ -L "$agents_target" ] && rm "$agents_target"
    [ ! -d "$agents_target" ] && ln -s "$FULL_PATH" "$agents_target"

    [ -L "$claude_target" ] && rm "$claude_target"
    [ ! -d "$claude_target" ] && ln -s "$agents_target" "$claude_target"

    echo -e "  ${GREEN}Claude Code:${NC} linked"
fi

echo -e "${GREEN}Done!${NC}"
