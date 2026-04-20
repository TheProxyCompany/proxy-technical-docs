# Integrations

Proxy connects to external tools and services through a **tri-modal integration system** — three transport types unified under one interface.

## Transport Types

### 1. MCP Servers

Persistent connections using the Model Context Protocol. Proxy discovers tools automatically via the MCP protocol handshake.

```
Proxy ←→ MCP Server (stdio or HTTP/SSE)
         ↓
    Tool discovery
    Tool execution
    Resource access
```

Examples: GitHub, Slack, Proxy's own MCP server, custom MCP servers.

### 2. CLI Tools

Subprocess invocation with structured JSON output. Proxy calls the tool as a child process and parses the result.

Examples: `gh` (GitHub CLI), `gws` (Google Workspace CLI), `aws`.

### 3. Direct HTTP APIs

REST calls with stored credentials. Proxy makes HTTP requests directly to external APIs.

Examples: OpenRouter, Stripe, custom webhooks.

## Managing Integrations

Integrations are managed through the Proxy CLI or the Attic (settings) UI:

```bash
# List connected integrations
proxy integration list --connected

# Add a new integration
proxy integration add my-server

# Connect via stdio
proxy integration connect stdio my-server '{"command":"node","args":["server.js","--stdio"]}'

# Connect via HTTP
proxy integration connect http my-server '{"url":"http://localhost:3000/mcp"}'

# See available tools
proxy integration tools my-server

# Import from Claude Desktop config
proxy integration import
```

## Harnesses

Harnesses are a special class of integration for **agent runtimes** — external programs that can participate in Party sessions as full agents.

| Harness | Transport | What it is |
|---------|-----------|-----------|
| **Claude Code** | Process (stdin/stdout JSONL) | Anthropic's CLI agent |
| **Codex** | WebSocket | OpenAI's coding agent |
| **OpenClaw** | WebSocket | Open-source agent runtime |

Harnesses differ from regular integrations because they're bidirectional — Proxy sends prompts to the harness, and the harness sends tool calls and responses back.

```bash
# List available harnesses
proxy harness list

# Connect a harness
proxy harness connect claude-code

# Configure
proxy harness set-path claude-code /usr/local/bin/claude

# Check status
proxy harness status
```

## Loadouts

A **loadout** is a saved configuration of integrations and skills for an agent. Each agent can have multiple loadouts that define what tools and MCP servers are available to them.

```bash
# List loadouts
proxy loadout list

# Equip an integration to a loadout
proxy loadout integration equip <loadout_id> <integration_id>

# Equip a skill
proxy loadout skill equip <loadout_id> <skill_id>
```

## Proxy MCP Server

Proxy itself runs an MCP server on `localhost:51711` when the app is open. This lets external tools interact with Proxy:

- Read and write the Life Map
- Manage agents and teams
- Send messages to Party sessions
- Take screenshots
- Navigate the UI

Any MCP client can connect. This is how Claude Code and other tools integrate with Proxy for AI-assisted development.
