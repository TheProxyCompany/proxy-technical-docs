# Quickstart Guide

This guide will help you get up and running with the Proxy Structuring Engine (PSE) in just a few minutes. We'll cover basic setup and walk through simple examples to demonstrate PSE's core functionality.

## Prerequisites

Before you begin, ensure you have:

- Python 3.8 or higher installed
- PSE installed (see [Installation Guide](installation.md))
- A compatible LLM accessible via one of the supported frameworks (PyTorch, MLX, TensorFlow, or JAX)

## Basic JSON Schema Example

Let's start with a simple example of generating JSON using PSE:

```python
from pse import StructuringEngine
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# 1. Load your model
model_name = "meta-llama/Llama-3-8b-instruct"  # Replace with your model
model = AutoModelForCausalLM.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

# 2. Define a simple JSON schema
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "occupation": {"type": "string"}
    },
    "required": ["name", "age"]
}

# 3. Create a structuring engine from the schema
engine = StructuringEngine.from_json_schema(person_schema)

# 4. Setup your prompt
prompt = "Extract information about Sarah, who is 29 years old and works as a software engineer."
input_ids = tokenizer.encode(prompt, return_tensors="pt")

# 5. Generate structured output
outputs = engine.generate(
    model,
    input_ids,
    max_new_tokens=200,
    temperature=0.7
)

# 6. Decode and print result
result = tokenizer.decode(outputs[0])
print(result)
```

Expected output:
```json
{
  "name": "Sarah",
  "age": 29,
  "occupation": "software engineer"
}
```

## Framework-Specific Examples

### PyTorch Integration

For PyTorch-based models, you can use the specialized `TorchStructuringEngine`:

```python
from pse.util.torch_mixin import TorchStructuringEngine
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "required": ["name"]
}

# Create engine with PyTorch-specific implementation
engine = TorchStructuringEngine.from_json_schema(schema)

# Prepare input
prompt = "Extract information about John who is 25 years old."
input_ids = tokenizer.encode(prompt, return_tensors="pt")

# Generate with PyTorch-specific methods
generated_ids = engine.generate(
    model, 
    input_ids, 
    max_length=100,
    do_sample=True,
    temperature=0.7
)

# Decode output
result = tokenizer.decode(generated_ids[0])
print(result)
```

### MLX Integration (Apple Silicon)

For MLX on Apple Silicon devices:

```python
from pse.util.generate_mlx import MLXStructuringEngine
import mlx.core as mx
from mlx_lm import load, generate

# Load MLX model
model, tokenizer = load("mlx-community/Llama-3-8b-mlx")

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "required": ["name"]
}

# Create engine with MLX-specific implementation
engine = MLXStructuringEngine.from_json_schema(schema)

# Prepare input
prompt = "Extract information about John who is 25 years old."
input_ids = mx.array(tokenizer.encode(prompt))

# Generate with MLX-specific methods
generated_ids = engine.generate(
    model, 
    input_ids, 
    max_length=100,
    temperature=0.7
)

# Decode output
result = tokenizer.decode(generated_ids[0].tolist())
print(result)
```

## Custom Grammar Example

Beyond JSON, PSE can work with any custom grammar:

```python
from pse import Grammar, OneOf, Sequence, ZeroOrMore, Optional
from pse import StructuringEngine
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define a custom grammar for a simple SQL-like command language
sql_grammar = Grammar(
    "sql_query", 
    Sequence(
        "SELECT ",
        OneOf([
            "*",
            Sequence(
                ZeroOrMore(
                    Sequence(
                        Grammar("column_name", r"[a-zA-Z_][a-zA-Z0-9_]*"),
                        Optional(" AS ", Grammar("alias", r"[a-zA-Z_][a-zA-Z0-9_]*")),
                        Optional(", ")
                    )
                )
            )
        ]),
        " FROM ",
        Grammar("table_name", r"[a-zA-Z_][a-zA-Z0-9_]*"),
        Optional(
            " WHERE ",
            Grammar("condition", r"[a-zA-Z0-9_\.]+ (=|>|<|>=|<=|!=) [a-zA-Z0-9_\.]+( AND [a-zA-Z0-9_\.]+ (=|>|<|>=|<=|!=) [a-zA-Z0-9_\.]+)*")
        ),
        ";"
    )
)

# Create engine from custom grammar
engine = StructuringEngine.from_grammar(sql_grammar)

# Prepare prompt for SQL generation
prompt = "Generate a SQL query to get all users who are older than 30."
input_ids = tokenizer.encode(prompt, return_tensors="pt")

# Generate with the SQL grammar
outputs = engine.generate(
    model,
    input_ids,
    max_new_tokens=200,
    temperature=0.7
)

# Decode and print result
result = tokenizer.decode(outputs[0])
print(result)
```

