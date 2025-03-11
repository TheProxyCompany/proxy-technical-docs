# Quickstart

This quickstart guide will help you get up and running with PSE.

## Basic Usage

```python
from proxy_structuring_engine import StructuringEngine, Schema

# Define a simple schema
schema = Schema.from_json_schema({
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "hobbies": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "hobbies"]
})

# Create the structuring engine
engine = StructuringEngine(schema)

# Use with your LLM
response = engine.generate(model, "Tell me about yourself")
print(response)
```