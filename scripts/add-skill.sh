#!/usr/bin/env bash
set -euo pipefail

# AGENTLab — Add a new skill to the repo
# Usage:
#   bash scripts/add-skill.sh my-skill --lab           # add to lab/skills/ (shared with everyone)
#   bash scripts/add-skill.sh my-skill --personal      # add to members/<you>/skills/ (personal)
#   bash scripts/add-skill.sh my-skill --member alice   # add to a specific member's skills/

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SKILL_NAME="${1:-}"
LAYER="${2:---personal}"
MEMBER_NAME="${3:-}"

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: bash scripts/add-skill.sh <skill-name> [--lab|--personal|--member <name>]"
    echo ""
    echo "Options:"
    echo "  --lab              Add to lab/skills/ (shared, auto-installed for everyone)"
    echo "  --personal         Add to your members/<name>/skills/ (visible, not auto-installed)"
    echo "  --member <name>    Add to a specific member's skills/"
    exit 1
fi

case "$LAYER" in
    --lab)
        TARGET_DIR="$REPO_DIR/lab/skills/$SKILL_NAME"
        LAYER_NAME="lab"
        ;;
    --personal)
        # Auto-detect current member by checking which member dirs exist
        # and matching against the system username
        WHOAMI="$(whoami)"
        if [ -d "$REPO_DIR/members/$WHOAMI" ]; then
            MEMBER_NAME="$WHOAMI"
        else
            # Try to find a matching member directory
            read -p "Your member name (directory in members/): " MEMBER_NAME
        fi
        TARGET_DIR="$REPO_DIR/members/$MEMBER_NAME/skills/$SKILL_NAME"
        LAYER_NAME="personal ($MEMBER_NAME)"
        ;;
    --member)
        if [ -z "$MEMBER_NAME" ]; then
            echo "Error: --member requires a name"
            exit 1
        fi
        TARGET_DIR="$REPO_DIR/members/$MEMBER_NAME/skills/$SKILL_NAME"
        LAYER_NAME="member ($MEMBER_NAME)"
        ;;
    *)
        echo "Unknown option: $LAYER"
        exit 1
        ;;
esac

if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Skill already exists: $TARGET_DIR${NC}"
    exit 1
fi

# Scaffold the skill
mkdir -p "$TARGET_DIR"

cat > "$TARGET_DIR/SKILL.md" << 'SKILL_EOF'
---
name: SKILL_NAME_PLACEHOLDER
description: TODO — describe what this skill does
---

# SKILL_NAME_PLACEHOLDER

## When to Use

<!-- Describe when this skill should be activated -->

## Instructions

<!-- Agent instructions for this skill -->
SKILL_EOF

# Replace placeholder with actual name
sed -i '' "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$TARGET_DIR/SKILL.md" 2>/dev/null || \
sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$TARGET_DIR/SKILL.md"

echo -e "${GREEN}Created skill scaffold:${NC}"
echo "  $TARGET_DIR/"
echo "  └── SKILL.md"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Edit $TARGET_DIR/SKILL.md"

if [ "$LAYER" = "--lab" ]; then
    echo "  2. git add $TARGET_DIR && git commit -m 'Add $SKILL_NAME skill to lab'"
    echo "  3. git push (teammates run: bash scripts/sync.sh)"
    echo ""
    echo -e "  ${YELLOW}Note: Lab skills are auto-installed for all members on sync.${NC}"
else
    echo "  2. git add $TARGET_DIR && git commit -m 'Add $SKILL_NAME personal skill'"
    echo "  3. git push"
    echo "  4. To install locally: bash scripts/install-skill.sh ${TARGET_DIR#$REPO_DIR/}"
    echo ""
    echo -e "  ${YELLOW}To promote to lab-wide: move to lab/skills/ via PR.${NC}"
fi