Example output:
```sql
SELECT * FROM users WHERE age > 30;
```

## Composite Engine Example

PSE can combine natural language with structured output using composite engines:

```python
from pse import StructuringEngine, NaturalLanguageEngine
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define JSON schema
weather_schema = {
    "type": "object",
    "properties": {
        "location": {"type": "string"},
        "temperature": {"type": "number"},
        "conditions": {"type": "string"},
        "forecast": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "day": {"type": "string"},
                    "temperature": {"type": "number"},
                    "conditions": {"type": "string"}
                }
            }
        }
    },
    "required": ["location", "temperature", "conditions"]
}

# Create a composite engine with thinking space and structured output
composite_engine = StructuringEngine.create_composite_engine(
    {
        "thinking": NaturalLanguageEngine(),
        "output": StructuringEngine.from_json_schema(weather_schema)
    },
    delimiter_tokens={
        "thinking_to_output": ["\nJSON Output:\n"]
    }
)

# Prepare prompt
prompt = "Generate a weather report for New York. Include current conditions and a 3-day forecast."
input_ids = tokenizer.encode(prompt, return_tensors="pt")

# Generate with composite engine
outputs = composite_engine.generate(
    model,
    input_ids,
    max_new_tokens=500,
    temperature=0.7
)

# Decode and print result
result = tokenizer.decode(outputs[0])
print(result)
```

Example output:
```
I need to generate a weather report for New York with current conditions and a 3-day forecast. The report should include the location (New York), current temperature, current conditions, and a forecast for the next 3 days with day name, temperature, and conditions for each day.

Let me create a structured JSON with this information:

JSON Output:
{
  "location": "New York",
  "temperature": 72,
  "conditions": "Partly Cloudy",
  "forecast": [
    {
      "day": "Tuesday",
      "temperature": 75,
      "conditions": "Sunny"
    },
    {
      "day": "Wednesday",
      "temperature": 68,
      "conditions": "Rainy"
    },
    {
      "day": "Thursday",
      "temperature": 71,
      "conditions": "Cloudy"
    }
  ]
}
```

## Data Extraction Example

PSE is excellent for extracting structured data from unstructured text:

```python
from pse import StructuringEngine
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define a schema for product information
product_schema = {
    "type": "object",
    "properties": {
        "product_name": {"type": "string"},
        "brand": {"type": "string"},
        "price": {"type": "number"},
        "features": {
            "type": "array",
            "items": {"type": "string"}
        },
        "rating": {
            "type": "object",
            "properties": {
                "stars": {"type": "number", "minimum": 0, "maximum": 5},
                "review_count": {"type": "integer"}
            }
        }
    },
    "required": ["product_name", "price"]
}

# Create a structuring engine from the schema
engine = StructuringEngine.from_json_schema(product_schema)

# Product description text
product_text = """
The UltraSound X7 Wireless Headphones by AudioMax deliver exceptional sound quality with noise-cancellation technology. 
These premium headphones retail for $249.99 and feature:
- 30-hour battery life
- Fast charging (10 minutes for 5 hours of playback)
- Bluetooth 5.2 connectivity
- Comfortable memory foam ear cushions
- IPX4 water resistance

With a 4.7-star rating from over 2,300 reviews, the X7 is highly recommended by audio enthusiasts.
"""

# Prepare prompt for extraction
prompt = f"Extract structured product information from the following text:\n\n{product_text}"
input_ids = tokenizer.encode(prompt, return_tensors="pt")

# Generate structured data
outputs = engine.generate(
    model,
    input_ids,
    max_new_tokens=300,
    temperature=0.2
)

# Decode and print result
result = tokenizer.decode(outputs[0])
print(result)
```

Example output:
```json
{
  "product_name": "UltraSound X7 Wireless Headphones",
  "brand": "AudioMax",
  "price": 249.99,
  "features": [
    "30-hour battery life",
    "Fast charging (10 minutes for 5 hours of playback)",
    "Bluetooth 5.2 connectivity",
    "Comfortable memory foam ear cushions",
    "IPX4 water resistance"
  ],
  "rating": {
    "stars": 4.7,
    "review_count": 2300
  }
}
```

## Next Steps

Now that you've seen PSE in action, you can:

- Learn about [Basic Concepts](basic-concepts.md) behind PSE
- Work through a [complete project example](first-project.md)
- Explore [Core Concepts](../core-concepts/state-machine.md) for a deeper understanding
- Learn about [Framework Adapters](../api/framework-adapters.md) for different ML frameworks
- Review the [JSON Schema Guide](../guides/json-schema.md) for more advanced usage