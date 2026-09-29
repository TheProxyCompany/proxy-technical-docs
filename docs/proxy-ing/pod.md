# The Pod: Their Whole Compute Behind One Path

A person with a Proxy address has more than one way to run a model: the
Macs they own, an API key at Anthropic, a second one for work, prepaid
credits at OpenRouter or Fireworks. The pod puts all of it behind one
path at their address:

```text
https://<username>.proxy.ing/inference/pod/v1/...
```

It is the same API as `/inference/v1`, the OpenAI shape with `/models`,
`/chat/completions`, `/responses`, `/completions` and `/embeddings`, and
it takes the same bearer. The difference is who serves the request.

## Who Serves a Request

The person keeps a list of accounts in Proxy, under Providers, called
their pod. Each account is one credential for one provider, with a label,
and the list has an order. A request to `/inference/pod/v1` names a model,
and the address works down the list:

1. The first account whose provider serves that model takes the request.
2. If that account has no key, no credit, is rate limited, or the provider
   is unreachable or failing, the next account takes the request.
3. When the model's own provider has no account left, an aggregator
   account that also serves the model, such as OpenRouter, takes it.
4. A request the provider says is wrong, a `400`, is returned as is. It
   would fail the same way everywhere, so it is not retried.

A model the person serves on their own Macs goes straight to those Macs;
no account is involved.

Every attempt writes one line to the person's ledger: which account took
the request, and whether it served or refused it. The person reads it in
Proxy; a client reads it at `/client/v1/pod/ledger`.

## What Rotates and What Does Not

The pod rotates API keys and prepaid usage credits: a key at Anthropic,
OpenAI, Google, xAI, Fireworks, Moonshot, OpenRouter or any provider in
Proxy's catalog, and the credit balance behind it. Two keys at the same
provider are two accounts in the pod, and the person sets which comes
first.

A consumer subscription the person signs in to, such as Claude Pro or
Max or ChatGPT Plus or Pro, is not an account in the pod. Those
subscriptions are for the vendor's own apps under the vendor's terms, and
the pod does not put a login where an API key goes. When a person wants a
subscription's model behind their address, they add that vendor's API key.

## What a Client Gets

Point an OpenAI client at the pod and read `/models` the way you would at
`/inference/v1`:

```python
from openai import OpenAI

proxy = OpenAI(base_url="https://alice.proxy.ing/inference/pod/v1", api_key=token)
reply = proxy.chat.completions.create(
    model="claude-sonnet-4",
    messages=[{"role": "user", "content": "Summarise my week."}],
)
```

The answer comes from whichever of the person's accounts served it. Your
app does not hold a provider key, does not pick a provider, and does not
find out when the person swaps one account for another.

When nothing in the pod serves the model, the address answers `402` and
says so:

```json
{ "detail": "No account in your pod serves 'claude-sonnet-4'. Add one in Proxy under Providers." }
```

When every account refused, the answer carries the last refusal's status
and lists each account's reason, so the person can see which key ran dry.

## Managing the Pod

Proxy manages the pod on the Mac. A client the person let in can manage
it through the client API:

| Route | Purpose |
| --- | --- |
| `GET /client/v1/pod/accounts` | The pod, first to last |
| `POST /client/v1/pod/accounts` | Add an account: `provider`, `label`, `credential_key` |
| `PUT /client/v1/pod/accounts/order` | Set the order: `ids`, first to last |
| `DELETE /client/v1/pod/accounts/:id` | Take an account out |
| `GET /client/v1/pod/ledger` | The newest ledger lines first, `limit` up to 1000 |

The `credential_key` names an entry in the person's keychain. The secret
itself never passes through the address; Proxy puts it in the keychain on
the Mac.
