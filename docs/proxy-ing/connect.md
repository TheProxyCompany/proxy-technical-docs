# Connect a Proxy Address to Your App

Your users bring their own compute. A person with a Proxy address —
`https://alice.proxy.ing` — runs their own agent, tools and models on their
own Macs, and that address is its own OAuth 2.1 authorization server. Your
app asks for the username, sends the person to their address, and they let
your app in from Proxy on their Mac or phone: one tap, nothing to paste.
From then on your app calls their inference and their tools with the bearer
their address issued, and they can take it back whenever they like.

There is nothing to register with The Proxy Company. Every address speaks
the same protocol, so one client implementation reaches every person.

## What Your App Gets

| Surface | At | Speaks |
| --- | --- | --- |
| Inference | `https://<username>.proxy.ing/inference/v1/...` | The OpenAI API: `/models`, `/chat/completions`, `/responses` |
| Tools | `https://<username>.proxy.ing/mcp/proxy` | MCP over HTTP: the person's Life Map, Moves, parties, integrations |

Both take `Authorization: Bearer <token>`. A request without one answers
`401` with a `WWW-Authenticate` header that names the address's metadata,
which is how MCP clients such as Claude, Claude Code and Cursor find the flow
on their own: add `https://<username>.proxy.ing/mcp/proxy` and the person is
asked to let them in.

## The Flow

The address is the issuer. Everything below is standard OAuth 2.1 with PKCE,
dynamic client registration (RFC 7591), server metadata (RFC 8414) and
protected-resource metadata (RFC 9728).

### 1. Read the metadata

```bash
curl https://alice.proxy.ing/.well-known/oauth-authorization-server
```

```json
{
  "issuer": "https://alice.proxy.ing",
  "authorization_endpoint": "https://alice.proxy.ing/oauth/authorize",
  "token_endpoint": "https://alice.proxy.ing/oauth/token",
  "registration_endpoint": "https://alice.proxy.ing/oauth/register",
  "revocation_endpoint": "https://alice.proxy.ing/oauth/revoke",
  "response_types_supported": ["code"],
  "grant_types_supported": ["authorization_code"],
  "code_challenge_methods_supported": ["S256"],
  "token_endpoint_auth_methods_supported": ["none"]
}
```

### 2. Register your app, once per address

Say what you are called — the person is asked whether to let you in by that
name — and where the person comes back to. Clients are public: there is no
client secret, because holding the PKCE verifier is the proof.

```bash
curl -X POST https://alice.proxy.ing/oauth/register \
  -H 'content-type: application/json' \
  -d '{"client_name":"Acme","redirect_uris":["https://acme.com/proxy/callback"]}'
```

```json
{ "client_id": "3f9c…", "client_name": "Acme", "redirect_uris": ["https://acme.com/proxy/callback"], "token_endpoint_auth_method": "none" }
```

Keep the `client_id` beside the username. A redirect is `https://`, or
`http://` on the loopback for an app on the person's own machine. If a later
token exchange answers `invalid_client`, the address no longer knows you:
register again.

### 3. Send the person to their address

Make a PKCE verifier (43–128 characters of `[A-Za-z0-9-._~]`) and its S256
challenge, keep the verifier with your `state`, and redirect the browser:

```text
https://alice.proxy.ing/oauth/authorize
  ?response_type=code
  &client_id=3f9c…
  &redirect_uri=https://acme.com/proxy/callback
  &code_challenge=E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM
  &code_challenge_method=S256
  &state=<your nonce>
```

The person sees a page at their address — **Acme wants to connect to
alice.proxy.ing. Let it in from Proxy on your Mac or phone, or reject it
there.** — and Proxy shows the ask on every one of their devices. They tap
**Let it**, and the page sends them back to you, naming the address that
let you in (`iss`, RFC 9207) and your client id there:

```text
https://acme.com/proxy/callback?code=…&state=<your nonce>&iss=https://alice.proxy.ing&client_id=3f9c…
```

So a client that reached the person some other way — a deep link into
Proxy, which asks the person's own node on your behalf — learns where to
redeem its code from the answer itself.

If they do not, you get `?error=access_denied&state=…`. An ask nobody answers
goes away after fifteen minutes.

### 4. Redeem the code

Within ten minutes, once, from the client that asked:

```bash
curl -X POST https://alice.proxy.ing/oauth/token \
  -d grant_type=authorization_code \
  -d code=… \
  -d redirect_uri=https://acme.com/proxy/callback \
  -d client_id=3f9c… \
  -d code_verifier=dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk
```

```json
{ "access_token": "…", "token_type": "Bearer" }
```

The token does not expire. Keep it the way you keep any credential, sealed
at rest, and never show it to the browser.

### 5. Use their Proxy

