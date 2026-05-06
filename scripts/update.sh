#!/usr/bin/env bash
set -euo pipefail

# AGENTLab — Daily update script (works on laptop, cluster, any device)
# Usage:
#   bash scripts/update.sh pull      # Before work: pull latest + show changes
#   bash scripts/update.sh log       # After work: record progress → commit → push
#   bash scripts/update.sh status    # Anytime: check project status
#   bash scripts/update.sh push      # Push unpushed local commits
#   bash scripts/update.sh init      # First time: set identity on this device

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
IDENTITY_FILE="$HOME/.agentlab/identity"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# --- Identity ---
get_identity() {
    if [ -f "$IDENTITY_FILE" ]; then
        cat "$IDENTITY_FILE"
    else
        echo ""
    fi
}

ensure_identity() {
    local name
    name="$(get_identity)"
    if [ -z "$name" ]; then
        echo -e "${YELLOW}No identity set on this device.${NC}"
        echo "Run: bash scripts/update.sh init"
        exit 1
    fi
    echo "$name"
}

# --- Commands ---

cmd_init() {
    echo -e "${BLUE}=== AGENTLab Identity Setup ===${NC}"
    echo ""
    echo "This links your identity to this device (laptop, cluster, etc.)."
    echo "Your identity = your members/ directory name."
    echo ""

    # List existing members
    echo "Existing members:"
    for dir in "$REPO_DIR"/members/*/; do
        [ -d "$dir" ] && echo "  - $(basename "$dir")"
    done
    echo ""

    if [ -n "${1:-}" ]; then
        local name="$1"
    else
        read -p "Enter your member name: " name
    fi

    # Validate
    if [ ! -d "$REPO_DIR/members/$name" ]; then
        echo -e "${RED}Error: members/$name does not exist.${NC}"
        echo "Ask Admin to run setup.sh for you first, or create your directory."
        exit 1
    fi

    # Write identity
    mkdir -p "$HOME/.agentlab"
    echo "$name" > "$IDENTITY_FILE"
    echo ""
    echo -e "${GREEN}Identity set: $name${NC}"
    echo "Stored at: $IDENTITY_FILE"
    echo ""
    echo "Device: $(hostname)"
    echo "Git user: $(git config user.name 2>/dev/null || echo 'not set')"
    echo ""
    echo "You can now use: update.sh pull / log / status / push"
}

cmd_pull() {
    echo -e "${BLUE}=== AGENTLab Pull ===${NC}"
    cd "$REPO_DIR"

    # Check for local uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}Warning: You have uncommitted changes:${NC}"
        git status --short | sed 's/^/  /'
        echo ""
        echo "Stashing changes before pull..."
        git stash
        STASHED=true
    else
        STASHED=false
    fi

    # Pull with rebase to keep history clean
    echo ""
    echo "Pulling latest..."
    if git pull --rebase 2>&1 | sed 's/^/  /'; then
        echo ""
    else
        echo -e "${RED}Pull failed. Possible conflict.${NC}"
        echo "Run: git status to see the issue, then resolve manually."
        exit 1
    fi

    # Restore stash
    if $STASHED; then
        echo "Restoring your local changes..."
        git stash pop || echo -e "${YELLOW}Stash pop conflict — resolve manually.${NC}"
    fi

    # Show recent changes (last 24h or last 5 commits, whichever is fewer)
    echo -e "${GREEN}Recent updates:${NC}"
    git log --oneline --since="24 hours ago" | head -10 | sed 's/^/  /'
    RECENT=$(git log --oneline --since="24 hours ago" | wc -l | tr -d ' ')
    if [ "$RECENT" = "0" ]; then
        git log --oneline -3 | sed 's/^/  /'
        echo "  (no changes in the last 24h, showing last 3 commits)"
    fi
    echo ""
}

cmd_status() {
    local name
    name="$(ensure_identity)"

    echo -e "${BLUE}=== AGENTLab Status ===${NC}"
    echo "Identity: $name | Device: $(hostname)"
    echo ""

    # Show projects this member is part of
    echo -e "${GREEN}Your projects:${NC}"
    if [ -f "$REPO_DIR/lab/MEMBERS.md" ]; then
        grep -i "$name" "$REPO_DIR/lab/MEMBERS.md" | sed 's/^/  /' || echo "  (not found in MEMBERS.md)"
    fi
    echo ""

    # Show latest progress for each project
    echo -e "${GREEN}Latest progress:${NC}"
    for progress_file in "$REPO_DIR"/projects/*/PROGRESS.md; do
        [ -f "$progress_file" ] || continue
        project="$(basename "$(dirname "$progress_file")")"
        # Get the first ## entry (latest)
        latest=$(grep -m1 "^## \[" "$progress_file" 2>/dev/null || echo "(empty)")
        echo "  $project: $latest"
    done
    echo ""

    # Show unpushed commits
    local unpushed
    unpushed=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    if [ "$unpushed" != "0" ]; then
        echo -e "${YELLOW}Unpushed commits: $unpushed${NC}"
        git log --oneline @{u}..HEAD | sed 's/^/  /'
    fi
}

