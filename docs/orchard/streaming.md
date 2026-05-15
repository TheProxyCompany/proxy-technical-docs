# Streaming

Orchard supports streaming from the direct Python client and from the HTTP
server. Chat streams return token deltas. Responses streams return typed events.

## Sync Chat Streaming

```python
from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    stream = client.chat(
        MODEL,
        [{"role": "user", "content": "Count from one to five."}],
        stream=True,
        temperature=0.0,
        max_generated_tokens=64,
    )

    for delta in stream:
        if delta.content:
            print(delta.content, end="", flush=True)
    print()
```

## Async Chat Streaming

```python
import asyncio

from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"


async def main() -> None:
    async with InferenceEngine() as engine:
        await engine.load_model(MODEL)
        client = engine.client()
        stream = await client.achat(
            MODEL,
            [{"role": "user", "content": "Count from one to five."}],
            stream=True,
            temperature=0.0,
            max_generated_tokens=64,
        )

        async for delta in stream:
            if delta.content:
                print(delta.content, end="", flush=True)
        print()


asyncio.run(main())
```

## Sync Responses Text Streaming

Use `responses_text` when you only need text chunks.

```python
from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    for chunk in client.responses_text(
        MODEL,
        input="Write one short paragraph about local inference.",
        temperature=0.0,
        max_output_tokens=96,
    ):
        print(chunk, end="", flush=True)
    print()
```

## Async Responses Event Streaming

Use `aresponses(..., stream=True)` when you need full event data, including
tool call arguments or reasoning deltas.

```python
import asyncio

from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"


async def main() -> None:
    async with InferenceEngine() as engine:
        await engine.load_model(MODEL)
        client = engine.client()
        events = await client.aresponses(
            MODEL,
            input="Write one short paragraph about local inference.",
            stream=True,
            temperature=0.0,
            max_output_tokens=96,
        )

        async for event in events:
            if event.type == "response.output_text.delta":
                print(event.delta, end="", flush=True)
        print()


asyncio.run(main())
```

## HTTP Streaming

```bash
curl -N http://127.0.0.1:8000/v1/responses \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{
    "model": "google/gemma-4-E2B-it",
    "input": "Count from one to five.",
    "stream": true,
    "temperature": 0.0,
    "max_output_tokens": 64
  }'
```

## Batched Streams

When streaming a batched chat request, every delta includes `prompt_index`.
Use it to demultiplex the output for each prompt.

## Related

- [Client example](client.md)
- [Server example](server.md)
- [Batching](batching.md)
- [Tool use](tool-use.md)
