# Your Proxy address

**steve.proxy.ing** is an address for Steve's Proxy. Like an email address,
it gives other people a place to reach you, through the representative working
on your behalf. Apps can ask to connect there, and other people can invite
your Proxy to work with theirs.

You decide who gets in. An address identifies your Proxy; it does not give
someone access to your Life Map, conversations, or tools.

## Work with another person's Proxy

On compatible versions, a [Party](../proxy/party.md) can include another
person's Proxy at their address. The host sends an invitation. The owner sees
a [Move](../proxy/moves.md) naming who is asking, which agent they want to
include, and what the connection opens.

For example, Steve could invite your Proxy into a Party to coordinate a DJ set.
You review the invitation on your desktop or phone. If you accept, your Proxy
can receive messages and return work to Steve's Party. You can read and steer
the corresponding conversation with your Proxy.

That invitation opens one conversation with the named agent. It does not open
the owner's other chats or their whole Life Map, and it does not let the host
approve the owner's Moves. Either side can end the connection. See
[Parties with other Proxies](../proxy/party.md#work-with-someone-elses-proxy)
for how the conversations fit together.

## Connect an app

A compatible app can ask to use your agents, models, or tools. You receive a
connection Move that names the app and the access it requests. Review it in
Proxy before letting the app in. You can remove that connection later under
proxy.ing in Proxy.

Developers can follow [Connect your app](connect.md) for the authorization
flow and the scopes each connection can request.

## Reach your own Proxy

The same address also connects your own devices to your running host:

- Open the configured web chat client from a browser.
- Connect Proxy Mobile to review conversations and Moves away from your desk.
- Use compatible apps with the access you have approved.

Your host must be running and connected. It remains the home for your Life Map;
the address routes requests to it. See [devices](../proxy/devices.md) for the
current desktop, mobile, and browser surfaces.

[Set up your address](getting-started.md) or
[connect an app](connect.md).

## Developer reference

The public routes below reach a host through a Cloudflare Tunnel. A compatible
address also exposes authorization metadata and an OAuth connection flow.
Discover its capabilities before connecting; an address may be offline or
running an older version.

## What It Serves

| Public route | What handles it |
| --- | --- |
| `https://username.proxy.ing/` | The shared proxy.ing web chat client |
| `https://username.proxy.ing/v1/*` | An OpenAI-compatible route on the user's tunnel origin |
| `https://username.proxy.ing/client/*` | Grand Central's client API |
| `https://username.proxy.ing/inference/*` | Grand Central's inference API |
| `https://username.proxy.ing/mcp/proxy` | Proxy MCP server |
| `https://username.proxy.ing/mcp/party` | Party MCP server |
| `https://username.proxy.ing/.well-known/oauth-authorization-server` | Connection metadata for a compatible host |
| `https://username.proxy.ing/oauth/*` | App registration, connection requests, token exchange, and revocation |

Reserved names and unknown usernames redirect to `https://proxy.ing`.

## What To Read

| Need | Page |
| --- | --- |
| Claim and connect an address | [Getting started](getting-started.md) |
| Understand public and private route prefixes | [Routes](routes.md) |
| Understand passkeys, approval links, and recovery | [Device approval](device-approval.md) |
| Build against the Grand Central client API | [Client API](client-api.md) |
| Let your users connect their Proxy to your app | [Connect Your App](connect.md) |

## Ownership Model

Address ownership is passkey-bound. A device does not receive tunnel
credentials until the owner approves a device challenge. Proxy desktop stores
the tunnel configuration locally, runs `cloudflared`, and exposes Grand Central
on the device's local port.

Approving a device for your address and approving an app or Party connection
are different decisions. A Party invitation gives the host the limited
conversation access described above; it does not make that host one of your
devices.

The default Grand Central port is `51711`.

## Related

- [Getting started](getting-started.md)
- [Routes](routes.md)
- [Device approval](device-approval.md)
- [Client API](client-api.md)
- [Connect Your App](connect.md)
- [Proxy overview](../proxy/index.md)
- [Orchard overview](../orchard/index.md)
