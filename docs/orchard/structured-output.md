# Structured Output

Use structured output when the model must return JSON that matches a schema.
Orchard supports structured output from chat completions and from the Responses
API.

## Responses API

```python
import json

from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

schema = {
    "type": "object",
    "properties": {
        "capital": {"type": "string"},
        "population": {"type": "integer"},
    },
    "required": ["capital", "population"],
}

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    response = client.responses(
        MODEL,
        input="What is the capital of France and its approximate population?",
        temperature=0.0,
        max_output_tokens=64,
        text={
            "format": {
                "type": "json_schema",
                "name": "city_info",
                "schema": schema,
                "strict": True,
            }
        },
    )

    data = json.loads(response.output_text)
    print(data["capital"])
```

## Chat Completions

```python
import json

from orchard.engine.inference_engine import InferenceEngine

MODEL = "google/gemma-4-E2B-it"

schema = {
    "type": "object",
    "properties": {
        "summary": {"type": "string"},
        "score": {"type": "number", "minimum": 0.0, "maximum": 1.0},
    },
    "required": ["summary", "score"],
}

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    response = client.chat(
        MODEL,
        [{"role": "user", "content": "Summarize why local inference matters."}],
        temperature=0.0,
        max_generated_tokens=96,
        response_format={
            "type": "json_schema",
            "json_schema": {
                "name": "local_inference_summary",
                "schema": schema,
                "strict": True,
            },
        },
    )

    data = json.loads(response.text)
    print(data)
```

## HTTP Responses

```bash
curl http://127.0.0.1:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "google/gemma-4-E2B-it",
    "input": "What is the capital of France and its approximate population?",
    "temperature": 0.0,
    "max_output_tokens": 64,
    "text": {
      "format": {
        "type": "json_schema",
        "name": "city_info",
        "schema": {
          "type": "object",
          "properties": {
            "capital": {"type": "string"},
            "population": {"type": "integer"}
          },
          "required": ["capital", "population"]
        },
        "strict": true
      }
    }
  }'
```

## Related

- [Client example](client.md)
- [Server example](server.md)
- [Tool use](tool-use.md)
