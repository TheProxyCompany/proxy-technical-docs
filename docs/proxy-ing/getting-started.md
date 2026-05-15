# Getting Started With proxy.ing

This page describes the public flow implemented by Proxy and the proxy.ing
registry.

## Claim An Address

1. Open the proxy.ing section in Proxy or Proxy Mobile.
2. Choose a lowercase username, such as `alice`.
3. Create the passkey for `alice.proxy.ing`.
4. Complete checkout.
5. Return to Proxy to finish connecting the device.

The registry keeps the address reserved while the passkey and checkout flow
finish. After payment, the address becomes active.

## Connect A Device

Proxy creates a device challenge for the address. The owner approves that
challenge with their passkey or recovery credential. After approval, the device
claims the challenge and receives the tunnel credentials.

Proxy saves those credentials locally, starts `cloudflared`, and routes the
address to Grand Central on port `51711`.

## Use The Address

Once connected:

```text
https://alice.proxy.ing/
```

opens the web chat client.

```text
https://alice.proxy.ing/client/v1/moves
```

reaches Grand Central's client API.

```text
https://alice.proxy.ing/inference/v1/chat/completions
```

reaches Grand Central's inference API.

```text
https://alice.proxy.ing/mcp/proxy
```

reaches the Proxy MCP server.

```text
https://alice.proxy.ing/mcp/party
```

reaches the Party MCP server.

## Use An OpenAI-Compatible Route

The web chat client posts to:

```text
https://alice.proxy.ing/v1/chat/completions
```

and falls back to:

```text
https://alice.proxy.ing/v1/responses
```

Those routes are for the OpenAI-compatible origin exposed by the user's tunnel.
For Grand Central's built-in inference server, use the `/inference/v1/*` paths.

See [routes](routes.md) for the full public route map and [client API](client-api.md)
for the app/mobile API.

## Security Model

- Address ownership is tied to a passkey.
- Device access requires an owner-approved challenge.
- Tunnel credentials are stored on the approved device.
- Grand Central's private tunnel routes require the expected bearer token when
  requests arrive through Cloudflare.
- Private tunnel prefixes do not enable broad browser CORS.

See [device approval](device-approval.md) for username rules, passkey origins,
approval links, recovery credentials, and registry routes.
