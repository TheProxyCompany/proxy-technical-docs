# Proxy Structuring Engine

<div class="hero-content" style="text-align: center; margin: 2em 0;">
  <p style="font-size: 1.5em; max-width: 800px; margin: 0 auto;">
    Transform stochastic language models into deterministic systems for reliable structured outputs
  </p>
</div>

The **Proxy Structuring Engine** (PSE) is a state-of-the-art technology that addresses a fundamental challenge in working with large language models: ensuring they produce outputs that conform to specific structures while preserving their creative capabilities.

## Key Features

- **State Machine Architecture**: Uses a hierarchical state machine to guide generation according to your schema
- **Token Healing**: Automatically recovers from minor errors to maintain structural validity
- **Framework Agnostic**: Works seamlessly with PyTorch, MLX, TensorFlow, and JAX
- **Minimal Overhead**: Designed for production use with ~20ms per token overhead
- **Schema Flexibility**: Supports JSON Schema, Pydantic models, and custom grammar definitions

## How It Works

PSE uses a novel approach to constrain LLM generation:

1. **Schema Definition**: You define the structure you need using JSON Schema or other formats
2. **State Machine Creation**: PSE converts this schema into a hierarchical state machine
3. **Guided Generation**: During generation, PSE uses the state machine to guide the LLM token-by-token
4. **Token Healing**: If the LLM deviates slightly, PSE applies token healing to recover
5. **Valid Output**: The result is a properly structured output that follows your schema

This approach gives you the best of both worlds: the creative power of LLMs with the reliability of structured systems.

## Quick Example

```python
from proxy_structuring_engine import StructuringEngine, Schema
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "interests": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "interests"]
}

# Create engine
engine = StructuringEngine.from_json_schema(schema)

# Generate
prompt = "Extract information about Sarah, who is 29 and works as a software engineer."
input_ids = tokenizer.encode(prompt, return_tensors="pt")
outputs = engine.generate(model, input_ids, max_new_tokens=200)
result = tokenizer.decode(outputs[0])
print(result)
```

## Use Cases

- **API Integration**: Ensure agents produce valid API calls with correct parameters
- **Data Extraction**: Convert unstructured text to validated structured formats
- **Code Generation**: Generate syntactically valid code in any programming language
- **Report Generation**: Create properly formatted reports with consistent structure
- **Game Systems**: Define and enforce complex rules for game AI

## Documentation

Our comprehensive documentation covers everything you need to understand and implement PSE:

### Introduction

- [Overview](introduction/overview.md) - A complete introduction to PSE
- [Key Features](introduction/key-features.md) - Detailed exploration of PSE's capabilities
- [Use Cases](introduction/use-cases.md) - Real-world applications and examples

### Getting Started

- [Installation](getting-started/installation.md) - Setting up PSE in your environment
- [Quickstart](getting-started/quickstart.md) - Your first PSE implementation
- [Basic Concepts](getting-started/basic-concepts.md) - Understanding PSE fundamentals

### Core Concepts

- [State Machine Architecture](core-concepts/state-machine.md) - How PSE's state machine works
- [Token Healing](core-concepts/token-healing.md) - Understanding PSE's error recovery
- [Type System](core-concepts/type-system.md) - PSE's comprehensive type system

### API Reference

- [StructuringEngine](api/structuring-engine.md) - Complete StructuringEngine API reference
- [Framework Adapters](api/framework-adapters.md) - Framework-specific adapters

## Open-Source

PSE is available under the Apache 2.0 license. We welcome contributions from the community to help improve and extend this technology.

[View on GitHub](https://github.com/TheProxyCompany/proxy-structuring-engine){: .md-button .md-button--primary }
[Read the Docs](introduction/overview.md){: .md-button }