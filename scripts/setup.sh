#!/usr/bin/env bash
set -euo pipefail

# AGENTLab — First-time setup for new members
# Usage: bash scripts/setup.sh [your-name]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CODEX_HOME="$HOME/.codex"
CLAUDE_HOME="$HOME/.claude"
AGENTS_HOME="$HOME/.agents"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== AGENTLab Setup ===${NC}"
echo ""

# --- Step 1: Get member name ---
if [ -n "${1:-}" ]; then
    MEMBER_NAME="$1"
else
    read -p "Enter your name (used for members/ directory, e.g., alice): " MEMBER_NAME
fi

if [ -z "$MEMBER_NAME" ]; then
    echo "Error: Name cannot be empty."
    exit 1
fi

MEMBER_DIR="$REPO_DIR/members/$MEMBER_NAME"

# --- Step 2: Create member directory structure ---
echo -e "${GREEN}[1/6]${NC} Creating member directory..."
mkdir -p "$MEMBER_DIR"/{skills,settings,journal}

if [ ! -f "$MEMBER_DIR/ME.md" ]; then
    cp "$REPO_DIR/templates/ME.md.template" "$MEMBER_DIR/ME.md"
    echo "  Created: members/$MEMBER_NAME/ME.md (please fill in your profile)"
else
    echo "  Exists:  members/$MEMBER_NAME/ME.md (skipping)"
fi

if [ ! -f "$MEMBER_DIR/ME.private.md" ]; then
    cp "$REPO_DIR/templates/ME.private.md.template" "$MEMBER_DIR/ME.private.md"
    echo "  Created: members/$MEMBER_NAME/ME.private.md (local only, never uploaded)"
else
    echo "  Exists:  members/$MEMBER_NAME/ME.private.md (skipping)"
fi

if [ ! -f "$MEMBER_DIR/settings/codex.toml" ]; then
    cp "$REPO_DIR/templates/settings-codex.toml.template" "$MEMBER_DIR/settings/codex.toml"
    echo "  Created: members/$MEMBER_NAME/settings/codex.toml"
fi

if [ ! -f "$MEMBER_DIR/settings/claude.json" ]; then
    cp "$REPO_DIR/templates/settings-claude.json.template" "$MEMBER_DIR/settings/claude.json"
    echo "  Created: members/$MEMBER_NAME/settings/claude.json"
fi

# --- Step 3: Detect AI tools ---
echo ""
echo -e "${GREEN}[2/6]${NC} Detecting AI tools..."

HAS_CODEX=false
HAS_CLAUDE=false

if [ -d "$CODEX_HOME" ]; then
    HAS_CODEX=true
    echo "  Found: Codex CLI ($CODEX_HOME)"
fi

if [ -d "$CLAUDE_HOME" ]; then
    HAS_CLAUDE=true
    echo "  Found: Claude Code ($CLAUDE_HOME)"
fi

if ! $HAS_CODEX && ! $HAS_CLAUDE; then
    echo -e "${YELLOW}  Warning: Neither Codex nor Claude Code found. Skills will not be installed.${NC}"
    echo "  You can run this script again after installing your AI tool."
fi

# --- Step 4: Install skills ---
echo ""
echo -e "${GREEN}[3/6]${NC} Installing shared skills..."

SKILLS_DIR="$REPO_DIR/lab/skills"

