# Client API

The client API lets Proxy Mobile and connected apps work with a running Proxy
host. The host keeps the source data, and the Proxy address routes authorized
requests to it. If you are building a third-party app, start with
[Connect your app](connect.md) to request the access it needs.

## Base URL

For a proxy.ing address:

```text
https://username.proxy.ing/client/v1
```

Proxy Mobile can be paired with the MCP endpoint:

```text
https://username.proxy.ing/mcp/proxy
```

The mobile client rewrites that endpoint to `/client/v1` for app API requests.
This lets the same address expose MCP tools and app/mobile routes without
asking the user to type a second URL.

## Authentication

Private tunnel requests require authorization. An approved device can use the
account bearer. A connected app uses the scoped token issued by the address's
[authorization flow](connect.md). Its token only opens the permitted route
families; the route list below is not a promise that every app can use every
endpoint. A Party connection is further limited to one direct thread with
the named agent.

Clients should preserve the `Mcp-Session-Id` header when an MCP server returns
one.

Private tunnel prefixes do not enable broad browser CORS. Browser-facing
OpenAI-compatible requests should use the top-level `/v1/*` route class.

## Timeline And Content

| Route | Purpose |
| --- | --- |
| `GET /timeline/entries` | Timeline entries |
| `GET /timeline/entries/:id` | One timeline entry |
| `GET /content/:reference` | Referenced content for blocks, attachments, and timeline items |
| `GET /events` | App-wide event stream |

Use `/events` to keep remote UI state fresh after messages, approvals, roster
changes, or Move updates.

## Moves

| Route | Purpose |
| --- | --- |
| `GET /moves` | List Moves for review |
| `POST /moves/:id/resolve` | Resolve a Move |

Moves are the app review surface for proposed agent work. A remote client
should render them as reviewable actions, not plain chat text.

An app with the `moves` scope can read Moves. Resolving a Move also requires
proof from an approved owner device; a bearer token alone receives `403`.
See [Move approval requirements](connect.md#what-your-app-asks-for). Connecting
an app does not authorize it to make the person's decisions.

## Agents And Loadouts

| Route | Purpose |
| --- | --- |
| `GET /agents` | Available agents |
| `GET /agents/:id` | Agent detail |
| `GET /agents/:id/loadouts` | Loadouts for an agent |
| `POST /agents/:id/loadouts` | Create a loadout |
| `PATCH /loadouts/:id` | Update a loadout |
| `DELETE /loadouts/:id` | Delete a loadout |
| `POST /loadouts/:id/duplicate` | Duplicate a loadout |
| `POST /loadouts/:id/activate` | Activate a loadout |
| `POST/PATCH/DELETE /loadouts/:id/skills/:skill_id` | Equip, update, or remove a skill |
| `POST/DELETE /loadouts/:id/integrations/:integration_id` | Equip or remove an integration |

Some integrations require desktop setup. If a remote client tries to equip one
directly, Grand Central can return a conflict explaining that desktop setup is
required.

## Catalogs

| Route | Purpose |
| --- | --- |
| `GET /catalog/harnesses` | Harness catalog |
| `GET /catalog/skills` | Skill catalog |
| `GET /catalog/integrations` | Integration catalog |
| `GET /catalog/models` | Model catalog |
| `GET /catalog/providers` | Provider catalog |

Use catalogs to build roster, harness, model, skill, and integration selection
UI.

## Threads And Party

| Route | Purpose |
| --- | --- |
| `GET /threads` | List threads |
| `POST /threads` | Create a thread |
| `GET /threads/:id` | Thread detail |
| `GET /threads/:id/roster` | Thread roster |
| `POST /threads/:id/participants` | Add a participant |
| `GET /threads/:id/snapshot` | Thread snapshot |
| `GET /threads/:id/events` | Thread event stream |
| `GET /threads/:id/messages` | List messages |
| `POST /threads/:id/messages` | Send a message |

For live Party UI, use the thread event stream and refresh snapshots after
state-changing operations.

## Approvals

| Route | Purpose |
| --- | --- |
| `POST /approvals/:id/respond` | Approve or reject an approval request |

Approvals are separate from normal chat messages. Treat them as first-class
review actions in a remote client.

## Related

- [Routes](routes.md)
- [Device approval](device-approval.md)
- [Proxy Party](../proxy/party.md)
- [Proxy Moves](../proxy/moves.md)
