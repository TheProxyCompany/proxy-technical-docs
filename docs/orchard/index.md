# Orchard

Orchard is the production local inference layer for Apple Silicon.

Use `orchard-py` when you want to run a model from Python. Use `orchard-rs`
when you are embedding Orchard in a Rust app or service. Use the HTTP server
when another process needs an OpenAI-compatible endpoint.

Orchard is meant to stay running. The production path is a long-lived engine
process with one or more loaded models, batched requests, streaming deltas,
structured output, tool use, multimodal input, and OpenAI-compatible server
routes.

## Quick Example

```bash
uv venv
source .venv/bin/activate
uv pip install orchard
```

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

See the [getting started guide](getting-started.md) for the shortest path, then
use the focused guides for client calls, server calls, streaming, tools, and
structured output.

## What You Get

- Local inference on Apple Silicon
- Python sync and async clients
- Production batching for higher throughput
- Multiple loaded models in one server process
- Streaming token deltas
- OpenAI Responses-style output objects
- Tool calls and structured output
- Optional OpenAI-compatible HTTP server
- Rust client for app and service integrations
- On-demand model downloads from Hugging Face

## When To Use Each Interface

| Interface | Use it when |
| --- | --- |
| Python client | Your app is written in Python and can call Orchard directly |
| Responses API client | You want typed response objects, event streams, tools, or structured output |
| HTTP server | You need `curl`, the OpenAI SDK, batched HTTP requests, model status, or another process to connect over HTTP |
| Rust client | You are embedding Orchard in a Rust app or service |

## Production Starting Points

| Need | Start with |
| --- | --- |
| Keep a local inference runtime alive | [Production use](production.md) |
| Send many prompts to the same model | [Batching](batching.md) |
| Serve another process over HTTP | [Server example](server.md) |
| Stream tokens or batched deltas | [Streaming](streaming.md) |
| Use typed output or tools | [Structured output](structured-output.md) and [tool use](tool-use.md) |

## Model Starting Points

| Mac | Start with |
| --- | --- |
| 8 GB unified memory | `google/gemma-4-E2B-it` |
| 16-32 GB unified memory | `google/gemma-4-E4B-it` or `Qwen/Qwen3.5-4B` |
| 32 GB+ unified memory | `meta-llama/Llama-3.1-8B-Instruct` |

## Links

- [Getting started](getting-started.md)
- [Production use](production.md)
- [Client example](client.md)
- [Server example](server.md)
- [Streaming](streaming.md)
- [Batching](batching.md)
- [Multimodal input](multimodal.md)
- [Structured output](structured-output.md)
- [Tool use](tool-use.md)
- [Reasoning levels](reasoning.md)
- [Orchard for Rust](rust.md)
- [orchard on PyPI](https://pypi.org/project/orchard/)
- [orchard-py source](https://github.com/TheProxyCompany/orchard-py)
- [orchard-rs source](https://github.com/TheProxyCompany/orchard-rs)
