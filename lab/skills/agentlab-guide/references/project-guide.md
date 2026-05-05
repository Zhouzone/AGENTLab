# PROJECT.md + PROGRESS.md Writing Guide

## PROJECT.md — The Project Brain

This file is the single source of truth for what a project is about. AI agents read this to understand context before helping with project-related tasks.

### Structure

```markdown
# Project: [Name]

## Overview          ← One paragraph: what and why
## Team              ← Who, linked to ME.md
## Goals             ← Checklist of objectives
## Architecture      ← Technical design, key decisions
## Key Resources     ← Links to repos, papers, datasets
## Status            ← planning / active / paused / completed
## Agent Instructions ← Special guidance for AI agents
```

### Tips

1. **Overview**: One paragraph. If you can't explain it in one paragraph, the project scope is unclear.
2. **Team**: Always link to `../../members/<name>/ME.md` so agents can cross-reference.
3. **Goals**: Use checkboxes `- [ ]`. Update as goals are achieved.
4. **Architecture**: Include key technical decisions and constraints (e.g., "model context is 8192 tokens, must split long traces").
5. **Agent Instructions**: Tell the agent what it MUST know to help with this project. Model names, frameworks, conventions.
6. **Status**: Keep this updated. An "active" project that's actually paused wastes agent effort.

## PROGRESS.md — The Project Memory

Chronological log of what happened. Newest entries at top.

### Entry Format

```markdown
## [YYYY-MM-DD] Title

**Author:** Name
**Tags:** `experiment` | `decision` | `finding` | `blocker` | `milestone`

### What happened
### Key findings / decisions
### Next steps
### References
```

### Tag Meanings

| Tag | When to use |
|-----|------------|
| `experiment` | Ran an experiment, got results |
| `decision` | Made a design/architecture choice |
| `finding` | Discovered something unexpected |
| `blocker` | Something is stuck, needs help |
| `milestone` | Major checkpoint reached |

### Tips

1. **Newest first**: Always add at the top, not the bottom.
2. **Be specific in "Key findings"**: "Loss diverged at lr=3e-4 with batch_size=32" > "Training didn't work"
3. **Link references**: Commit hashes, paper URLs, Obsidian notes, experiment IDs.
4. **"Next steps" is a contract**: Your future self and teammates will read this.
5. **Don't repeat PROJECT.md**: PROGRESS.md is about what changed, not what the project is.

## How Agents Use These Files

When someone asks "What's the status of project X?":
1. Agent reads `projects/<project>/PROJECT.md` → understands the project
2. Agent reads top entries of `PROGRESS.md` → knows recent activity
3. Agent cross-references team members' `ME.md` → knows who to ask

When someone asks "Help me with the Judger training":
1. Agent reads `PROJECT.md` → understands architecture and constraints
2. Agent reads `Agent Instructions` section → knows model names, frameworks
3. Agent can give contextually appropriate help
