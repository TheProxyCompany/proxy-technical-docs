# Connect a Proxy Address to Your App

Your users bring their own compute. A person with a Proxy address,
`https://alice.proxy.ing`, runs their own agent, tools and models on their
own Macs, and that address is its own OAuth 2.1 authorization server. Your
app asks for the username, sends the person to their address, and they let
your app in from Proxy on their Mac or phone: one tap, nothing to paste.
From then on your app calls what it asked for with the bearer their address
issued, for thirty days, and they can take it back whenever they like.

There is nothing to register with The Proxy Company. Addresses running a
compatible Proxy version expose the protocol below. Before offering a connection,
check the address's authorization-server metadata for the endpoints and
capabilities your app needs. If metadata is unavailable, say that the address
could not offer this connection: ask the person to check that Proxy is running
and up to date, then let them retry. Do not treat a missing or unreachable
metadata endpoint as a refusal. This guide does not establish which version
every live address is running.

## What Your App Gets

| Surface | At | Speaks |
| --- | --- | --- |
| Threads | `https://<username>.proxy.ing/client/v1/threads` | The client API: open a thread with one of the person's agents, read it, post in it |
| Inference | `https://<username>.proxy.ing/inference/v1/...` | The OpenAI API: `/models`, `/chat/completions`, `/responses` |
| Tools | `https://<username>.proxy.ing/mcp/proxy` | MCP over HTTP: the person's Life Map, Moves, parties, integrations |

All take `Authorization: Bearer <token>`. A request without one answers
`401` with a `WWW-Authenticate` header that names the address's metadata and
the scope that surface needs, which is how MCP clients such as Claude,
Claude Code and Cursor find the flow on their own: add
`https://<username>.proxy.ing/mcp/proxy` and the person is asked to let them
in.

## What Your App Asks For

A token opens only what its scope names. The scope is a space-separated set
of these words, each one family of paths at the address:

| Scope | Opens | The person reads |
| --- | --- | --- |
| `threads` | `/client/v1/threads`, the agents to pick one, the content that rides in a message | open threads with your agents and read and post in them |
| `life-map-read` | `/client/v1/graph/map`, `/client/v1/timeline` | read your Life Map |
| `life-map-write` | `/client/v1/graph/nodes`, and `/mcp/proxy`, the tools that write it | change your Life Map, and use your Proxy's tools |
| `computer` | `/mcp/computer`, `/mcp/phone` | control your computer and phone |
| `mail` | `/mcp/mail` | read and send your mail |
| `messages` | `/mcp/messages` | read and send your messages |
| `inference` | `/inference` | run your models |
| `moves` | `/client/v1/moves`, resolving one | see your Moves, and resolve one with a device signature |

Ask for what your app needs and no more; the person sees the list on the
ask, in those words, and decides on it. Making a Move is the person's
gesture: `POST /client/v1/moves/<id>/resolve` and the `proxy_make_move`
tool answer `403` to a bearer alone, the person's own account bearer
included, with `This Move can only be made from Proxy`. Proxy on their Mac
resolves locally, and their phone signs its resolve with the device key it
enrolled with (`x-proxy-device-signature` over the method, the path, the
minute and the body, verified against the keys the Mac trusts). A token
with the `moves` scope sees Moves; it does not make them. An ask that names no scope gets
`threads`, which is what a dashboard needs to ask the person's Proxy a
question. Everything else at the address (the person's own app routes,
their parties, their shares, their calendar) stays closed to every token; a
word that is not in the table is refused as `invalid_scope` on your
redirect. The separate party connection described below uses a purpose-specific
scope. The metadata lists the general-purpose scopes under `scopes_supported`.

A request outside the scope answers `403` with
`WWW-Authenticate: Bearer error="insufficient_scope", scope="<what it needs>"`
and a body that says so in words; the token itself is still good. Ask again
with the wider scope and the person decides again.

A general-purpose token lasts thirty days from issue, and the answer says so
(`expires_in`). After that it answers `401` like any bad bearer, and your
app sends the person to their address again: the same ask, the same tap.
There is no refresh token, on purpose. A refresh token is a second secret
that extends access with nobody in the loop, and the point of the expiry is
that the person is in the loop: every thirty days they see who is connected,
what it asks for, and say yes or no.

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

