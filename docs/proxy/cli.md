# Proxy CLI

`proxy` is a command-line tool that ships with Proxy for controlling a running instance. It talks to Proxy's MCP server over HTTP on `localhost:51711`.

**Proxy must be running** for any CLI command to work. The CLI is a client, not a standalone tool.

## Global Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-p, --port <PORT>` | 51711 (or `$EDEN_PORT`) | HTTP port |
| `-f, --format json\|human` | json | Output format |
| `--host <HOST>` | 127.0.0.1 | Target host |

## Commands

### Party

Create and manage multi-agent sessions.

```bash
# List sessions
proxy party session list

# Create a session with a team
proxy party session create --title "Research" --team <TEAM_ID>

# Send a message (triggers full agent round)
proxy party session send <SESSION_ID> --content "analyze this codebase"

# Read messages
proxy party session messages <SESSION_ID>

# List participants
proxy party session participants <SESSION_ID>

# Set working directory for all agents
proxy party session set-config <SESSION_ID> '{"working_directory":"/path/to/repo"}'

# Search across sessions
proxy party search --query "deployment" --limit 50
```

### Teams

Manage agent teams and role assignments.

```bash
# List teams
proxy team list

# Create a team
proxy team create '{"name":"Research","format_id":"forum","mode":"parallel"}'

# Assign an agent to a team
proxy team assign add <TEAM_ID> '{"role":"participant","agent_id":"<AGENT_ID>","position":0}'

# Remove an assignment
proxy team assign remove <ASSIGNMENT_ID>

# List roles for a format
proxy team roles <FORMAT_ID>
```

### Agents

Manage the agent roster.

```bash
# List all agents
proxy agent list

# Get agent details
proxy agent get <AGENT_ID>

# Sync from remote registry
proxy agent sync

# Set agent defaults
proxy agent defaults set <KEY> <VALUE>
```

### Models

Browse and configure models.

```bash
# List models
proxy model list
proxy model list --provider openrouter
proxy model list --family llama3
proxy model list --embedding

# Get model details
proxy model get <MODEL_ID>

# List model families
proxy model family list
proxy model family list --party-only

# Set active variant for a family
proxy model family set-variant <FAMILY_ID> <VARIANT_ID>

# Resolve a model identifier
proxy model resolve llama-3.3-70b
```

### Providers

Manage API keys for cloud inference.

```bash
# List providers
proxy provider list

# Set an API key
proxy provider key set anthropic sk-ant-...

# Check key status
proxy provider key status anthropic

# Test a key
proxy provider key test anthropic
```

### Harnesses

Manage external agent runtimes.

```bash
# List harnesses
proxy harness list

# Check status
proxy harness status

# Connect a harness
proxy harness connect claude-code

# Set binary path
proxy harness set-path claude-code /usr/local/bin/claude

# Run a harness directly
proxy harness run claude-code -- --help
```

### Integrations

Manage MCP server connections.

```bash
# List integrations
proxy integration list
proxy integration list --connected

# Connect via stdio
proxy integration connect stdio my-server '{"command":"node","args":["server.js"]}'

# Connect via HTTP
proxy integration connect http my-server '{"url":"http://localhost:3000"}'

# Disconnect
proxy integration disconnect my-server

# List tools from an integration
proxy integration tools my-server

# Import from Claude Desktop config
proxy integration import

# Search the integration registry
proxy integration registry search "github"
```

### Loadouts

Manage agent equipment configurations.

```bash
# List loadouts
proxy loadout list

# Create a loadout
proxy loadout create '{"name":"Dev Setup"}'

# Equip skills and integrations
proxy loadout skill equip <LOADOUT_ID> <SKILL_ID>
proxy loadout integration equip <LOADOUT_ID> <INTEGRATION_ID>
```

### Skills

Manage agent skills.

```bash
# List skill sources
proxy skill source list

# Add a skill source
proxy skill source add /path/to/skills

# List default skills
proxy skill defaults
```

### System

System administration and diagnostics.

```bash
# Health check
proxy system health

# Create a snapshot
proxy system snapshot create

# List snapshots
proxy system snapshot list

# Restore from snapshot
proxy system snapshot restore <SNAPSHOT_ID>

# Orchard status
proxy system orchard status
proxy system orchard start
proxy system orchard stop

# Navigate Proxy UI
proxy system navigate widget
proxy system navigate party
proxy system navigate attic

# Take a screenshot
proxy screenshot --output screen.png
```

### Config

Read and write Proxy settings.

```bash
# List all settings
proxy config list

# Get a setting
proxy config get <KEY>

# Set a setting
proxy config set <KEY> <VALUE>
```

## Typical Workflow

```bash
# See what teams are available
proxy team list

# Create a session with a team
proxy party session create --title "Code Review" --team <TEAM_ID>

# Set working directory for all agents
proxy party session set-config <SESSION_ID> '{"working_directory":"/path/to/repo"}'

# Send a message to kick things off
proxy party session send <SESSION_ID> --content "review the latest changes"

# Watch the conversation
proxy party session messages <SESSION_ID>
```
