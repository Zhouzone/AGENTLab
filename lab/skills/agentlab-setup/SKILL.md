---
name: agentlab-setup
description: Install, update, and manage AGENTLab — a shared context framework for research labs using Claude Code and Codex CLI. Use when the user wants to set up AGENTLab on a new device, sync updates, initialize their identity, or manage their AGENTLab installation. Works as a standalone skill that bootstraps the full framework.
---

# AGENTLab Setup & Sync

> This skill can be installed standalone. Once installed, it bootstraps the full AGENTLab framework through conversation.

## What is AGENTLab?

A Git-based shared context framework for research labs using Claude Code and Codex CLI. It manages:
- Team member profiles and expertise
- Research project goals, progress, and documentation
- Shared skills and agent instructions
- Multi-device sync (laptop, clusters, etc.)

Repository: Your team's Git repo (created from this template)

## Installation

```bash
# Clone AGENTLab 到任意目录，然后运行 setup
git clone <your-team-repo-url> <your-path>
cd <your-path> && bash scripts/setup.sh <your-name>
```

setup.sh 会自动将所有 lab skills（包括本 skill）symlink 到 `~/.claude/skills/` 和 `~/.codex/skills/`。

更新时：
```bash
cd <your-path> && bash scripts/sync.sh
```

## Agent Behaviors

### User says: "Set up AGENTLab" / "安装 AGENTLab" / "初始化 AGENTLab"

This is the **first-time setup on a new device** (laptop or cluster).

1. Ask for install path (default: `~/AGENTLab`), or detect if already cloned:
   ```bash
   # Check common locations
   for path in ~/AGENTLab ~/Desktop/project/AGENTLab /mnt/*/project/AGENTLab; do
     [ -d "$path/lab/skills/agentlab-guide" ] && echo "Found: $path"
   done
   ```

2. If not found, clone:
   ```bash
   git clone <your-team-repo-url> <install-path>
   ```

3. Ask for member name (or detect from `~/.agentlab/identity`):
   ```bash
   cat ~/.agentlab/identity 2>/dev/null || echo "not set"
   ```

4. Run setup:
   ```bash
   cd <install-path> && bash scripts/setup.sh <name>
   ```
   This will:
   - Create `members/<name>/` directory
   - Install all lab skills to `~/.claude/skills/` (or `~/.codex/skills/`)
   - Set local identity at `~/.agentlab/identity`
   - Install INSTRUCTIONS.md as CLAUDE.md / AGENTS.md

5. Confirm success and show next steps:
   - Fill in `members/<name>/ME.md` (including Sharing section)
   - Create branch → commit → PR

### User says: "Sync AGENTLab" / "同步一下" / "update"

This is the **daily sync** — pull latest + re-install skills.

1. Locate AGENTLab repo:
   ```bash
   # Find repo path
   for path in ~/AGENTLab ~/Desktop/project/AGENTLab; do
     [ -d "$path/.git" ] && echo "$path" && break
   done
   # Or search more broadly
   find ~ /mnt -maxdepth 4 -name "agentlab-guide" -path "*/lab/skills/*" 2>/dev/null | head -1
   ```

2. Run sync:
   ```bash
   cd <repo-path> && bash scripts/sync.sh
   ```
   This will: `git pull --rebase` → re-symlink all skills → update INSTRUCTIONS.md

3. Show what changed:
   ```bash
   cd <repo-path> && git log --oneline --since="24 hours ago"
   ```

### User says: "Record progress" / "记录进度" / "log"

1. Locate repo and run:
   ```bash
   cd <repo-path> && bash scripts/update.sh log
   ```
   Or do it conversationally (preferred):
   - Ask what they worked on
   - Read current PROGRESS.md
   - Prepend new entry with date, author, tags
   - `git add` + `git commit` + `git push`

### User says: "Check status" / "看看最近进展"

```bash
cd <repo-path> && bash scripts/update.sh status
```

### User says: "Set up on cluster" / "在集群上配置"

For cluster setup (no GUI, might not have Claude Code):

1. If Claude Code IS available on cluster:
   ```bash
   # Full setup (same as laptop)
   cd <cluster-path>/AGENTLab && bash scripts/setup.sh <name>
   ```

2. If Claude Code is NOT available:
   ```bash
   # Lightweight — just clone + set identity
   git clone <your-team-repo-url> <path>
   bash <path>/scripts/update.sh init <name>
   # Then use update.sh for daily operations
   ```

### User says: "Update this skill" / "更新 skill"

Self-update: pull latest version of this skill from the AGENTLab repo:
```bash
REPO_PATH="<detected-repo-path>"
cp -r "$REPO_PATH/lab/skills/agentlab-setup/" ~/.claude/skills/agentlab-setup/
echo "Updated agentlab-setup skill from repo"
```

## Compatibility

| Tool | Skill Location | Install Method |
|------|---------------|----------------|
| Claude Code | `~/.claude/skills/agentlab-setup/` | Clone/copy this directory |
| Codex CLI | `~/.codex/skills/agentlab-setup/` | Clone/copy this directory |

This skill works identically on both tools. No format conversion needed.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `git clone` fails (SSH) | Try HTTPS URL instead of SSH |
| Skills not detected | Check symlinks: `ls -la ~/.claude/skills/` |
| Identity not set | Run: `bash scripts/update.sh init <name>` |
| Permission denied on cluster | Check if `~/.claude/` is writable; try `--personal` path |
