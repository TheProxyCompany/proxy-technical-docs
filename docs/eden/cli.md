# Eden CLI

`eden` is a command-line tool that ships with Eden for controlling a running instance. It talks to Eden's MCP server over HTTP on `localhost:51711`.

**Eden must be running** for any CLI command to work. The CLI is a client, not a standalone tool.

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
eden party session list

# Create a session with a team
eden party session create --title "Research" --team <TEAM_ID>

# Send a message (triggers full agent round)
eden party session send <SESSION_ID> --content "analyze this codebase"

# Read messages
eden party session messages <SESSION_ID>

# List participants
eden party session participants <SESSION_ID>

# Set working directory for all agents
eden party session set-config <SESSION_ID> '{"working_directory":"/path/to/repo"}'

# Search across sessions
eden party search --query "deployment" --limit 50
```

### Teams

Manage agent teams and role assignments.

```bash
# List teams
eden team list

# Create a team
eden team create '{"name":"Research","format_id":"forum","mode":"parallel"}'

# Assign an agent to a team
eden team assign add <TEAM_ID> '{"role":"participant","agent_id":"<AGENT_ID>","position":0}'

# Remove an assignment
eden team assign remove <ASSIGNMENT_ID>

# List roles for a format
eden team roles <FORMAT_ID>
```

### Agents

Manage the agent roster.

```bash
# List all agents
eden agent list

# Get agent details
eden agent get <AGENT_ID>

# Sync from remote registry
eden agent sync

# Set agent defaults
eden agent defaults set <KEY> <VALUE>
```

### Models

Browse and configure models.

```bash
# List models
eden model list
eden model list --provider openrouter
eden model list --family llama3
eden model list --embedding

# Get model details
eden model get <MODEL_ID>

# List model families
eden model family list
eden model family list --party-only

# Set active variant for a family
eden model family set-variant <FAMILY_ID> <VARIANT_ID>

# Resolve a model identifier
eden model resolve llama-3.3-70b
```

### Providers

Manage API keys for cloud inference.

```bash
# List providers
eden provider list

# Set an API key
eden provider key set anthropic sk-ant-...

# Check key status
eden provider key status anthropic

# Test a key
eden provider key test anthropic
```

### Harnesses

Manage external agent runtimes.

```bash
# List harnesses
eden harness list

# Check status
eden harness status

# Connect a harness
eden harness connect claude-code

# Set binary path
eden harness set-path claude-code /usr/local/bin/claude

# Run a harness directly
eden harness run claude-code -- --help
```

### Integrations

Manage MCP server connections.

```bash
# List integrations
eden integration list
eden integration list --connected

# Connect via stdio
eden integration connect stdio my-server '{"command":"node","args":["server.js"]}'

# Connect via HTTP
eden integration connect http my-server '{"url":"http://localhost:3000"}'

# Disconnect
eden integration disconnect my-server

# List tools from an integration
eden integration tools my-server

# Import from Claude Desktop config
eden integration import

# Search the integration registry
eden integration registry search "github"
```

### Loadouts

Manage agent equipment configurations.

```bash
# List loadouts
eden loadout list

# Create a loadout
eden loadout create '{"name":"Dev Setup"}'

# Equip skills and integrations
eden loadout skill equip <LOADOUT_ID> <SKILL_ID>
eden loadout integration equip <LOADOUT_ID> <INTEGRATION_ID>
```

### Skills

Manage agent skills.

```bash
# List skill sources
eden skill source list

# Add a skill source
eden skill source add /path/to/skills

# List default skills
eden skill defaults
```

### System

System administration and diagnostics.

```bash
# Health check
eden system health

# Create a snapshot
eden system snapshot create

# List snapshots
eden system snapshot list

# Restore from snapshot
eden system snapshot restore <SNAPSHOT_ID>

# Orchard status
eden system orchard status
eden system orchard start
eden system orchard stop

# Navigate Eden UI
eden system navigate widget
eden system navigate party
eden system navigate attic

# Take a screenshot
eden screenshot --output screen.png
```

### Config

Read and write Eden settings.

```bash
# List all settings
eden config list

# Get a setting
eden config get <KEY>

# Set a setting
eden config set <KEY> <VALUE>
```

## Typical Workflow

```bash
# See what teams are available
eden team list

# Create a session with a team
eden party session create --title "Code Review" --team <TEAM_ID>

# Set working directory for all agents
eden party session set-config <SESSION_ID> '{"working_directory":"/path/to/repo"}'

# Send a message to kick things off
eden party session send <SESSION_ID> --content "review the latest changes"

# Watch the conversation
eden party session messages <SESSION_ID>
```