Check that the returned `issuer` exactly matches the Proxy address the person
chose. Keep that issuer and its metadata associated with this connection; do
not replace them with values from a later callback.

### 2. Register your app, once per address

Say what you are called (the person is asked whether to let you in by that
name) and where the person comes back to. Clients are public: there is no
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
challenge. Generate an unpredictable, one-use `state` and save it with the
verifier, the expected issuer, registered client ID, exact redirect URI, and
the trusted issuer's metadata. Bind this pending request to the user session
that started it, then redirect the browser:

```text
https://alice.proxy.ing/oauth/authorize
  ?response_type=code
  &client_id=3f9c…
  &redirect_uri=https://acme.com/proxy/callback
  &code_challenge=E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM
  &code_challenge_method=S256
  &state=<your nonce>
```

Add `&scope=threads%20inference` for what your app needs (see above); left
out, it is `threads`.

The person sees a page at their address: **Acme wants to connect to
alice.proxy.ing and be sent back to acme.com. It asks to open threads with
your agents and read and post in them, and run your models, for thirty days.
Let it in from Proxy on your Mac or phone, or reject it there.** Proxy
shows the ask on every one of their devices as a Move that names you, where
you send them back to, and what you asked for. When your name is not one
your origin would give you (`Claude` sent back to `evil.example`), the Move
leads with the origin, because the name is yours to choose and the origin is
not. They tap **Let it**, and the page sends them back to you, naming the
address that let you in (`iss`, RFC 9207) and your client id there:

```text
https://acme.com/proxy/callback?code=…&state=<your nonce>&iss=https://alice.proxy.ing&client_id=3f9c…
```

Before accepting the callback, match `state` to the pending request in the
same user session and require the returned `iss` and `client_id` to equal the
saved issuer and client ID. Require the callback to arrive at the saved
redirect URI. Reject missing, mismatched, expired, or already-used state,
including on error callbacks. Consume the pending request once; do not redeem
another code for it.

Use the token endpoint from the metadata you already associated with that
trusted issuer. Never choose a token host from the callback's `iss`, a returned
URL, or an unverified deep link, and never send the PKCE verifier to such a
host. A deep-link flow must establish the expected issuer and the same request
bindings before it accepts an authorization result.

If they do not, you get `?error=access_denied&state=…`. An ask nobody answers
goes away after fifteen minutes.

### 4. Redeem the code

After those checks, redeem the code within ten minutes, once, using the saved
client ID, exact redirect URI, and PKCE verifier:

```bash
curl -X POST https://alice.proxy.ing/oauth/token \
  -d grant_type=authorization_code \
  -d code=… \
  -d redirect_uri=https://acme.com/proxy/callback \
  -d client_id=3f9c… \
  -d code_verifier=dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk
```

```json
{ "access_token": "…", "token_type": "Bearer", "expires_in": 2592000, "scope": "threads inference" }
```

For this general-purpose flow, the token lasts thirty days (`expires_in`,
in seconds) and opens the scope it names. Keep it the way you keep any
credential, sealed at rest, and never show it to the browser. (A Proxy holding one for a party seat keeps it
in its own database on the Mac that asked, out of every snapshot; that
database is device local, not sealed.) When it runs out, start again from
step 3.

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

Their models are whatever their Proxy serves, local models on their own
hardware or the cloud providers they connected, so read `/models` rather
than assuming one.

### 6. Let go

```bash
curl -X POST https://alice.proxy.ing/oauth/revoke -d token=…
```

The person can also remove you in Proxy, under proxy.ing → MCP access →
Connected, where each connection shows what it opens and until when. From
the next request on, the token answers `401`.

## Limits

One source (one address at the edge) may register ten clients and open
thirty asks in ten minutes; past that the address answers `429` with
`Retry-After`. Every registration is written to the person's Proxy log with
the source and the origin it sends the person back to.

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
would have been sent to. Treat that URL as an authorization response, not as
a trusted destination: apply the state, issuer, client, and redirect checks in
step 3, then redeem `code` at the saved issuer's token endpoint as in step 4.
A refusal is
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

