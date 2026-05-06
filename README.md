# AGENTLab

A lightweight framework for research lab groups to share AI agent context across **Claude Code** and **OpenAI Codex CLI**.

AGENTLab solves four problems that existing tools don't address together:

1. **Why does this project exist?** — `GOAL.md` per project defines mission, milestones, and current priority
2. **Who are you?** — `ME.md` personal profiles let AI agents understand each team member
3. **Where is the project?** — `PROJECT.md` + `PROGRESS.md` track research progress as shared agent context
4. **How do we work?** — Shared skills, instructions, and config defaults across Codex & Claude Code

```
               AGENTLab
       ┌──────────┼──────────┐
    members/    projects/     lab/
       │           │           │
    ME.md       GOAL.md    INSTRUCTIONS.md
  (profiles)  (why we do)  (how we work)
       │           │           │
  ME.private.md PROJECT.md   skills/
  (local only) (what we do) (shared tools)
       │           │           │
    journal/   PROGRESS.md  MEMBERS.md
  (daily log) (who did what) (team roster)

  ── Lab Level: Git shared ──    ── Personal Level: Local ──
  ME.md, projects/, lab/         ME.private.md, API keys
```

## Quick Start

### 1. Create your team's repo from this template

```bash
# Clone this template
git clone https://github.com/YOUR-ORG/AGENTLab.git my-lab
cd my-lab

# Remove example data, start fresh
rm -rf members/example-member projects/example-project
rm -rf .git && git init

# Push to your team's repo
git remote add origin <your-team-repo-url>
git add -A && git commit -m "Initialize AGENTLab"
git push -u origin main
```

### 2. Team members join

```bash
# Clone your team's repo (any path works)
git clone <your-team-repo-url> ~/AGENTLab

# Run setup (installs skills + sets identity)
cd ~/AGENTLab && bash scripts/setup.sh <your-name>
```

Setup installs all lab skills to your AI tool:
- Claude Code → `~/.claude/skills/`
- Codex CLI → `~/.codex/skills/`

### 3. Use it

**Recommended: Talk to your AI Agent** (skills auto-activate after setup)

```
You: Record today's experiment results     → Agent writes PROGRESS.md + commit + push
You: Sync latest progress                  → Agent runs git pull + shows updates
You: What's the status of project X?       → Agent reads GOAL.md + PROGRESS.md
You: What's everyone working on?           → Agent reads MEMBERS.md + journals
```

**Alternative: CLI scripts** (for environments without AI tools)

```bash
bash scripts/update.sh pull      # Before work: pull latest
bash scripts/update.sh log       # After work: log progress → commit → push
bash scripts/update.sh status    # Anytime: check project status
```

## Multi-Device Sync

AGENTLab works across laptops, clusters, and any device with Git access.

```
Laptop (full setup.sh)
   ↕ git push/pull
 GitHub (your team's repo)
   ↕ git push/pull
Cluster A (init only)          Cluster B (init only)
```

```bash
# On a new device (cluster, second laptop, etc.)
git clone <your-team-repo-url> /path/to/AGENTLab

# If the device has Claude Code or Codex — full setup:
bash scripts/setup.sh <your-name>

# If no AI tools — lightweight identity only:
bash scripts/update.sh init <your-name>
```

Each device stores identity at `~/.agentlab/identity`. Scripts auto-detect who you are.

---

## Directory Structure

```
AGENTLab/
├── members/                          # Team member profiles
│   └── <name>/
│       ├── ME.md                     # Public: expertise, projects, sharing info
│       ├── ME.private.md             # Local only (.gitignored)
│       ├── skills/                   # Personal skills (visible, not auto-installed)
│       ├── settings/                 # Shareable tool config (no secrets)
│       └── journal/                  # Research journal
│
├── projects/                         # Research projects
│   └── <project-name>/
│       ├── GOAL.md                   # North star: mission, milestones, priority
│       ├── PROJECT.md                # Technical: architecture, team, resources
│       └── PROGRESS.md              # Progress log: who did what, decisions
│
├── lab/                              # Lab-wide shared config
│   ├── INSTRUCTIONS.md               # Shared agent instructions → AGENTS.md / CLAUDE.md
│   ├── MEMBERS.md                    # Team roster: roles, responsibilities, expertise
│   ├── skills/                       # Shared skills (auto-installed for everyone)
│   │   ├── agentlab-setup/           # Install & sync skill
│   │   └── agentlab-guide/           # Project management conventions
│   └── mcp/                          # Shared MCP server configs
│
├── scripts/
│   ├── setup.sh                      # One-time setup for new members
│   ├── update.sh                     # Daily workflow: pull/log/status/push
│   ├── sync.sh                       # Re-sync skills to local tools
│   ├── add-skill.sh                  # Create a new skill
│   └── install-skill.sh              # Install someone's personal skill
│
└── templates/                        # Templates for new content
    ├── ME.md.template
    ├── GOAL.md.template
    ├── PROJECT.md.template
    ├── PROGRESS.md.template
    └── ...
```

