# Proxy CLI

`proxy` is the command-line client for a running Proxy instance. Every command
is an HTTP call against the Grand Central server that Proxy hosts on
`localhost:${PROXY_PORT:-51711}` — management commands use the `/cli` routes,
headless party runs use the same `/client` API the Proxy app uses.

**Proxy must be running.** The CLI holds no state and runs no inference itself.
When nothing is listening it prints
`Error: Cannot connect to Proxy on port <PORT>. Is Proxy running?` and exits 1.

This page is the canonical reference. Rendered version:
<https://docs.theproxycompany.com/proxy/cli/>

## Global Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-p, --port <PORT>` | `$PROXY_PORT`, else 51711 | Proxy HTTP port |
| `-f, --format <FORMAT>` | `json` | `json` for machine parsing, `human` for readable summaries |
| `--host <HOST>` | `127.0.0.1` | Target Proxy host |

Port precedence: explicit `-p/--port` beats `$PROXY_PORT`, which beats 51711.

## Output Contract

Proxy wraps every `/cli` response in an `{ "ok": bool, "data": ..., "error": ... }`
envelope. The CLI unwraps it:

- **`--format json` (default):** success prints the `data` payload as one line
  of compact JSON on stdout. Server errors print the full envelope to stderr.
- **`--format human`:** success prints `[OK] <title>` followed by the values;
  arrays of objects render as aligned tables, cells truncate at 80 characters.

Requests time out after 60 seconds (`image generate` allows 300 seconds;
headless run streams are not bounded by this).

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success (also `--help` and `--version`) |
| 1 | Usage error, cannot connect, transport failure — and every headless-run failure |
| 2 | Server-reported error (`ok: false` envelope or HTTP error status) from any non-headless command |
| 124 | Headless run hit `--timeout` before the party reached quiescence |

## Headless Party Runs

`proxy party run` seats agents, posts a prompt, streams the live feed, and
prints the final transcript when the session goes quiescent. It is the primary
way for scripts and agents to use Proxy's multi-agent runtime without the app
UI.

```bash
# Seat roster agents by name (or ID) and run to quiescence
proxy party run "summarize the open PRs in this repo" --agents claude,codex

# Seat a saved team
proxy party run "triage today's crash reports" --team support-team

# Inline flow DSL (roles are roster agent names)
proxy party run "draft the Q3 plan" --flow "author -> [reviewer*3] ~> synthesizer"

# Bounded run: exit 124 if not quiescent within 300 seconds
proxy party run "audit the release checklist" --agents claude --timeout 300 --json
```

Exactly one prompt source is required: the positional `PROMPT` or the
`--prompt TEXT` flag alias. Exactly one seating source is required: `--agents`,
`--team`, or `--flow` (they are mutually exclusive).

| Flag | Description |
|------|-------------|
| `--agents <NAMES>` | Comma-separated roster agent names or IDs to seat |
| `--team <TEAM>` | Team ID or name to seat instead of `--agents` |
| `--flow <DSL>` | Inline flow DSL whose roles are roster agent names |
| `--format-id <FORMAT_ID>` | Party format: `forum`, `swarm`, `pair_programming`, or a definition ID. Default: `forum` for multi-agent, `swarm` for one. Conflicts with `--flow` (the flow defines the format) |
| `--prompt <TEXT>` | Flag alias of the positional `PROMPT` |
| `--name <TITLE>` | Session title |
| `--timeout <SECS>` | Exit with code 124 if the party is not quiescent in time |
| `--json` | Print the final transcript as JSON |

### Stream and Transcript Contract

A run dispatches `POST /client/v1/party/run` (which returns `party_id` and
`conversation_id`), then subscribes to the session's server-sent event stream
until quiescence:

- **Live feed goes to stderr** as it happens: each posted message renders as
  `[speaker] text`. System notes render as `[system] note` and agent failures
  as `[agent-id] error: message`. Agent errors do not end the run.
- **The final transcript goes to stdout** once the session's dispatch queue is
  idle (quiescence). Default output is one `[speaker] text` line per message.
- **`--json`** prints a single JSON object instead:

```json
{
  "party_id": "run-…",
  "conversation_id": "…",
  "messages": [
    { "speaker": "claude", "text": "…", "ts": "2026-07-16T00:00:01Z" }
  ]
}
```

Only items of type `message` with non-empty content appear in the transcript
(tool calls and other items are dropped). `speaker` is the participant display
name, falling back to the role; `ts` is the message creation time. The
transcript is paged from the server 500 messages at a time, so long sessions
arrive complete.