The person's Move names the host by where the ask is sent back to, never
by the `host` word in the scope: an ask whose `host` is not its redirect
origin gets no Move at all. It reads **Alice wants your Proxy in a party**
when the host's name is one its origin would give it (`Alice` at
`alice.proxy.ing`), and **official.proxy.ing wants your Proxy in a party**
otherwise, with a Who is asking block that says what it calls itself, and
a Who goes block naming the agent and the loadout the host asked for and
what the connection opens. They tap **Let it** on their Mac or phone. The
token the host gets carries that scope, and the address holds it to the
scope. It has no clock: a purpose token opens one thread and nothing else,
so it lasts until the person removes the connection under proxy.ing in
Proxy or the host takes the seat out of the party, and a standing party
does not end in silence on day thirty. The token answer carries no
`expires_in`.

With it the host can do one thing at that address: open one direct thread
with the agent the scope names, `POST /client/v1/threads` with `kind`
`direct` and that one `participant`, titled `Party: <title>`, and then read
and post in that thread: `GET` and `POST` on its `/messages`, `GET` on its
`/queue-idle` and `/events`. Every message the host delivers to that seat
lands in this thread, and every reply comes back from it. Any other request
with that token answers `403` with `this connection opens one party thread
and nothing else`: the person's thread list, any other thread of theirs,
their inference, their tools, a thread with another of their agents. A
`401` means the token itself is gone.

On the person's side, that thread is a direct thread of their own with their
Proxy, titled `Party: <title>`, that they can read and steer like any thread
of theirs. It is not a party in their sidebar and it carries no shared feed;
that comes with the reverse credential, in a later root.

### How either side ends it

The person removes the connection in Proxy, under proxy.ing, the same place
as any connected client. The host's next call answers `401`, the host drops
the bearer and marks the seat gone with one line in the party. The host ends
it by taking the seat out of the party: it revokes the connection on its own
side at once and hands the bearer back with `/oauth/revoke`, as in step 6,
trying again until the address confirms, so the person's list of connections
never shows a host that already dropped them. An address that does not
answer (the edge's `502` or `503` for a Mac that is asleep) is said once in
the party, `could not reach alice`, and the seat waits: the messages go as
one send when the address is back.

## What to Show Your Users

Call the button **Connect your Proxy**. Ask for one thing, the username, and
say what happens next: *You will let Acme in from Proxy on your Mac or
phone, then land back here.* When they are back, show the address you are
connected to and a way to disconnect.

A person's Macs may be asleep: an address that does not answer is a `502`
or `503` at the edge, not a refusal. Say so, *alice.proxy.ing did not
answer; is Proxy running on one of your Macs?*, and let them try again.

## Reference

| Endpoint | Method | Body | Answers |
| --- | --- | --- | --- |
| `/.well-known/oauth-authorization-server` | GET | none | RFC 8414 metadata |
| `/.well-known/oauth-protected-resource` | GET | none | RFC 9728 metadata: the address is its own authorization server, and `scopes_supported` |
| `/oauth/register` | POST | JSON `client_name`, `redirect_uris` | `201` and the client, or `400` `invalid_client_metadata` / `invalid_redirect_uri`, `429` past the limit |
| `/oauth/authorize` | GET | query, as above, with `scope` | The page the person answers from; a refusal a client can hear rides back on the redirect, `invalid_scope` among them; `429` past the limit |
| `/oauth/authorize` with `Accept: application/json` | GET | query, as above | JSON `ask`, `client_name`, `origin`, `scope`, `poll` |
| `/oauth/token` | POST | form `grant_type=authorization_code`, `code`, `redirect_uri`, `client_id`, `code_verifier` | `200` and the token with `scope` (plus `expires_in` for general-purpose tokens); or `400` `invalid_grant` / `invalid_request`, `401` `invalid_client` |
| `/oauth/revoke` | POST | form `token` | `200` |

Every endpoint answers CORS, so a browser-side client works too, though the
token should live with your server.

The authorization server is open source: the `oauth` module of
[proxy-node-server](https://github.com/TheProxyCompany/proxy-node-server),
the node that runs at every address.