if $HAS_CODEX; then
    echo "  Installing skills for Codex..."
    for skill_dir in "$SKILLS_DIR"/*/; do
        skill_name="$(basename "$skill_dir")"
        target="$CODEX_HOME/skills/$skill_name"
        if [ -L "$target" ]; then
            rm "$target"
        fi
        if [ ! -d "$target" ]; then
            ln -s "$skill_dir" "$target"
            echo "    Linked: $skill_name -> Codex"
        else
            echo "    Exists: $skill_name (manual install detected, skipping)"
        fi
    done
fi

if $HAS_CLAUDE; then
    echo "  Installing skills for Claude Code..."
    mkdir -p "$AGENTS_HOME/skills"
    for skill_dir in "$SKILLS_DIR"/*/; do
        skill_name="$(basename "$skill_dir")"
        agents_target="$AGENTS_HOME/skills/$skill_name"
        claude_target="$CLAUDE_HOME/skills/$skill_name"

        # Link to ~/.agents/skills/
        if [ -L "$agents_target" ]; then
            rm "$agents_target"
        fi
        if [ ! -d "$agents_target" ]; then
            ln -s "$skill_dir" "$agents_target"
        fi

        # Link from ~/.claude/skills/ to ~/.agents/skills/
        mkdir -p "$CLAUDE_HOME/skills"
        if [ -L "$claude_target" ]; then
            rm "$claude_target"
        fi
        if [ ! -d "$claude_target" ]; then
            ln -s "$agents_target" "$claude_target"
            echo "    Linked: $skill_name -> Claude Code"
        else
            echo "    Exists: $skill_name (manual install detected, skipping)"
        fi
    done
fi

# --- Step 5: Install INSTRUCTIONS.md ---
echo ""
echo -e "${GREEN}[4/6]${NC} Installing lab instructions..."

if $HAS_CODEX; then
    cp "$REPO_DIR/lab/INSTRUCTIONS.md" "$CODEX_HOME/AGENTS.md"
    echo "  Installed: AGENTS.md -> Codex"
fi

if $HAS_CLAUDE; then
    cp "$REPO_DIR/lab/INSTRUCTIONS.md" "$CLAUDE_HOME/CLAUDE.md"
    echo "  Installed: CLAUDE.md -> Claude Code"
fi

# --- Step 6: Show MCP server recommendations ---
echo ""
echo -e "${GREEN}[5/6]${NC} MCP server recommendations..."
if [ -f "$REPO_DIR/lab/mcp/servers.json" ]; then
    echo "  Lab-wide MCP configs available at: lab/mcp/servers.json"
    echo "  Browse and add relevant servers to your local config."
fi

# --- Step 6: Set local identity ---
echo ""
echo -e "${GREEN}[6/7]${NC} Setting local identity..."
mkdir -p "$HOME/.agentlab"
echo "$MEMBER_NAME" > "$HOME/.agentlab/identity"
echo "  Identity: $MEMBER_NAME @ $(hostname)"
echo "  Stored at: ~/.agentlab/identity"

# --- Done ---
echo ""
echo -e "${GREEN}[7/7]${NC} Setup complete!"
echo ""
echo -e "${BLUE}Your directory:${NC}"
echo "  members/$MEMBER_NAME/"
echo "  ├── ME.md              (public profile — fill this in!)"
echo "  ├── ME.private.md      (local only — personal preferences)"
echo "  ├── skills/            (your personal skills)"
echo "  ├── settings/          (your shareable config)"
echo "  └── journal/           (your research journal)"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Edit ${YELLOW}members/$MEMBER_NAME/ME.md${NC} — fill in your profile (include Sharing section!)"
echo "  2. Edit ${YELLOW}members/$MEMBER_NAME/ME.private.md${NC} — personal preferences (local only)"
echo "  3. Commit and push (via PR for first time):"
echo "     git checkout -b $MEMBER_NAME/init"
echo "     git add members/$MEMBER_NAME/ME.md members/$MEMBER_NAME/settings/"
echo "     git commit -m \"Add $MEMBER_NAME profile\""
echo "     git push -u origin $MEMBER_NAME/init"
echo "     # Then create PR on GitHub"
echo ""
echo -e "${BLUE}Daily workflow:${NC}"
echo "  bash scripts/update.sh pull     # Before work: pull latest"
echo "  bash scripts/update.sh log      # After work: record progress"
echo "  bash scripts/update.sh status   # Anytime: check status"
echo ""
echo -e "${BLUE}On another device (cluster etc.):${NC}"
echo "  git clone <repo-url> ~/AGENTLab"
echo "  bash scripts/update.sh init $MEMBER_NAME    # Set identity"
echo "  # No need to run setup.sh again — just init identity"