Reliability behavior, verified against the implementation:

- **Queue-idle probe.** The event broadcast has no replay: a session that
  finished before the CLI subscribed already fired its idle event. On stream
  connect the CLI probes `GET /v1/threads/<id>/queue-idle` once and skips
  straight to the transcript if the queue is already idle.
- **Keepalives and dead-peer detection.** The server sends a keepalive every
  15 seconds. Each stream read is bounded at 30 seconds; three consecutive
  silent reads (about 90 seconds without a single byte) declares the peer dead
  and the run fails with exit 1.
- **Timeouts.** The `--timeout` deadline is checked between reads. A silent
  stream wakes the reader every 30 seconds, so exit can lag the deadline by up
  to 30 seconds. On expiry the CLI prints
  `Error: timed out waiting for party quiescence` to stderr and exits 124. No
  transcript is printed; the partial feed is already on stderr.
- **Errors exit 1.** For `party run`, `party fire`, and roster runs, dispatch
  failures, stream errors, and server-reported errors all exit 1 (the usual
  exit-2 server-error path is deliberately demoted for headless runs, so
  scripts can treat nonzero-but-not-124 uniformly).

### Flow DSL

`--flow` compiles a format on the fly. For inline flows, every role name must
resolve to a roster agent (by name or ID); `*N` seats that many copies of the
agent.

| Operator | Meaning |
|----------|---------|
| `->` | Sequence: dispatch order, implies round-robin dispatch |
| `[ ]` | Parallel group |
| `~>` | Quiescence: the left roles settle, then the right roles are dispatched for review |
| `=>` | Broadcast gate: the left role's posts are gated by the right role |
| `*N` | Role multiplicity (`reviewer*3`); bare `*` means unbounded |
| `,` | Separates independent clauses |

`@` (human gate) parses but is not yet supported for compilation.

```bash
# Author drafts, three reviewers respond in parallel, a synthesizer
# reviews once the reviewers settle
proxy party run "draft the Q3 plan" --flow "author -> [reviewer*3] ~> synthesizer"

# Round-robin pair
proxy party run "debate this schema change" --flow "claude -> codex"

# Forum shape: participants settle into a moderator, and every
# participant post is gated by the moderator
proxy party run "research MLX kernel tricks" \
  --flow "[scout*3] ~> editor, scout => editor"
```

### Firing Standing Parties

```bash
proxy party fire <STANDING_PARTY_ID> [--timeout SECS] [--json]
```

`party fire` kicks off a standing party definition and streams it to
quiescence with the same stderr feed, stdout transcript, `--json` shape, and
exit codes as `party run`.

### Roster Fallthrough

Any unknown top-level word is treated as a roster agent name and run as a
party of one:

```bash
proxy claude "what changed in the last release?"
proxy codex -p "fix the failing test" --timeout 600 --json
proxy scout --prompt="scan today's inbox"
```

The prompt is the first bare positional argument, or `-p`/`--prompt`.
`--timeout` and `--json` behave exactly as in `party run`. The agent name is
matched case-insensitively against roster names (or exactly against agent
IDs); an unknown name fails with the list of available agents and exit 1.

## Standing Parties

Standing parties are durable, schedulable party definitions. Each one lives in
a folder at `$PROXY_DATA_ROOT/parties/<id>/`:

| File | Purpose |
|------|---------|
| `party.yaml` | Manifest: flow, team, roles, outputs, optional `schedule.cron` |
| `goal.md` | Kickoff prompt |
| `roles/*.md` | Role prompts |
| `playbook.md` | Optional playbook |
| `loadouts/*.md` | Loadout files (shared loadouts live in `$PROXY_DATA_ROOT/loadouts/*.md`) |
| `schemas/*.json` | Output schemas |

Definitions with an enabled cron schedule fire automatically; any definition
can be fired manually with `proxy party fire <id>`.

## Command Reference

### Provider

Inference providers and their API keys (stored in Keychain).

```bash
proxy provider list
proxy provider key set anthropic sk-ant-...
proxy provider key status anthropic
proxy provider key test anthropic
proxy provider key remove anthropic
```

### Agent

The agent roster, registry sync, and default assignments.

