# Multimodal Input

Multimodal requests use Responses-style message items with `input_text` and
`input_image` content parts. Images are sent as data URLs.

Use a vision-capable model for these examples.

## Python Client

```python
import base64
from pathlib import Path

from orchard.engine.inference_engine import InferenceEngine

MODEL = "moondream/moondream3-preview"
IMAGE_PATH = Path("image.jpg")

image_data = base64.b64encode(IMAGE_PATH.read_bytes()).decode("utf-8")
image_url = f"data:image/jpeg;base64,{image_data}"

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    response = client.responses(
        MODEL,
        input=[
            {
                "type": "message",
                "role": "user",
                "content": [
                    {"type": "input_image", "image_url": image_url},
                    {"type": "input_text", "text": "What is shown in this image?"},
                ],
            }
        ],
        temperature=0.0,
        max_output_tokens=96,
    )
    print(response.output_text)
```

## HTTP

```bash
curl http://127.0.0.1:8000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "moondream/moondream3-preview",
    "input": [
      {
        "type": "message",
        "role": "user",
        "content": [
          {"type": "input_text", "text": "What is shown in this image?"},
          {"type": "input_image", "image_url": "data:image/jpeg;base64,..."}
        ]
      }
    ],
    "temperature": 0.0,
    "max_output_tokens": 96
  }'
```

## Content Parts

| Type | Fields |
| --- | --- |
| `input_text` | `text` |
| `input_image` | `image_url`, optional `detail` |

`detail` can be `auto`, `low`, or `high`.

## Related

- [Client example](client.md)
- [Server example](server.md)
- [Streaming](streaming.md)