cmd_log() {
    local name
    name="$(ensure_identity)"

    echo -e "${BLUE}=== AGENTLab Progress Log ===${NC}"
    echo "Identity: $name | Device: $(hostname)"
    echo ""

    # Ask for project
    echo "Projects available:"
    local i=0
    declare -a projects=()
    for dir in "$REPO_DIR"/projects/*/; do
        [ -d "$dir" ] || continue
        project="$(basename "$dir")"
        projects+=("$project")
        i=$((i + 1))
        echo "  $i) $project"
    done
    echo ""

    if [ -n "${1:-}" ]; then
        local project="$1"
    else
        read -p "Which project? (name or number): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#projects[@]}" ]; then
            project="${projects[$((choice - 1))]}"
        else
            project="$choice"
        fi
    fi

    local progress_file="$REPO_DIR/projects/$project/PROGRESS.md"
    if [ ! -f "$progress_file" ]; then
        echo -e "${RED}Error: projects/$project/PROGRESS.md not found.${NC}"
        exit 1
    fi

    # Collect entry info
    echo ""
    read -p "Title (what happened, one sentence): " title
    echo ""
    echo "Tags: experiment, decision, finding, blocker, milestone"
    read -p "Tag: " tag
    echo ""
    echo "Describe what happened (end with empty line):"
    local body=""
    while IFS= read -r line; do
        [ -z "$line" ] && break
        body="${body}${line}\n"
    done
    echo ""
    read -p "Key finding or decision (optional, press Enter to skip): " finding
    echo ""
    read -p "Next steps (optional, press Enter to skip): " nextsteps

    # Build entry
    local date_str
    date_str="$(date +%Y-%m-%d)"
    local entry="## [$date_str] $title

**Author:** $name
**Tags:** \`$tag\`

### What happened
$(echo -e "$body")
"

    if [ -n "$finding" ]; then
        entry="${entry}
### Key findings / decisions
$finding
"
    fi

    if [ -n "$nextsteps" ]; then
        entry="${entry}
### Next steps
$nextsteps
"
    fi

    entry="${entry}---

"

    # Prepend to PROGRESS.md (after the header)
    local header
    header=$(head -4 "$progress_file")
    local rest
    rest=$(tail -n +5 "$progress_file")

    echo "$header" > "$progress_file"
    echo "" >> "$progress_file"
    echo "$entry" >> "$progress_file"
    echo "$rest" >> "$progress_file"

    echo -e "${GREEN}Entry added to projects/$project/PROGRESS.md${NC}"
    echo ""

    # Auto commit + push
    read -p "Commit and push now? [Y/n]: " confirm
    confirm="${confirm:-Y}"
    if [[ "$confirm" =~ ^[Yy] ]]; then
        cd "$REPO_DIR"
        git add "projects/$project/PROGRESS.md"
        git commit -m "Update $project progress: $title"
        git push
        echo -e "${GREEN}Pushed successfully.${NC}"
    else
        echo "Not pushed. Run 'bash scripts/update.sh push' when ready."
    fi
}

cmd_push() {
    echo -e "${BLUE}=== AGENTLab Push ===${NC}"
    cd "$REPO_DIR"

    # Check for staged/unstaged changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "Uncommitted changes:"
        git status --short | sed 's/^/  /'
        echo ""

        # Safety check: never commit ME.private.md
        if git status --porcelain | grep -q "ME.private.md"; then
            echo -e "${RED}ERROR: ME.private.md is staged! Removing from staging...${NC}"
            git reset HEAD -- "**/ME.private.md" 2>/dev/null || true
        fi

        read -p "Stage and commit these changes? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy] ]]; then
            read -p "Commit message: " msg
            git add -A
            # Double check: unstage ME.private.md
            git reset HEAD -- "**/ME.private.md" 2>/dev/null || true
            git commit -m "$msg"
        else
            echo "Skipping commit."
        fi
    fi

    # Push
    local unpushed
    unpushed=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    if [ "$unpushed" != "0" ]; then
        echo "Pushing $unpushed commit(s)..."
        git push
        echo -e "${GREEN}Done.${NC}"
    else
        echo "Nothing to push."
    fi
}

# --- Main ---
case "${1:-help}" in
    init)
        cmd_init "${2:-}"
        ;;
    pull)
        cmd_pull
        ;;
    status)
        cmd_status
        ;;
    log)
        cmd_log "${2:-}"
        ;;
    push)
        cmd_push
        ;;
    help|*)
        echo "AGENTLab Update — Daily workflow for any device"
        echo ""
        echo "Usage: bash scripts/update.sh <command>"
        echo ""
        echo "Commands:"
        echo "  init [name]   First-time: set your identity on this device"
        echo "  pull          Before work: pull latest + show changes"
        echo "  log [project] After work: record progress → commit → push"
        echo "  status        Check project progress and your unpushed commits"
        echo "  push          Push uncommitted changes (with safety checks)"
        echo ""
        echo "Typical daily flow:"
        echo "  1. bash scripts/update.sh pull     # Before starting work"
        echo "  2. (do your work...)"
        echo "  3. bash scripts/update.sh log      # After work: record progress"
        echo ""
        echo "Identity: $(get_identity || echo 'not set') @ $(hostname)"
        ;;
esac