## Registering Existing Projects

Most research projects already have their own code repo and data location. AGENTLab doesn't replace them — it acts as a **command center** that tracks direction, progress, and team context, while code and data stay where they are.

```
AGENTLab (this repo)                External (where work actually happens)
────────────────────                ──────────────────────────────────────
projects/eeg-emotion/               github.com/org/EEG-Ablation     ← code
  GOAL.md     (why we do this)      /data/shared/eeg-raw/            ← data
  PROJECT.md  (where & how)         cluster GPU jobs                 ← experiments
  PROGRESS.md (what happened)
```

**To register an existing project**, just tell your AI agent:

```
I have a project called eeg-emotion.
Code is at github.com/org/EEG-Ablation, data is on cluster at /data/shared/eeg/.
Goal is EEG emotion recognition ablation study. Baseline is done.
```

The agent will create `projects/eeg-emotion/` with GOAL.md, PROJECT.md, and PROGRESS.md. The `PROJECT.md` will reference your external code and data locations:

```markdown
## Key Resources
- Code: https://github.com/org/EEG-Ablation
- Data: cluster `/data/shared/eeg/`
- Paper: [link]

## Agent Instructions
- Code lives in the above GitHub repo, not in this repository
- Experiments run on cluster, results are logged to PROGRESS.md here
- Framework: PyTorch 2.x, main model: EEGNet
```

After that, recording progress works from anywhere:

```
You: eeg-emotion — ablation without temporal attention dropped accuracy from 85% to 78%
→ Agent updates projects/eeg-emotion/PROGRESS.md, commits, and pushes
```

## Two-Level Architecture

| Level | What | In Git? | Examples |
|-------|------|---------|----------|
| **Lab** | Everything shared | Yes | ME.md, GOAL.md, PROGRESS.md, skills/, journal/ |
| **Personal** | Private preferences | No | ME.private.md, API keys, auth tokens |

## Git Collaboration

- **Shared repo + Branch Protection** (not Fork)
- All members added as **Collaborators**
- `main` branch requires 1 approval via PR
- Daily updates (journal, progress) can push directly after Admin approval

## Commit Rules

| Category | What | Rule |
|----------|------|------|
| **Must commit** | ME.md, journal/, PROGRESS.md, shared skills | Always push to keep team synced |
| **Never commit** | ME.private.md, API keys, `.obsidian/workspace.json` | .gitignore protects these |
| **Optional** | Personal skills, settings/ | Your choice — share if it helps others |

Commit message format: `Update <target>: <brief description>`

## Skills Compatibility

Skills use the same `SKILL.md` format for both tools:

```
skill-name/
├── SKILL.md              # Universal — both Codex and Claude Code
├── agents/
│   └── openai.yaml       # Optional: Codex UI metadata (ignored by Claude Code)
└── references/           # Optional: supporting docs
```

## Onboarding Flow

### For Admins

1. Add new member as **Collaborator** on GitHub
2. Add them to `lab/MEMBERS.md` (name, role, projects, expertise)
3. Review their ME.md PR

### For New Members

1. Clone → `setup.sh` → Fill ME.md (including **Sharing** section) → PR
2. Read assigned projects: GOAL.md → PROJECT.md → PROGRESS.md
3. Check `lab/MEMBERS.md` for who to contact about what

## ME.md Sharing Section

Each member's ME.md includes a `## Sharing` section describing:
- What expertise they can offer
- What documentation/resources they maintain
- What topics they're available to discuss

This helps teammates (and AI agents) know who to ask for help.

## Inspired By

- [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — LLM-maintained knowledge base
- [skillshare](https://github.com/runkids/skillshare) — Cross-tool skill sync
- [colleague-skill](https://github.com/titanwings/colleague-skill) — Digital profiles for teammates
- [Squad](https://github.blog/ai-and-ml/github-copilot/how-squad-runs-coordinated-ai-agents-inside-your-repository/) — Charter + decisions.md pattern
- [claude-code-dotfiles](https://github.com/elizabethfuentes12/claude-code-dotfiles) — Dotfiles-as-code for AI tools

## License

MIT
