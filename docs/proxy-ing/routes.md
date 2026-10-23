# proxy.ing Routes

`proxy.ing` has three route classes:

1. Web traffic for the shared public chat client.
2. OpenAI-compatible `/v1/*` traffic for browser-safe API use.
3. Authenticated private tunnel traffic for Grand Central client, inference,
   and MCP routes.

## Public Route Map

| Route | Purpose | CORS |
| --- | --- | --- |
| `https://username.proxy.ing/` | Shared web chat client | Site default |
| `https://username.proxy.ing/v1/*` | OpenAI-compatible route on the user's tunnel origin | Browser CORS enabled |
| `https://username.proxy.ing/client/*` | Grand Central client API | No broad browser CORS |
| `https://username.proxy.ing/inference/*` | Grand Central inference API | No broad browser CORS |
| `https://username.proxy.ing/mcp/proxy` | Proxy MCP server | No broad browser CORS |
| `https://username.proxy.ing/mcp/party` | Party MCP server | No broad browser CORS |

Unknown usernames and reserved subdomains redirect to `https://proxy.ing`.

## Tunnel Ingress

Proxy creates a Cloudflare Tunnel configuration for the user's address. The
private prefixes route to Grand Central on the device:

| Prefix | Local service |
| --- | --- |
| `/mcp/*` | `http://localhost:51711` |
| `/client/*` | `http://localhost:51711` |
| `/inference/*` | `http://localhost:51711` |
| everything else | The configured local web/chat origin |

The fallback local origin can use a different port, but the Grand Central
client, inference, and MCP prefixes route to port `51711`.

## Grand Central Client Routes

When accessed through proxy.ing, these routes live under
`https://username.proxy.ing/client/v1`.

| Route | Purpose |
| --- | --- |
| `GET /timeline/entries` | Timeline entries for the app surface |
| `GET /timeline/entries/:id` | One timeline entry |
| `GET /content/:reference` | Referenced content blobs |
| `GET /events` | App event stream |
| `GET /moves` | Moves for review |
| `POST /moves/:id/resolve` | Resolve a Move |
| `GET /agents` | Available agents |
| `GET /agents/:id` | Agent detail |
| `GET /agents/:id/loadouts` | Agent loadouts |
| `POST /agents/:id/loadouts` | Create a loadout |
| `PATCH /loadouts/:id` | Update a loadout |
| `DELETE /loadouts/:id` | Delete a loadout |
| `POST /loadouts/:id/duplicate` | Duplicate a loadout |
| `POST /loadouts/:id/activate` | Activate a loadout |
| `POST/PATCH/DELETE /loadouts/:id/skills/:skill_id` | Equip, update, or remove a skill |
| `POST/DELETE /loadouts/:id/integrations/:integration_id` | Equip or remove an integration |
| `GET /catalog/harnesses` | Harness catalog |
| `GET /catalog/skills` | Skill catalog |
| `GET /catalog/integrations` | Integration catalog |
| `GET /catalog/models` | Model catalog |
| `GET /catalog/providers` | Provider catalog |
| `GET/POST /threads` | List or create threads |
| `GET /threads/:id` | Thread detail |
| `GET /threads/:id/roster` | Thread roster |
| `POST /threads/:id/participants` | Add a participant |
| `GET /threads/:id/snapshot` | Thread snapshot |
| `GET /threads/:id/events` | Thread event stream |
| `GET/POST /threads/:id/messages` | List or send messages |
| `POST /approvals/:id/respond` | Respond to an approval request |

## Grand Central Inference Routes

When accessed through proxy.ing, these routes live under
`https://username.proxy.ing/inference/v1`.

| Route | Purpose |
| --- | --- |
| `POST /responses` | OpenAI Responses-style inference |
| `POST /chat/completions` | OpenAI-compatible chat completions |
| `POST /completions` | OpenAI-compatible text completions |
| `POST /embeddings` | Embeddings |
| `GET /models` | Model listing |
| `GET /models/:model_id/status` | Model readiness |

For browser clients that need broad CORS, use the top-level `/v1/*` route class.
For app and device clients that carry the expected bearer token, use
`/inference/v1/*`.

## MCP Routes

proxy.ing currently documents two MCP endpoints:

| Route | Purpose |
| --- | --- |
| `/mcp/proxy` | Proxy MCP tools |
| `/mcp/party` | Party MCP tools |

These are private tunnel routes. Treat them as authenticated device routes, not
public browser APIs.

## Related

- [Getting started](getting-started.md)
- [Device approval](device-approval.md)
- [Client API](client-api.md)
