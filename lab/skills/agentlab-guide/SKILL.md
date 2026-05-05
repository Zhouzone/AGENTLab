---
name: agentlab-guide
description: Manage the AGENTLab repository — create/update member profiles, projects, progress logs, skills, and instructions. Use when the user asks about AGENTLab conventions, wants to add/update projects or members, write PROGRESS.md entries, manage skills across Codex and Claude Code, or needs guidance on how the lab's shared context system works.
---

# AGENTLab Management Guide

AGENTLab is a shared context repository for a research lab using both **OpenAI Codex** and **Claude Code**. This skill teaches you the conventions and workflows for managing it.

## GOAL.md — The Project North Star

Every project has a `GOAL.md` at `projects/<name>/GOAL.md`. It defines the project's mission, research questions, principles, milestones, and current priority. **All project work should align with its GOAL.md.**

As an agent, you MUST:
1. **Read GOAL.md** before helping with decisions on a specific project
2. **Check alignment** — if user's work doesn't advance any milestone, flag it
3. **Reference current priority** — when the user asks "what should I do next", consult GOAL.md + PROGRESS.md
4. **Never modify** Mission or Principles without project lead approval
5. **Current Priority** and milestone status can be updated by the project lead

## Core Principle: Progressive Disclosure

AGENTLab follows the same progressive disclosure pattern used by both tools:

- **GOAL.md** (project level) → each project's north star, read for strategic decisions
- **INSTRUCTIONS.md** (lab level) → installed as `AGENTS.md` (Codex) + `CLAUDE.md` (Claude Code)
- **PROJECT.md** → loaded when working on that project
- **ME.md** → loaded when context about a person is needed
- **SKILL.md** → loaded only when the skill is triggered

Keep each file concise. If a file exceeds 200 lines, split into references.

## File Conventions

### Dual-Tool Compatibility

AGENTLab serves two tools with different conventions:

| Aspect | Codex (AGENTS.md) | Claude Code (CLAUDE.md) |
|--------|-------------------|------------------------|
| Instructions file | `AGENTS.md` | `CLAUDE.md` |
| Discovery | Reads nearest in directory tree | Layered: org → user → project → subdir |
| Skills | `~/.codex/skills/` | `~/.claude/skills/` via `~/.agents/skills/` |
| Config | `config.toml` (TOML) | `settings.json` (JSON) |
| Agent metadata | `agents/openai.yaml` | Not needed (ignored) |
| Import syntax | Not supported | `@path/to/file.md` |
| Size limit | 32 KiB combined | ~200 lines recommended, 300 max |

### Writing INSTRUCTIONS.md (Shared)

Since INSTRUCTIONS.md becomes **both** AGENTS.md and CLAUDE.md, follow the intersection of best practices:

1. **Lead with commands, not explanations** (AGENTS.md best practice)
2. **Stay under 200 lines** (CLAUDE.md best practice)
3. **Use plain markdown only** — no `@import`, no tool-specific syntax
4. **Structure**: project overview → coding standards → commands → team context
5. **Point to references** for details: "See `projects/<name>/PROJECT.md` for architecture"

### Writing ME.md

For member profiles, see [references/me-guide.md](references/me-guide.md).

### Writing PROJECT.md + PROGRESS.md

For project documentation, see [references/project-guide.md](references/project-guide.md).

### Writing SKILL.md

For creating new skills, see [references/skill-guide.md](references/skill-guide.md).

## Two-Level Architecture

AGENTLab 只分两层：**Lab 级别**（Git 共享）和**个人级别**（本地不上传）。

```
Lab 级别 (Git)          个人级别 (Local Only)
─────────────────       ────────────────────
lab/                    members/*/ME.private.md
projects/               ~/.config/team-ai-config/
members/*/ME.md         API keys, auth tokens
members/*/settings/     个人笔记和 TODO
members/*/journal/
members/*/skills/
```

### 成员清单

`lab/MEMBERS.md` 记录所有成员的角色（Admin / Member / Intern）和职责。Agent 通过此文件了解每个人能做什么。

### What goes where

