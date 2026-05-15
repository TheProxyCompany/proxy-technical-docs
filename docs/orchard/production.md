# Production Use

Orchard is designed to run as a production local inference service on Apple
Silicon, not only as a notebook demo. The normal shape is a long-lived engine
process with one or more loaded models, requests sent in batches when possible,
and streaming results routed back to the caller as they are produced.

## Production Shape

| Capability | What Orchard provides |
| --- | --- |
| Long-running engine | Start once, keep the process alive, and reuse loaded models across requests |
| Batched requests | Send multiple prompts for the same model in one request |
| High throughput | Batch prompts, stream deltas, and avoid restarting model processes between calls |
| Multiple models | Preload more than one model in the server or load models before direct client calls |
| OpenAI compatibility | Use `/v1/chat/completions`, `/v1/responses`, `/v1/embeddings`, and `/v1/models` |
| Model readiness | Check `/v1/models/:model_id/status` before sending traffic |

## Batch For Throughput

Batching is the main throughput lever. The Python client accepts a list of
conversations, the HTTP server accepts `messages` as a list of conversations,
and the Rust client sends all prompts in one IPC request so PIE can schedule
the work together.

```python
from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

prompts = [
    [{"role": "user", "content": "Write one short product tagline."}],
    [{"role": "user", "content": "Write one short documentation tagline."}],
    [{"role": "user", "content": "Write one short benchmark tagline."}],
]

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    responses = client.chat(
        MODEL,
        prompts,
        temperature=0.0,
        max_generated_tokens=32,
    )

    for response in responses:
        print(response.text)
```

See [batching](batching.md) for HTTP batching, heterogeneous per-prompt
settings, and streaming batch output.

## Serve Multiple Models

Start the HTTP server with every model you want ready for traffic:

```bash
orchard serve \
  --model google/gemma-4-E2B-it meta-llama/Llama-3.1-8B-Instruct \
  --host 127.0.0.1 \
  --port 8000
```

List models:

```bash
curl http://127.0.0.1:8000/v1/models
```

Check one model's readiness:

```bash
curl http://127.0.0.1:8000/v1/models/google%2Fgemma-4-E2B-it/status
```

Model IDs that contain `/` should be URL-encoded when they are used as a path
segment.

## Keep The Engine Hot

For repeated traffic, keep one engine or server process alive instead of
starting a new process per request. The first run may download model files and
initialize the engine. After that, steady-state latency and throughput depend
on model size, hardware, batch size, output length, and whether requests can be
grouped by model.

Use these rules of thumb:

- Load the models you expect to use before serving user traffic.
- Batch prompts that target the same model.
- Stream when the user needs early tokens.
- Set output limits such as `max_generated_tokens` or `max_completion_tokens`.
- Use model status endpoints before routing traffic to a model.

## Related

- [Batching](batching.md)
- [Server example](server.md)
- [Streaming](streaming.md)
- [Orchard for Rust](rust.md)
