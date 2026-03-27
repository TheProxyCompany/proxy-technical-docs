# Eden

Eden is a macOS application that gives you a spatial representation of your own trajectory through time. It combines structural reasoning, multi-agent deliberation, and local intelligence into a single cockpit.

## What Eden Is

- A map of your life — the Life Map
- A multi-agent deliberation system — the Party
- A daily driver for AI — local models, cloud models, bring your own keys, or use Proxy credits
- A console — models are the games, agents are the leverage, the Life Map is the mini map

## What Eden Is Not

- Not another chat app glued on top of models
- Not an attention farm, feed, or timeline
- Not an "AI front-end" where the selling point is which logo is in the corner

## Architecture

```
Eden (SwiftUI)
  └── Glue (Rust FFI bridge)
      └── Grand Central (coordination)
          ├── Trellis (Life Map database)
          ├── Party (multi-agent deliberation)
          ├── Roster (agent configuration)
          ├── Content (blob storage)
          ├── Harnesses (external agent runtimes)
          ├── Integrations (MCP servers)
          └── Skills (structured deliverables)
```

**Eden** is the SwiftUI interface — the cockpit, the Life Map visualization, the Party chat, the settings drawer (Attic).

**Glue** is a Rust FFI layer that bridges Swift and the Rust coordination layer. It exposes C-compatible functions that Swift calls directly.

**Grand Central** is the coordination layer. It manages agents, content, the Party system, MCP servers, harness connections, and the database. Grand Central also runs an MCP server on `localhost:51711`, which external tools (Claude Code, Codex, or any MCP client) use to interact with Eden.

**Trellis** is the graph database that stores the Life Map. It's a fork of GraphLite (Apache 2.0), extended with PageRank2 leverage computation and the 8-8-7 type system.

## Storage

Eden stores all data locally:

```
~/Eden/
├── eden.db          # SQLite database (agents, models, conversations, party, roster, skills)
├── config.json      # Device identity and settings
├── graph/           # Trellis graph database
├── content/         # Content-addressed blob storage (SHA-256)
├── skills/          # Installed skills
├── snapshots/       # Point-in-time backups (.eden files)
├── changesets/      # Sync units
├── events/          # Event logs
├── exports/         # User exports
└── mcp.json         # MCP server runtime state
```

Everything runs on your machine. Cloud calls happen only when you explicitly use cloud models.

## Inference

Eden supports three inference modes:

| Mode | How it works |
|------|-------------|
| **Local** | Orchard runs models directly on Apple Silicon via PIE |
| **Bring Your Own Key (BYOK)** | Use your own API keys for Anthropic, OpenAI, Google, or xAI |
| **Proxy Credits** | Pay-as-you-go cloud inference through OpenRouter, displayed in dollars |

All three modes work through the same interface. You can mix local and cloud models in the same Party session.

## MCP Server

When Eden is running, it exposes an MCP server on `localhost:51711`. This server provides tools for reading and writing the Life Map, managing agents, running Party sessions, and more.

Any MCP-compatible client can connect — Claude Code, Codex, or custom tooling.

