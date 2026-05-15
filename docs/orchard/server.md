# Orchard Server

Use the server when another process needs HTTP, `curl`, the OpenAI SDK, batched
requests, model status, or an OpenAI-compatible client.

## Start The Server

```bash
orchard serve --model google/gemma-4-E2B-it --host 127.0.0.1 --port 8000
```

Preload more than one model by passing multiple model IDs:

```bash
orchard serve --model google/gemma-4-E2B-it meta-llama/Llama-3.1-8B-Instruct
```

## Chat With Curl

```bash
curl http://127.0.0.1:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "google/gemma-4-E2B-it",
    "messages": [
      {"role": "user", "content": "Write one sentence about local AI."}
    ],
    "temperature": 0.0,
    "max_completion_tokens": 64
  }'
```

## Responses With Curl

```bash
curl http://127.0.0.1:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "google/gemma-4-E2B-it",
    "input": "Explain local inference in two sentences.",
    "temperature": 0.0,
    "max_output_tokens": 96
  }'
```

## OpenAI SDK

```python
from openai import OpenAI

client = OpenAI(base_url="http://127.0.0.1:8000/v1", api_key="orchard")

response = client.chat.completions.create(
    model="google/gemma-4-E2B-it",
    messages=[{"role": "user", "content": "Hello from Orchard."}],
    temperature=0.0,
    max_completion_tokens=64,
)
print(response.choices[0].message.content)
```

## Model Status

List loaded and available models:

```bash
curl http://127.0.0.1:8000/v1/models
```

Check one model's readiness:

```bash
curl http://127.0.0.1:8000/v1/models/google%2Fgemma-4-E2B-it/status
```

Model IDs that contain `/` should be URL-encoded when they are used as a path
segment.

## Server Routes

| Route | Purpose |
| --- | --- |
| `/v1/chat/completions` | OpenAI-compatible chat completions |
| `/v1/completions` | OpenAI-compatible text completions |
| `/v1/responses` | Responses-style object and stream API |
| `/v1/embeddings` | Embedding vectors |
| `/v1/models` | Loaded and available models |
| `/v1/models/:model_id/status` | Model readiness |

## Stop The Engine

```bash
orchard engine stop
```

## Related

- [Client example](client.md)
- [Production use](production.md)
- [Streaming](streaming.md)
- [Batching](batching.md)
- [Multimodal input](multimodal.md)