```bash
proxy agent list
proxy agent get <AGENT_ID>
proxy agent create '{"name":"Scout","accent_color":"#4CBCF2"}'
proxy agent update <AGENT_ID> '{"name":"Scout","system_prompt":"..."}'
proxy agent delete <AGENT_ID>

# Sync from / reset to the remote registry
proxy agent sync
proxy agent reset

# Default assignments (for example the party moderator)
proxy agent defaults list --scope party
proxy agent defaults set '{"scope":"party","role":"moderator","agent_id":"agent-123","position":0}'
proxy agent defaults remove '{"scope":"party","role":"moderator","agent_id":"agent-123"}'
```

Backend and tuning keys in `create`/`update` payloads (`provider_id`,
`model_id`, `harness_id`, `temperature`, `system_prompt`,
`working_directory`, and the other loadout fields) are routed to the agent's
active loadout automatically. The removed `evolution_tier`, `level`, and `xp`
keys are rejected.

### Party

Sessions, participants, messages, formats, external threads, and search. The
headless `run` and `fire` subcommands are documented above.

```bash
# Sessions
proxy party session list --limit 20
proxy party session create --title "Release War Room" --team <TEAM_ID> --message "kick off"
proxy party session get <SESSION_ID>
proxy party session update <SESSION_ID> '{"title":"Refactor Chat","pinned":true}'
proxy party session delete <SESSION_ID>

# Participants
proxy party session participants <SESSION_ID>
proxy party session add-participant <SESSION_ID> '{"agent_id":"agent-123","role":"participant"}'
proxy party session remove-participant <SESSION_ID> <PARTICIPANT_ID>

# Config overrides: whole session, or one participant
proxy party session set-config <SESSION_ID> '{"working_directory":"/path/to/repo"}'
proxy party session set-config <SESSION_ID> <PARTICIPANT_ID> '{"temperature":0.2}'

# Messages
proxy party session messages <SESSION_ID> --limit 50
proxy party session send <SESSION_ID> --content "review the latest changes"

# Synced external Codex / Claude Code / Hermes threads
proxy party external list --provider claude-code --limit 10
proxy party session add-external <SESSION_ID> --thread <THREAD_ID> --role participant

# Search and formats
proxy party search --query "deployment" --limit 50
proxy party format list
proxy party format roles <FORMAT_ID>
```

### Harness

External CLI agent runtimes (`claude-code`, `codex`, `opencode`).

```bash
proxy harness list
proxy harness status claude-code
proxy harness discover claude-code
proxy harness configure claude-code
proxy harness unconfigure claude-code
proxy harness probe claude-code
proxy harness connect claude-code
proxy harness disconnect claude-code
proxy harness set-path claude-code /usr/local/bin/claude

# Run the harness binary with arguments after --
proxy harness run claude-code -- --version

# Flattened config, one key at a time, and the settings schema
proxy harness config claude-code
proxy harness config-set claude-code permissions.default_mode "acceptEdits"
proxy harness schema claude-code

# Tunnel configuration
proxy harness tunnel get
proxy harness tunnel set '{"username":"proxy","tunnel_token":"...","local_port":51711,"enabled":true}'
proxy harness tunnel clear
```

### Image

Image generation with stored provider keys. The request timeout is 300
seconds.

```bash
proxy image generate "a solarpunk greenhouse at dusk" \
  --provider openai --model gpt-image-2 \
  --size 1536x1024 --quality high --background opaque \
  -n 2 --output ~/Pictures/
```

Defaults: `--provider openai`, `--model gpt-image-2`, `--size 1024x1024`,
one image. Output defaults to `<data dir>/images/`. Human format prints one
generated file path per line; JSON prints the full response with `paths`.

### Integration

MCP integrations: transports, registry, and secrets.

```bash
proxy integration list
proxy integration list --connected
proxy integration get <INTEGRATION_ID>
proxy integration add '{"name":"GitHub","slug":"github","transport":"http","transport_config":{"url":"https://example"}}'
proxy integration remove <INTEGRATION_ID>

# Connect over stdio or HTTP
proxy integration connect stdio <INTEGRATION_ID> '{"command":"mcp-server","args":["--stdio"],"env":{"TOKEN":"..."}}'
proxy integration connect http <INTEGRATION_ID> '{"url":"http://localhost:3000/mcp","headers":{"Authorization":"Bearer ..."}}'
proxy integration disconnect <INTEGRATION_ID>
proxy integration tools <INTEGRATION_ID>

# Registry
proxy integration registry search --query github --limit 10
proxy integration registry refresh
proxy integration registry install <NAME> --curated

# Import from external MCP config files
proxy integration import

# Secrets (Keychain)
proxy integration key set github api_key ghp_...
proxy integration key delete github
```

