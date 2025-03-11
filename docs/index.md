# Proxy Structuring Engine

<div class="hero-content" style="text-align: center; margin: 2em 0;">
  <p style="font-size: 1.5em; max-width: 800px; margin: 0 auto;">
    A system for repurposing stochastic LLMs as stateful, controllable engines capable of producing reliable structured outputs
  </p>
</div>

The **Proxy Structuring Engine (PSE)** transforms unpredictable language models into dependable tools for production applications, without sacrificing their creative capabilities. PSE addresses the fundamental challenge of ensuring language models produce outputs that conform to specific structural requirements, solving a critical obstacle to LLM adoption in enterprise environments.

## Key Features

- **Guaranteed Structure**: Enforce JSON schema, XML, or custom grammar constraints on LLM outputs
- **Framework Agnostic**: Compatible with PyTorch, MLX, TensorFlow, and JAX
- **Minimal Overhead**: ~20ms per token with zero-copy tensor operations
- **Parallel Exploration**: Handles ambiguous grammar through parallel path exploration
- **Token Healing**: Corrects minor generation errors automatically through partial credit
- **Composable**: Transition seamlessly between natural language and structured output

## How It Works

PSE uses a hierarchical state machine approach to guide LLM generation:

1. Define the required output structure (JSON schema, custom grammar, etc.)
2. The engine constructs a state machine representing valid generation paths
3. During generation, PSE masks invalid token probabilities before sampling
4. Multiple possible interpretations are explored in parallel when ambiguity arises
5. The result is structurally valid output that preserves the LLM's intent

This approach provides the reliability of template-based systems while maintaining the creative power of large language models.

## Getting Started

```python
from pse import StructuringEngine
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define JSON schema
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "occupation": {"type": "string"}
    },
    "required": ["name", "age"]
}

# Create structuring engine
engine = StructuringEngine.from_json_schema(person_schema)

# Generate structured output
prompt = "Extract information about Sarah, who is 29 and works as a software engineer."
input_ids = tokenizer.encode(prompt, return_tensors="pt")
outputs = engine.generate(model, input_ids, max_new_tokens=100)
result = tokenizer.decode(outputs[0])
print(result)
```

## Use Cases

- **Intelligent Agents**: Build reliable agents that interact with APIs and external tools
- **Data Extraction**: Convert unstructured text to structured information
- **Interactive Apps**: Create dynamic experiences with consistent output formats
- **Code Generation**: Produce syntax-constrained code with guaranteed correctness
- **Conversational AI**: Develop chatbots with consistent, structured responses

## Documentation

Our comprehensive documentation covers everything you need to get started with PSE and understand its powerful capabilities:

### Introduction

- [Overview](introduction/overview.md) - A complete introduction to PSE and its approach
- [Key Features](introduction/key-features.md) - Detailed exploration of PSE's capabilities
- [Use Cases](introduction/use-cases.md) - Real-world applications and examples
- [Comparison with Alternatives](introduction/comparison.md) - How PSE compares to other approaches

### Getting Started

- [Installation](getting-started/installation.md) - Setting up PSE in your environment
- [Quickstart](getting-started/quickstart.md) - Your first PSE implementation
- [Basic Concepts](getting-started/basic-concepts.md) - Understanding PSE fundamentals
- [First Project](getting-started/first-project.md) - Build a complete project with PSE

### Core Concepts

- [State Machine Architecture](core-concepts/state-machine.md) - How PSE guides generation
- [Token Healing](core-concepts/token-healing.md) - Handling tokenization inconsistencies

### User Guides

- [JSON Schema Integration](guides/json-schema.md) - Using JSON Schema with PSE

### API Reference

- [StructuringEngine](api/structuring-engine.md) - Complete API reference
- [Framework Adapters](api/framework-adapters.md) - Framework-specific integration

## Open-Source

PSE is available under the Apache 2.0 license. We welcome contributions from the community to help improve and extend this technology.

[View on GitHub](https://github.com/TheProxyCompany/proxy-structuring-engine){: .md-button .md-button--primary }
[Read the Docs](introduction/overview.md){: .md-button }