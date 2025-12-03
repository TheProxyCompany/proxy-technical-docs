# Proxy State Engine

The **Proxy State Engine** (PSE) is a system for dynamically constrained natural language generation.

It compiles rules and schemas into efficient hierarchical state machines that dynamically filter token probabilities during generation, guaranteeing structurally valid outputs while preserving natural language fluency.

## Use Cases
- **Tool Calling** - Generate precise, validated parameters for function calls
- **API Integration** - Guarantee well-formed outputs for seamless system interoperability
- **Synthetic Data** - Create diverse, schema-conformant datasets for training
- **Structured Output** - Enforce type-safe results for reliable downstream processing
- **Agent Frameworks** - Constrain agent actions and reasoning (see [Proxy Base Agent](https://github.com/TheProxyCompany/proxy-base-agent))

## Key Points
- **100% Structural Guarantee** - Eliminate schema violations, parsing errors, and malformed outputs. Enables reliable downstream processing and state management.
- **Handles Complexity & Recursion** - Reliably generate deeply nested JSON, valid code, or custom recursive formats via the core HSM engine.
- **Flexible Schema Definition** - Configure instantly using Pydantic models, JSON Schema, Python function signatures, or compose custom structures with pse.types.
- **Robust & Resilient** - Built-in Token Healing recovers from minor tokenization artifacts. Principled path selection resolves ambiguity deterministically.
- **High-Performance C++ Core** - Optimized HSM engine delivers guaranteed structure with minimal latency (~20ms/token overhead).
- **Model & Framework Agnostic** - Integrates with any local LLM stack via standard generation hooks. Optional mixins simplify transformers integration.

## Getting Started

```python
from pse import StructuringEngine
from pydantic import BaseModel
from transformers import AutoTokenizer

# 1. Define your desired output structure
class User(BaseModel):
    name: str
    age: int

# 2. Initialize the tokenizer and engine
tokenizer = AutoTokenizer.from_pretrained("your-model-name")
engine = StructuringEngine(tokenizer)

# 3. Configure the engine with your schema
engine.configure(User)

# 4. Integrate with your generation loop
# (Example using Hugging Face Transformers)
output = model.generate(
    ...,
    logits_processor=[engine.process_logits],
    sampler=engine.sample, # Use the engine's sampling method for multi-token generation
)

# 5. Extract the structured output
structured_user = engine.get_structured_output(User, raise_on_error=True)
print(structured_user)

```

## Open Source
PSE is released under the Apache 2.0 license.

We enthusiastically welcome community contributions and collaborations.

[Explore the Code](https://github.com/TheProxyCompany/proxy-structuring-engine){: .md-button .md-button--primary }
