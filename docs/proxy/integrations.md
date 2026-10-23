# Integrations

Integrations are the tools and services Proxy can use on your behalf. They live
on the Mac-side Proxy instance and are equipped to agents through loadouts.

## Integration Types

| Type | What it is | Examples |
| --- | --- | --- |
| MCP server | A Model Context Protocol server that exposes tools and resources | GitHub, Slack, local Proxy MCP, custom MCP servers |
| CLI tool | A command-line tool Proxy can run with structured inputs and outputs | `gh`, `gws`, `aws` |
| HTTP API | A direct web API with stored credentials | OpenRouter, Stripe, custom internal APIs |
| Skill | Local instructions and scripts an agent can use | repo workflows, app-specific operating guides |

## Loadouts

Agents experience integrations through loadouts. A loadout can define:

- model provider and model
- system prompt
- enabled skills
- equipped integrations
- working directory
- harness selection
- reasoning and sampling settings
- display name, avatar, and accent color

Changing a loadout changes what that agent can do. This is the right place to
decide whether an agent can read GitHub, use Google Workspace, talk to Proxy
MCP, or operate in a specific repo.

## Desktop And Mobile

The desktop app owns integration setup and credentials. Proxy Mobile can inspect
agents and loadouts, and it can equip or unequip integrations that are already
available on the Mac. Credential setup, OAuth, and local binary paths stay on
the desktop device.

## Proxy MCP

Proxy itself exposes an MCP server on `localhost:51711` when the app is
running. External clients can use it to work with Proxy context, Moves, agents,
and Party sessions.

Through proxy.ing, the public MCP docs currently expose:

```text
https://username.proxy.ing/mcp/proxy
https://username.proxy.ing/mcp/party
```

## Related

- [Roster](roster.md)
- [Harnesses](harnesses.md)
- [Party Chat](party.md)
