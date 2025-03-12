# Quickstart

This quickstart guide will help you get up and running with PSE in just a few minutes. We'll cover the basic workflow and show you how to generate structured outputs with your favorite language model.

## Installation

First, install PSE using pip:

```bash
pip install proxy-structuring-engine
```

For specific framework support, include the appropriate extras:

```bash
# For PyTorch support
pip install "proxy-structuring-engine[torch]"

# For MLX support (Apple Silicon)
pip install "proxy-structuring-engine[mlx]"

# For TensorFlow support
pip install "proxy-structuring-engine[tensorflow]"

# For JAX support
pip install "proxy-structuring-engine[jax]"
```

## Basic Workflow

The basic workflow for using PSE involves three main steps:

1. **Define your schema** - Specify the structure you want your output to follow
2. **Create the engine** - Initialize a StructuringEngine with your schema 
3. **Generate structured output** - Use the engine with your language model

## Example with PyTorch

Here's a complete example using PyTorch and HuggingFace Transformers:

```python
from proxy_structuring_engine import StructuringEngine
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# 1. Load your model and tokenizer
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# 2. Define your schema using JSON Schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "hobbies": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "hobbies"]
}

# 3. Create the StructuringEngine
engine = StructuringEngine.from_json_schema(schema)

# 4. Prepare your input
prompt = "Extract information about Sarah, who is 29 and enjoys hiking, reading, and photography."
input_ids = tokenizer.encode(prompt, return_tensors="pt")

# 5. Generate structured output
outputs = engine.generate(model, input_ids, max_new_tokens=200)
structured_result = tokenizer.decode(outputs[0], skip_special_tokens=True)

print(structured_result)
# Output: {"name": "Sarah", "age": 29, "hobbies": ["hiking", "reading", "photography"]}
```

## Alternative Schema Sources

PSE supports various ways to define your schema:

### Using Pydantic Models

```python
from proxy_structuring_engine import StructuringEngine
from pydantic import BaseModel, Field
from typing import List

# Define schema using Pydantic
class Person(BaseModel):
    name: str
    age: int = Field(ge=0)
    hobbies: List[str]

# Create engine from Pydantic model
engine = StructuringEngine.from_pydantic(Person)
```

### Using TypedDict

```python
from proxy_structuring_engine import StructuringEngine
from typing import TypedDict, List

# Define schema using TypedDict
class Person(TypedDict):
    name: str
    age: int
    hobbies: List[str]

# Create engine from TypedDict
engine = StructuringEngine.from_typed_dict(Person)
```

### Using Dataclasses

```python
from proxy_structuring_engine import StructuringEngine
from dataclasses import dataclass
from typing import List

# Define schema using dataclass
@dataclass
class Person:
    name: str
    age: int
    hobbies: List[str]

# Create engine from dataclass
engine = StructuringEngine.from_dataclass(Person)
```

## Generation Parameters

PSE supports various parameters to control the generation process:

```python
outputs = engine.generate(
    model,
    input_ids,
    max_new_tokens=200,           # Maximum number of tokens to generate
    temperature=0.7,              # Control randomness (lower = more deterministic)
    top_p=0.95,                   # Nucleus sampling parameter
    token_healing=True,           # Enable token healing for more robust generation
    return_incomplete=False,      # Don't return incomplete outputs
    early_stopping=True           # Stop when a valid structure is completed
)
```

## Advanced Usage: Framework-Specific Adapters

For optimal performance, use framework-specific adapters:

### PyTorch

```python
from proxy_structuring_engine import StructuringEngine
from proxy_structuring_engine.adapters import PyTorchAdapter

adapter = PyTorchAdapter(device="cuda:0", dtype=torch.float16)
engine = StructuringEngine.from_json_schema(schema, adapter=adapter)
```

### MLX (Apple Silicon)

```python
from proxy_structuring_engine import StructuringEngine
from proxy_structuring_engine.adapters import MLXAdapter
import mlx.core as mx

adapter = MLXAdapter(dtype=mx.float16)
engine = StructuringEngine.from_json_schema(schema, adapter=adapter)
```

## Processing Outputs

If you need to parse the generated JSON into a Python object:

```python
import json

# Parse the generated JSON
result_dict = json.loads(structured_result)
print(f"Name: {result_dict['name']}")
print(f"Age: {result_dict['age']}")
print(f"Hobbies: {', '.join(result_dict['hobbies'])}")
```

Or use Pydantic for validation:

```python
from pydantic import BaseModel
from typing import List

class Person(BaseModel):
    name: str
    age: int
    hobbies: List[str]

# Parse and validate in one step
person = Person.parse_raw(structured_result)
print(f"Name: {person.name}")
print(f"Age: {person.age}")
print(f"Hobbies: {', '.join(person.hobbies)}")
```

## Next Steps

- Learn more about [State Machine Architecture](../core-concepts/state-machine.md)
- Understand [Token Healing](../core-concepts/token-healing.md) for robust generation
- Explore the [StructuringEngine API](../api/structuring-engine.md) for advanced options
- See the [Framework Adapters](../api/framework-adapters.md) documentation for framework-specific optimizations