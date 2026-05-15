# Proxy

Proxy is the app layer for The Proxy Company. It is a Mac app plus a mobile
companion for working with your Life Map, agents, Party chats, Moves, tools,
models, and integrations.

Proxy is local-first. Your data lives on your machine, and cloud calls happen
only when you choose a cloud model, a connected service, or a public proxy.ing
route.

## App Surfaces

| Surface | What it does |
| --- | --- |
| Proxy desktop | Main workspace for Parties, Moves, Life Map context, roster setup, models, integrations, and harnesses |
| Proxy Mobile | Companion app for Timeline, Roster, Proxy chat, Moves, and Party chats connected back to a running desktop instance |
| Proxy CLI | Command-line control plane for a running Proxy instance |
| proxy.ing | Public address layer for chat, client routes, inference, and MCP access to an approved local device |

## Core Concepts

| Concept | Meaning |
| --- | --- |
| [Roster](roster.md) | The agents available to work inside Proxy |
| [Integrations](integrations.md) | MCP servers, CLI tools, HTTP APIs, skills, and services Proxy can use |
| [Harnesses](harnesses.md) | External agent runtimes, such as Codex or Claude Code, that can join Party sessions |
| [Timeline](timeline.md) | A chronological feed of Life Map entries and activity |
| [Life Map](life-map.md) | Proxy's context layer for projects, people, commitments, files, decisions, and active work |
| [Moves](moves.md) | Reviewable cards and documents that ask for a decision or present structured work |
| [Party Chat](party.md) | Shared chats where you and selected agents work together |

## Model Routes

Proxy can mix model routes in the same product surface.

| Route | Use it for |
| --- | --- |
| Local Orchard models | Private Apple Silicon inference through Orchard |
| Bring Your Own Key | Cloud providers you configure with your own API keys |
| Proxy Credits | Pay-as-you-go cloud inference through Proxy |
| Harnesses | External agent CLIs and runtimes that run work outside the model router |

## Local Storage

Proxy stores its working state locally:

```text
~/Proxy/
├── proxy.db
├── config.json
├── graph/
├── content/
├── skills/
├── snapshots/
├── changesets/
├── events/
├── exports/
└── mcp.json
```

The desktop app owns the local source of truth. Proxy Mobile connects to it
through Grand Central's client API and keeps a small local cache for responsive
views.

## MCP Server

When Proxy is running, it exposes a local MCP server on `localhost:51711`.
External clients can use it to query context, send Party messages, inspect
Moves, and operate through Proxy's local runtime.

See [proxy.ing](../proxy-ing/index.md) for the public address layer that can
route approved traffic back to a local Proxy device.
