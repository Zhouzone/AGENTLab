# ME.md Writing Guide

## Purpose

ME.md is read by AI agents to understand who the user is. It serves two audiences:
1. **AI agents** — adapts responses to the person's expertise and preferences
2. **Teammates** — quick reference for who does what

## Required Fields

These must be filled (enforced via PR review):

| Field | Why it matters |
|-------|---------------|
| Name | Identity |
| Research Area | Agent knows what domain you work in |
| Current Projects | Links to projects/ — agent can cross-reference |
| AI Tool | Codex / Claude Code / Both — affects skill loading |

## Optional but Valuable Fields

| Field | Impact |
|-------|--------|
| Expertise & Skills | Agent adjusts technical depth |
| Working Style | "Prefer concise responses" changes agent behavior |
| Publications | Agent can reference your papers |
| Links | Google Scholar, GitHub, etc. |

## Writing Tips

1. **Be specific about expertise**: "PyTorch distributed training with DeepSpeed" > "ML"
2. **Link to projects**: Use relative paths `../../projects/<name>/`
3. **State preferences explicitly**: "Respond in Traditional Chinese" or "Explain architecture decisions in detail"
4. **Update regularly**: When you switch projects, update Current Projects

## ME.md vs ME.private.md

| | ME.md | ME.private.md |
|---|-------|--------------|
| In Git | Yes | No |
| Visible to team | Yes | No |
| Read by teammates' agents | Yes | No |
| Contains API keys | Never | OK |
| Contains model preferences | General ("I use Codex") | Specific (model = "gpt-5.5") |

## Example

```markdown
# Alice Chen

## Research Area
NLP, Retrieval-Augmented Generation, Scientific Document Understanding

## Current Projects
- [my-project](../../projects/my-project/) — Your role and focus area

## AI Tool
- [x] Claude Code
- Primary model: Opus 4.6, effort: high

## Expertise & Skills
- Python, PyTorch, HuggingFace Transformers
- RAG systems, vector databases (FAISS, Qdrant)
- Scientific paper parsing (GROBID, S2ORC)

## Working Style
- Prefer detailed explanations for architecture decisions
- Use English for code comments, Chinese for discussions
```
