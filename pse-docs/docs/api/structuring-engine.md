# StructuringEngine API

The `StructuringEngine` class is the primary interface for PSE.

## Basic Usage

```python
from proxy_structuring_engine import StructuringEngine, Schema

# Create a schema
schema = Schema.from_json_schema({...})

# Initialize the engine
engine = StructuringEngine(schema)

# Generate structured output
result = engine.generate(model, prompt)
```

## Methods

### `__init__(schema, **options)`

Initialize a new structuring engine with the given schema.

### `generate(model, prompt, **options)`

Generate structured output using the provided model and prompt.