# How Orchard Runs

Most users do not need to know Orchard's internal project layout. The useful
mental model is simple:

```
Your Python code
  -> Orchard client
  -> Local engine process
  -> Model weights on your Mac
  -> Streamed response
```

The Python client starts or reuses a local engine process, loads the model you
request, submits prompts, and streams results back into your process. The same
engine can serve multiple requests and models during a session.

## Direct Python Client

Use this path for Python apps:

```python
from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    response = client.chat(
        MODEL,
        [{"role": "user", "content": "Hello."}],
        max_generated_tokens=32,
    )
    print(response.text)
```

## HTTP Server

Use this path when another process needs an HTTP API:

```bash
orchard serve --model google/gemma-4-E2B-it
```

That exposes OpenAI-compatible routes under `http://localhost:8000/v1`.

## Local Files

| File or cache | Purpose |
| --- | --- |
| `~/.orchard/` | Cached Orchard engine binary |
| Hugging Face cache | Model weights |
| Process logs | Engine and client diagnostics |

## Shutdown

The engine is reference-counted by Orchard clients. To stop a background engine
manually:

```bash
orchard engine stop
```
