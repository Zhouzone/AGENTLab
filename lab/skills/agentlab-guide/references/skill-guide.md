# Skill Writing Guide for AGENTLab

## Cross-Tool Compatibility

AGENTLab skills must work with both **Codex** and **Claude Code**. The good news: the core format is identical.

### Universal Structure

```
skill-name/
├── SKILL.md              # Required — works for both tools
├── agents/
│   └── openai.yaml       # Optional — Codex UI metadata (Claude ignores it)
└── references/           # Optional — progressive disclosure files
    ├── guide.md
    └── examples.md
```

### SKILL.md Format

```yaml
---
name: my-skill-name        # lowercase, hyphens, max 64 chars
description: What it does and when to use it. Be specific about triggers.
---

# Skill Title

## When to Use
[Describe activation conditions]

## Instructions
[Main content — under 500 lines]

## References
[Links to files in references/ directory]
```

### agents/openai.yaml (Codex only)

```yaml
interface:
  display_name: "Human-Readable Name"
  short_description: "Short description for Codex UI"
  default_prompt: "Default prompt when skill is invoked"
```

Claude Code ignores this file entirely. Include it for better Codex UX.

## Progressive Disclosure Rules

From Anthropic's official best practices:

1. **SKILL.md body: under 500 lines**
2. **References: one level deep** (SKILL.md → reference.md, never reference.md → another.md)
3. **Add table of contents** to reference files over 100 lines
4. **Claude loads references on demand** — large files have zero cost until read

### Pattern: High-level guide with references

```markdown
# Main Skill

## Quick start
[Essential instructions here]

## Advanced features
See [references/advanced.md](references/advanced.md)

## API reference
See [references/api.md](references/api.md)
```

### Pattern: Domain-specific organization

```
my-skill/
├── SKILL.md (overview + navigation)
└── references/
    ├── domain-a.md
    ├── domain-b.md
    └── domain-c.md
```

## Writing Tips

### From OpenAI (AGENTS.md style)
- Lead with commands, not explanations
- Reference test commands so the agent knows what "done" means
- Place overrides close to specialized work

### From Anthropic (CLAUDE.md style)
- Claude is already smart — only add context it doesn't have
- Be concise: challenge each paragraph's token cost
- Use consistent terminology throughout
- Provide defaults, not multiple options

### Common Mistakes

| Mistake | Fix |
|---------|-----|
| Over-explaining basics | Claude knows Python, Git, ML — skip the intro |
| Too many options | Pick one recommended approach, mention alternatives briefly |
| Deeply nested references | Keep references one level deep from SKILL.md |
| Vague description | Include BOTH what it does AND when to trigger it |
| Time-sensitive content | Use "current method" + "old patterns" sections |
| Windows paths | Always use forward slashes |

## Lab vs Personal Skills

| | Lab skill (`lab/skills/`) | Personal skill (`members/*/skills/`) |
|---|---|---|
| Auto-installed | Yes (via sync.sh) | No (manual install) |
| Reviewed | PR required | Optional |
| Audience | Everyone in lab | Just you (others can browse) |
| Promotion path | N/A | `git mv` to lab/skills/ via PR |
