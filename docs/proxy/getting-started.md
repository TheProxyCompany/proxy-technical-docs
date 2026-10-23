# Getting Started With Proxy

Proxy is the app layer for working with your Life Map, agents, Party chats,
Moves, integrations, and local or cloud models.

## Start On Desktop

1. Open Proxy on your Mac.
2. Complete the first-run setup.
3. Choose the model routes you want available: local Orchard models, your own
   provider keys, Proxy Credits, or harness-backed agents.
4. Review the Roster and pick the agents you want to use.
5. Start a Party chat or open Timeline to continue active work.

The desktop app owns the local source of truth. It stores your graph, content,
settings, snapshots, events, and integration configuration on the Mac.

## Add Agents

Open Roster to inspect available agents. An agent uses an active loadout, which
can define the model, harness, prompt, working directory, skills,
integrations, and reasoning settings.

Use loadouts when the same agent needs different operating modes, such as a
local model mode, a cloud model mode, and a harness-backed coding mode.

## Connect Integrations

Open Integrations when an agent needs access to a tool or service. Proxy can
use MCP servers, CLI tools, HTTP APIs, skills, and local services.

Credential setup stays on the Mac. Proxy Mobile can inspect and use available
loadout configuration, but desktop remains the setup surface for OAuth, local
binary paths, and private credentials.

## Use Proxy Mobile

Proxy Mobile connects back to a running desktop instance through Grand
Central's client API. Use it for Timeline, Roster, Proxy chat, Moves, and Party
chats while the Mac remains the source of truth.

If you use proxy.ing, pair mobile with an approved address such as:

```text
https://username.proxy.ing/mcp/proxy
```

Proxy Mobile rewrites that endpoint to the client API for app requests.

## Next

- [Roster](roster.md)
- [Party Chat](party.md)
- [Moves](moves.md)
- [Integrations](integrations.md)
- [proxy.ing getting started](../proxy-ing/getting-started.md)
