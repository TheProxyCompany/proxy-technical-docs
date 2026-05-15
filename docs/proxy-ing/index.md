# proxy.ing

`proxy.ing` is the public address layer for Proxy and Orchard.

A user can connect a local machine to a `username.proxy.ing` address. Normal
browser traffic serves the shared web chat client. Private route prefixes reach
the user's local Grand Central server through a Cloudflare Tunnel.

## What It Serves

| Public route | What handles it |
| --- | --- |
| `https://username.proxy.ing/` | The shared proxy.ing web chat client |
| `https://username.proxy.ing/v1/*` | An OpenAI-compatible route on the user's tunnel origin |
| `https://username.proxy.ing/client/*` | Grand Central's client API |
| `https://username.proxy.ing/inference/*` | Grand Central's inference API |
| `https://username.proxy.ing/mcp/proxy` | Proxy MCP server |
| `https://username.proxy.ing/mcp/party` | Party MCP server |

Reserved names and unknown usernames redirect to `https://proxy.ing`.

## What To Read

| Need | Page |
| --- | --- |
| Claim and connect an address | [Getting started](getting-started.md) |
| Understand public and private route prefixes | [Routes](routes.md) |
| Understand passkeys, approval links, and recovery | [Device approval](device-approval.md) |
| Build against the Grand Central client API | [Client API](client-api.md) |

## Ownership Model

Address ownership is passkey-bound. A device does not receive tunnel
credentials until the owner approves a device challenge. Proxy desktop stores
the tunnel configuration locally, runs `cloudflared`, and exposes Grand Central
on the device's local port.

The default Grand Central port is `51711`.

## Related

- [Getting started](getting-started.md)
- [Routes](routes.md)
- [Device approval](device-approval.md)
- [Client API](client-api.md)
- [Proxy overview](../proxy/index.md)
- [Orchard overview](../orchard/index.md)
