# Orchard Python Client

Use the Python client when your app can run Orchard in the same Python process.
The client starts the local engine, loads models, and talks to the engine over
IPC.

## Chat Completion

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

## Responses API

Use Responses when you want a typed output object, event streams, tools,
structured output, or multimodal input.

```python
from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    response = client.responses(
        MODEL,
        input="Explain local inference in two sentences.",
        temperature=0.0,
        max_output_tokens=96,
    )
    print(response.output_text)
```

## Async Client

```python
import asyncio

from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"


async def main() -> None:
    async with InferenceEngine() as engine:
        await engine.load_model(MODEL)
        client = engine.client()
        response = await client.achat(
            MODEL,
            [{"role": "user", "content": "Say hello from Orchard."}],
            temperature=0.0,
            max_generated_tokens=64,
        )
        print(response.text)


asyncio.run(main())
```

## Common Parameters

| Parameter | Used by | Purpose |
| --- | --- | --- |
| `temperature` | Chat and Responses | Sampling randomness |
| `top_p`, `top_k`, `min_p` | Chat and Responses | Token sampling controls |
| `max_generated_tokens` | Chat | Maximum generated tokens |
| `max_output_tokens` | Responses | Maximum generated tokens |
| `stream` | Chat and Responses | Return incremental deltas or events |
| `response_format` | Chat | Structured chat output |
| `text` | Responses | Structured Responses output |
| `tools`, `tool_choice` | Chat and Responses | Function calling |
| `reasoning_effort` | Chat | Native thinking effort for direct chat calls |
| `reasoning` | Responses | Native thinking effort for Responses calls |

## Related

- [Streaming](streaming.md)
- [Batching](batching.md)
- [Structured output](structured-output.md)
- [Tool use](tool-use.md)
- [Reasoning levels](reasoning.md)