### Loadout

Per-agent equipment: model tuning, skills, and integrations.

```bash
proxy loadout list
proxy loadout create '{"agent_id":"agent-123","name":"Deep Work","provider_id":"anthropic","model_id":"claude-sonnet-4-6"}'
proxy loadout activate <LOADOUT_ID>
proxy loadout tuning <LOADOUT_ID> '{"temperature":0.7,"working_directory":"/path/to/repo"}'
proxy loadout delete <LOADOUT_ID>

proxy loadout skill list <LOADOUT_ID>
proxy loadout skill equip <LOADOUT_ID> <SKILL_ID>
proxy loadout skill unequip <LOADOUT_ID> <SKILL_ID>

proxy loadout integration list <LOADOUT_ID>
proxy loadout integration equip <LOADOUT_ID> <INTEGRATION_ID>
proxy loadout integration unequip <LOADOUT_ID> <INTEGRATION_ID>
```

`create` requires `agent_id`; any keys beyond `agent_id` and `name` are
applied as a tuning update after creation.

### Model

Models, families, compute providers, and compute targets.

```bash
proxy model list
proxy model list --provider openrouter
proxy model list --family llama3
proxy model list --embedding
proxy model get <MODEL_ID>
proxy model resolve llama-3.3-70b

proxy model family list
proxy model family list --party-only
proxy model family set-variant <FAMILY_ID> <VARIANT_ID>
proxy model family set-slot <FAMILY_ID> 2      # omit the slot to clear it

proxy model provider list --category local
proxy model provider get <PROVIDER_ID>
proxy model provider access-modes <PROVIDER_ID>
proxy model provider set-access-mode <PROVIDER_ID> <MODE_ID>

proxy model target list
proxy model target create '{"name":"Local LM Studio","access_mode_id":"lm-studio-http"}'
proxy model target update <TARGET_ID> '{"name":"Studio (M3)"}'
proxy model target delete <TARGET_ID>
```

### Team

Saved teams and role assignments.

```bash
proxy team list
proxy team get <TEAM_ID>
proxy team create '{"name":"Research","format_id":"swarm","mode":"parallel"}'
proxy team update <TEAM_ID> '{"mode":"sequential"}'
proxy team delete <TEAM_ID>

proxy team assign add <TEAM_ID> '{"role":"participant","agent_id":"agent-123","position":0}'
proxy team assign update-config <ASSIGNMENT_ID> '{"working_directory":"/path/to/repo"}'
proxy team assign remove <ASSIGNMENT_ID>

proxy team roles <FORMAT_ID>
```

### Skill

Skill sources (local folders or SSH remotes) and bundled defaults.

```bash
proxy skill source list
proxy skill source add my-skills "My Skills" /path/to/skills
proxy skill source add-remote terminal-skills "Terminal Skills" proxy-terminal-1 "~/.hermes/skills"
proxy skill source sync terminal-skills
proxy skill source remove my-skills
proxy skill defaults
```

### Config

Proxy settings and the Grand Central config document.

```bash
proxy config list
proxy config get autoUpdate
proxy config set autoUpdate true

proxy config gc get
proxy config gc update '{"snapshots":{"enabled":true}}'
```

`config set` values are parsed as JSON when valid (`true`, `5173`, `"dark"`)
and sent as plain strings otherwise.

### System

Health, snapshots, the Orchard runtime, UI navigation, and app updates.

```bash
proxy system health

proxy system snapshot create
proxy system snapshot list
proxy system snapshot restore <SNAPSHOT_PATH>
proxy system snapshot merge <SNAPSHOT_PATH> --include-party

proxy system orchard status
proxy system orchard start
proxy system orchard stop

# Navigate the Proxy UI
proxy system navigate widget home        # home, timeline, roster, actions, command, lifeMap
proxy system navigate widget roster --tab agents
proxy system navigate widget lifeMap --node-id <NODE_ID>
proxy system navigate party --session-id <SESSION_ID>
proxy system navigate attic

proxy system update check
proxy system update status
proxy system update install
```

`snapshot merge` merges a snapshot into local data without deleting local
records; `--include-party` also merges the party/chat tables. `--tab` only
applies to the `roster` widget; the `--node-*` flags only apply to `lifeMap`.

### Screenshot

Capture Proxy's current window as a PNG.

```bash
proxy screenshot
proxy screenshot --output /tmp/proxy.png
```

Human format prints the file path; JSON prints the response object including
`path`. Without `--output` the capture goes to a temporary file.