| Content | Level | In Git? |
|---------|-------|---------|
| Coding standards (lab/INSTRUCTIONS.md) | Lab | Yes |
| Shared skills (lab/skills/) | Lab | Yes |
| MCP server configs (lab/mcp/) | Lab | Yes |
| Projects (projects/*/GOAL+PROJECT+PROGRESS) | Lab | Yes |
| Member profile (members/*/ME.md) | Lab | Yes |
| Member settings (members/*/settings/) | Lab | Yes |
| Member journal (members/*/journal/) | Lab | Yes |
| Member skills (members/*/skills/) | Lab | Yes |
| Private preferences (ME.private.md) | **Personal** | **No** |
| API keys / auth tokens | **Personal** | **No** |

## Git 协作模式

- **共享仓库 + Branch Protection**，不用 Fork
- 所有成员作为 Collaborator 加入同一个 repo
- 提交通过 branch → PR → review → merge
- 日常小更新（journal、progress）经 Admin 允许后可直接 push main

## Agent Behaviors — How to Respond to User Requests

When the user talks to you about AGENTLab-related tasks, you (the agent) should perform the file operations directly. The user does NOT manually edit files — you do it through the conversation.

### Locating the AGENTLab Repo

First, find the AGENTLab repo. Check in order:
1. `~/AGENTLab/`
2. `~/Desktop/project/AGENTLab/`
3. Any path containing `AGENTLab/lab/skills/agentlab-guide/` (e.g., cluster paths)
4. Read `~/.agentlab/identity` — if it exists, the repo was set up on this device; search parent directories of the identity file's creation context

### User says: "I just joined, what do I do?" / "我刚加入，怎么开始"

**Step 1: 个人配置**
1. Confirm they have clone access (should be added as Collaborator already)
2. Guide them: `bash scripts/setup.sh <name>` → installs skills + creates directories
3. Help them fill in `ME.md`（尤其是 Sharing 段落：能提供什么帮助）
4. Create branch, commit ME.md, push, create PR

**Step 2: 项目引导**
1. Read `lab/MEMBERS.md` → tell them their assigned projects
2. For each assigned project, summarize in order:
   - GOAL.md → 项目目的和当前优先级
   - PROGRESS.md (latest entry) → 目前进展和下一步
   - 负责人的 ME.md Sharing → 可以找谁对接什么
3. 告知：有问题随时问，Agent 会帮你读取上下文

### User says: "Tell me about project X" / "给我介绍下这个项目"

1. Read `projects/<project>/GOAL.md` → 目的、原则、里程碑
2. Read `projects/<project>/PROJECT.md` → 技术架构
3. Read `projects/<project>/PROGRESS.md` (latest 2-3 entries) → 近期进展
4. Read `lab/MEMBERS.md` → 谁负责这个项目
5. Read those members' `ME.md` Sharing → 找谁对接什么
6. Synthesize a briefing for the user

### User says: "Record my experiment results" / "更新下项目进度"

1. Ask which project (or infer from context)
2. Read the current `projects/<project>/PROGRESS.md`
3. Prepend a new entry at the TOP with today's date:

```markdown
## [YYYY-MM-DD] <title summarizing what happened>

**Author:** <name> (e.g., Zhiwang Zhou)
**Tags:** `experiment`

### What happened
<summarize what the user described>

### Key findings / decisions
<extract the key takeaway>

### Next steps
<ask the user, or infer from context>

### References
<link to relevant commits, papers, files>
```

4. Write the file, then `git add` + `git commit` + `git push`

### User says: "Today I worked on..." / "写一下今天的日志"

1. Create `members/<name>/journal/YYYY-MM-DD.md` using the journal template
2. Fill in the content based on what the user said
3. `git add` + `git commit` + `git push`

### User says: "Add a new project" / "新建一个项目"

1. Ask for project name and brief description (or infer)
2. Create `projects/<project-name>/GOAL.md` from the template — define mission, research questions, milestones
3. Create `projects/<project-name>/PROJECT.md` from the template — technical details, team, architecture
4. Create `projects/<project-name>/PROGRESS.md` from the template
7. Fill in what you know from the conversation
8. `git add` + `git commit` + `git push`

### User says: "Create a skill for..." / "帮我写一个 skill"

1. Ask: lab-wide or personal?
2. Run `bash scripts/add-skill.sh <name> --lab` or `--personal`
3. Write the SKILL.md content based on the user's description
4. Optionally create `agents/openai.yaml` for Codex UI metadata
5. Optionally create `references/` files if content > 500 lines
6. `git add` + `git commit` + `git push`

### User says: "What's everyone working on?" / "大家最近在做什么"

Delegate to the `lab-status` skill — read ME.md, PROGRESS.md, and journal files to synthesize an answer.

### User says: "Add cluster info" / "把集群信息加上去"

1. Read `lab/INSTRUCTIONS.md`
2. Append a `## Cluster` section with the info the user provides (SSH, paths, GPU, environment setup)
3. Keep INSTRUCTIONS.md under 200 lines — if it's getting long, create `lab/references/cluster-guide.md` and link to it
4. `git commit` + `git push`

### User says: "Update my profile" / "更新一下我的信息"

1. Read the current `members/<name>/ME.md`
2. Update the relevant fields based on what the user said
3. `git commit` + `git push`
4. If the change is private (preferences, model config), update `ME.private.md` instead (local only, do NOT push)

### User says: "I have a new idea for project X" / "我有个新想法"

1. Read `projects/<project>/GOAL.md`
2. Evaluate alignment:
   - Advances a milestone → encourage, update PROGRESS.md
   - Partially fits → discuss how to scope it
   - Doesn't fit → flag it honestly, ask if they want to revise the GOAL
3. If it's a brand new project, create `projects/<name>/` with GOAL.md, PROJECT.md, PROGRESS.md

### User says: "What should I work on next?" / "我接下来该做什么"

1. Read the user's `ME.md` → understand their expertise and current projects
2. Read `GOAL.md` of their active projects → check Current Priority and milestone status
3. Read `PROGRESS.md` → find the latest "Next steps"
4. Synthesize a recommendation that aligns project priorities with the user's context

### User says: "Update the project goals" / "更新下项目目标"

1. Read current `projects/<project>/GOAL.md`
2. Only update **Current Priority** and milestone status unless the user explicitly asks to change Mission/Principles
3. `git commit` + `git push`
4. Notify: "GOAL.md updated — teammates will see this on next sync"

### Git Conventions

**Commit message format:** `Update <target>: <brief description>`
- e.g., `Update my-project progress: first experiment results`
- e.g., `Add alice journal entry for 2026-05-05`

**必须提交（Lab 级别）:**
- `members/<name>/ME.md` — 公开画像（含 Sharing）
- `members/<name>/journal/` — 研究日志
- `members/<name>/skills/` — 想共享的 skills
- `projects/*/PROGRESS.md` — 进度更新
- `lab/MEMBERS.md` — 成员变更（Admin 操作）

**绝对不提交（个人级别）:**
- `ME.private.md` — 私有偏好
- API keys / auth tokens
- `.obsidian/workspace.json` — 个人 UI 状态
- 未整理的草稿

**可选提交（成员自行决定）:**
- 个人 skills（不想共享就不放）
- settings/（不含敏感信息就放）

**操作规范:**
- Stage only the changed files (never `git add .`)
- Push immediately so teammates can sync
- **NEVER commit ME.private.md** — always `git status` check first
- 新成员首次提交通过 PR，日常更新经 Admin 允许后可直接 push

### User says: "I want to share something with the team" / "我想共享一些东西"

1. 确认内容类型：
   - **Skill** → 放入 `members/<name>/skills/<skill-name>/SKILL.md`，标准化格式
   - **项目文档/笔记** → 放入对应 `projects/<project>/` 或 journal
   - **对接信息** → 更新 ME.md 的 Sharing 段落
2. 确认不含敏感信息
3. `git add` + `git commit` + `git push`
4. 如果是 skill 想提升为 lab-wide：PR + Admin review

## Quality Checklist

Before committing changes to AGENTLab:

- [ ] INSTRUCTIONS.md is under 200 lines
- [ ] SKILL.md body is under 500 lines (split into references if larger)
- [ ] ME.md has all required fields filled（含 Sharing 段落）
- [ ] PROGRESS.md entries have date, author, tags
- [ ] No API keys, auth tokens, or passwords in any committed file
- [ ] ME.private.md is NOT staged (`git status` check)
- [ ] Skills work for both Codex and Claude Code (test with both if possible)