```python
from openai import OpenAI

proxy = OpenAI(base_url="https://alice.proxy.ing/inference/v1", api_key=token)
models = proxy.models.list()                # what their Macs serve right now
reply = proxy.chat.completions.create(
    model=models.data[0].id,
    messages=[{"role": "user", "content": "Summarise my week."}],
)
```

Their models are whatever their Proxy serves — local models on their own
hardware, or the cloud providers they connected — so read `/models` rather
than assuming one.

### 6. Let go

```bash
curl -X POST https://alice.proxy.ing/oauth/revoke -d token=…
```

The person can also remove you in Proxy, under proxy.ing → MCP access →
Connected. From the next request on, the token answers `401`.

## A Proxy at another address as your client

Not every client has a browser. A Proxy at another address, one that wants
to seat the person's Proxy in a party it hosts, is a client like any other:
it registers, it asks, it redeems a code, it holds a bearer. It only cannot
send anyone anywhere. So it asks for the answer in JSON instead of the page.

### Ask without a browser

Send the same `/oauth/authorize` query with one header:

```bash
curl 'https://alice.proxy.ing/oauth/authorize?response_type=code&client_id=3f9c…&redirect_uri=…&code_challenge=…&code_challenge_method=S256&state=…' \
  -H 'accept: application/json'
```

```json
{ "ask": "ask_7d1e…", "client_name": "The Proxy Company at official.proxy.ing", "poll": "/oauth/ask/ask_7d1e…" }
```

The ask is the same ask the page would have made, and Proxy shows it on the
person's devices the same way. Poll `poll` every few seconds. It answers
`{"status":"waiting"}` until the person decides, then
`{"status":"let_in","redirect":"…"}`, where `redirect` is the link the browser
would have been sent to: read `code` and `state` from its query and redeem
the code at `/oauth/token` exactly as in step 4. A refusal is
`{"status":"refused","redirect":"…"}` with `error=access_denied` in that
query. An ask nobody answers goes away after fifteen minutes, and the poll
answers `404` `{"status":"gone"}`.

### A party host

A party host registers once at each member's address as
`"<host name> at <host>.proxy.ing"`, with the redirect
`https://<host>.proxy.ing/oauth/party-callback`. It never serves that page:
the redirect is nominal, because the code comes back through the poll. Then
it asks with a scope that says what it is for:

```text
scope=party:<party id>;title=<party title>;host=<host address>;agents=proxy;loadout=default
```

The person's Move reads **The Proxy Company wants to add your Proxy to the
party The Proxy Company**, with a Who goes block naming the agent and the
loadout the host asked for. They tap **Let it** on their Mac or phone. The
token the host gets carries that scope and nothing more.

With it the host can do one thing at that address: open a thread with the
person's Proxy at `/client/v1/threads`, titled `Party: <title>`, and keep
posting to it. Every message the host delivers to that seat lands in this
thread, and every reply comes back from it. The host cannot read the
person's other threads, call their inference, or reach their tools.

On the person's side, that thread is their own private thread with the party
on their node: their Proxy answers from what it knows of their work, and the
person can read and steer it like any thread of theirs. Nobody else can open
it.

### How the person ends it

They remove the connection in Proxy, under proxy.ing, the same place as any
connected client. The host's next call answers `401`, and the host marks the
seat gone. The host can also let go with `/oauth/revoke`, as in step 6.

## What to Show Your Users

Call the button **Connect your Proxy**. Ask for one thing, the username, and
say what happens next: *You will let Acme in from Proxy on your Mac or
phone, then land back here.* When they are back, show the address you are
connected to and a way to disconnect.

A person's Macs may be asleep: an address that does not answer is a `502`
or `503` at the edge, not a refusal. Say so — *alice.proxy.ing did not
answer; is Proxy running on one of your Macs?* — and let them try again.

## Reference

| Endpoint | Method | Body | Answers |
| --- | --- | --- | --- |
| `/.well-known/oauth-authorization-server` | GET | — | RFC 8414 metadata |
| `/.well-known/oauth-protected-resource` | GET | — | RFC 9728 metadata: the address is its own authorization server |
| `/oauth/register` | POST | JSON `client_name`, `redirect_uris` | `201` and the client, or `400` `invalid_client_metadata` / `invalid_redirect_uri` |
| `/oauth/authorize` | GET | query, as above | The page the person answers from; a refusal a client can hear rides back on the redirect |
| `/oauth/authorize` with `Accept: application/json` | GET | query, as above | JSON `ask`, `client_name`, `poll` |
| `/oauth/token` | POST | form `grant_type=authorization_code`, `code`, `redirect_uri`, `client_id`, `code_verifier` | `200` and the token, or `400` `invalid_grant` / `invalid_request`, `401` `invalid_client` |
| `/oauth/revoke` | POST | form `token` | `200` |

Every endpoint answers CORS, so a browser-side client works too, though the
token should live with your server.

The authorization server is open source: the `oauth` module of
[proxy-node-server](https://github.com/TheProxyCompany/proxy-node-server),
the node that runs at every address.
