# Batching

Batching lets Orchard process multiple prompts in one request. Use it when the
prompts share the same model and you want better throughput.

Orchard batches at the API boundary and the IPC boundary. The direct clients
build one batch request with all prompts, PIE receives prompt indexes for each
prompt, and streaming deltas carry `prompt_index` so callers can demultiplex
results.

## Python Client Batch

Pass a list of conversations to `client.chat`. The response is a list in the
same order.

```python
from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

conversations = [
    [{"role": "user", "content": "Reply with one cold color."}],
    [{"role": "user", "content": "Reply with one warm color."}],
]

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    responses = client.chat(
        MODEL,
        conversations,
        temperature=0.0,
        max_generated_tokens=16,
    )

    for response in responses:
        print(response.text)
```

## HTTP Batch

For `/v1/chat/completions`, send `messages` as a list of conversations.

```bash
curl http://127.0.0.1:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "google/gemma-4-E2B-it",
    "messages": [
      [{"role": "user", "content": "Say hello politely."}],
      [{"role": "user", "content": "Give me a fun fact about space."}]
    ],
    "temperature": 0.0,
    "max_completion_tokens": 24
  }'
```

The response `choices` array contains one choice per prompt.

## Heterogeneous HTTP Batch

Some generation fields can be sent as per-prompt lists. Each list must match
the batch size.

```json
{
  "model": "google/gemma-4-E2B-it",
  "messages": [
    [{"role": "user", "content": "Respond with a single word greeting."}],
    [{"role": "user", "content": "List three colors separated by commas."}]
  ],
  "temperature": [0.0, 0.0],
  "max_completion_tokens": [1, 8],
  "stop": [["!"], ["."]]
}
```

If a per-prompt list has the wrong length, the server returns `422`.

Fields such as `temperature`, `max_completion_tokens`, `stop`, tools, response
format, task, reasoning, and candidate settings can vary per prompt when the
server route supports the field.

## Streaming Batch Output

Streaming chat deltas include `prompt_index`. Use it to route each token to the
right output buffer.

## Rust Batch Path

`orchard-rs` exposes `achat_batch`, `achat_batch_with_params`, and
`aembed_batch`. These send all prompts in one IPC message and return responses
in prompt order.

```rust
let result = client
    .achat_batch(
        "google/gemma-4-E2B-it",
        conversations,
        params,
        false,
    )
    .await?;
```

Use `achat_batch_with_params` when each prompt needs its own sampling
parameters. Use `stream: true` when the caller wants deltas as soon as each
prompt produces tokens.

## Related

- [Production use](production.md)
- [Streaming](streaming.md)
- [Server example](server.md)
- [Structured output](structured-output.md)
