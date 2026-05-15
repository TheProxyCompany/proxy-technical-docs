# Getting Started With Orchard Python

This guide runs Orchard directly from Python. It does not start an HTTP server.

## Install

```bash
uv venv
source .venv/bin/activate
uv pip install orchard
```

## Run A Prompt

Create `hello_orchard.py`:

```python
from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    response = client.chat(
        MODEL,
        [{"role": "user", "content": "Write one sentence about local AI."}],
        temperature=0.0,
        max_generated_tokens=64,
    )
    print(response.text)
```

Run it:

```bash
python hello_orchard.py
```

On first use, Orchard downloads the engine binary and the model weights. Later
runs reuse the cached files.

## Next Examples

- [Client example](client.md) covers chat, Responses, sync calls, and async
  calls.
- [Server example](server.md) covers `orchard serve`, `curl`, and the OpenAI
  SDK.
- [Streaming](streaming.md) covers sync and async token streams.
- [Multimodal input](multimodal.md) covers text plus image requests.
- [Batching](batching.md) covers multiple prompts in one request.
- [Structured output](structured-output.md) covers JSON schema constrained
  output.
- [Tool use](tool-use.md) covers function calling and tool result continuation.
- [Reasoning levels](reasoning.md) covers `minimal`, `low`, `medium`, and
  `high` reasoning effort.

## Stop The Engine

```bash
orchard engine stop
```

## Requirements

- macOS 14 or newer
- Apple Silicon Mac
- Python 3.12 or newer
- Disk space for the engine binary and model weights
