# Proxy Structuring Engine

The **Proxy Structuring Engine** (PSE) is a technology that transforms stochastic language models into deterministic systems for generating reliable structured outputs.

## What is PSE?

PSE addresses a fundamental challenge in working with large language models: ensuring that they produce outputs that conform to specific structures while preserving their creative capabilities.

```python
from proxy_structuring_engine import StructuringEngine, Schema

# Define a schema for the structured output
schema = Schema.from_json_schema({
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "interests": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "interests"]
})

# Create a structuring engine with the schema
engine = StructuringEngine(schema)

# Generate structured output from the LLM
result = engine.generate(model, "Tell me about yourself")
```

## Key Features

- **State Machine Architecture**: PSE uses a state machine derived from your schema to guide generation
- **Token Healing**: Automatically fixes minor generation errors
- **Framework Agnostic**: Works with PyTorch, MLX, TensorFlow, and JAX
- **Minimal Overhead**: Designed for production use with minimal performance impact

## Get Started

- [Overview](introduction/overview.md)
- [Installation](getting-started/installation.md)
- [Quickstart](getting-started/quickstart.md)