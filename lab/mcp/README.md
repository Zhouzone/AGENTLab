# Lab MCP Servers

Shared MCP (Model Context Protocol) server configurations for the lab.

## How to Use

1. Browse the configs below to find servers useful for your workflow
2. Copy the relevant config into your local tool settings:
   - **Codex**: Add to `~/.codex/config.toml` under `[mcp]`
   - **Claude Code**: Add to `~/.claude/settings.json` under `"mcpServers"`

## Important

- Config files here contain **server addresses and setup instructions only**
- **Auth tokens and API keys are NEVER stored here** — set them locally via environment variables
- If a server requires auth, the config will reference `$ENV_VAR_NAME` placeholders
