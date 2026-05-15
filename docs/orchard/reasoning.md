# Reasoning Levels

Some Orchard model profiles support native thinking. For those models, reasoning
effort controls how much work the model can spend before answering.

## Effort Values

| Effort | Use it for |
| --- | --- |
| `minimal` | Fast classification, extraction, or routing |
| `low` | Simple Q&A and short transformations |
| `medium` | Normal analysis and planning |
| `high` | Difficult reasoning, code, math, or tool plans |

Passing `reasoning=True` uses `medium`.

## Responses API

```python
from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    response = client.responses(
        MODEL,
        input="Solve this carefully: if a train leaves at noon...",
        reasoning={"effort": "high"},
        temperature=0.0,
        max_output_tokens=256,
    )
    print(response.output_text)
```

You can also pass an effort string:

```python
response = client.responses(
    MODEL,
    input="Classify this message.",
    reasoning="minimal",
    max_output_tokens=32,
)
```

## Direct Chat Client

For direct chat calls, pass `reasoning_effort`.

```python
response = client.chat(
    MODEL,
    [{"role": "user", "content": "Plan a small database migration."}],
    reasoning_effort="medium",
    temperature=0.0,
    max_generated_tokens=256,
)
```

## HTTP

```bash
curl http://127.0.0.1:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "google/gemma-4-E2B-it",
    "input": "Plan a small database migration.",
    "reasoning": {"effort": "medium"},
    "temperature": 0.0,
    "max_output_tokens": 256
  }'
```

## Streaming Reasoning Events

Responses streams can include reasoning events when the model emits reasoning
content.

```python
events = client.responses(
    MODEL,
    input="Think through a migration plan.",
    reasoning={"effort": "high"},
    stream=True,
    max_output_tokens=256,
)

for event in events:
    if event.type == "response.reasoning.delta":
        print("[reasoning]", event.delta)
    elif event.type == "response.output_text.delta":
        print(event.delta, end="", flush=True)
```

If a model profile does not support native thinking, Orchard runs the request as
a normal generation request.

## Related

- [Client example](client.md)
- [Streaming](streaming.md)
- [Tool use](tool-use.md)
