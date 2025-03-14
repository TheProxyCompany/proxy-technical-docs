# Proxy Structuring Engine

The **Proxy Structuring Engine** (PSE) is a system for dynamically constrained natural language generation.

It compiles rules and schemas into efficient hierarchical state machines that dynamically filter token probabilities during generation, guaranteeing structurally valid outputs while preserving natural language fluency.

## Use Cases
- **Tool Calling** - Generate precise, validated parameters for function calls
- **API Integration** - Guarantee well-formed outputs for seamless system interoperability
- **Synthetic Data** - Create diverse, schema-conformant datasets for training
- **Structured Output** - Enforce type-safe results for reliable downstream processing
- **Agent Frameworks** - Constrain agent actions and reasoning (see [Proxy Base Agent](https://github.com/TheProxyCompany/proxy-base-agent))

## Key Points
- **Dynamic Validation** - A hierarchical state machine validates each token generated, ensuring correctness during generation
- **Token Healing** - Automatically recovers from tokenization mismatches, maintaining structural integrity
- **Parallel Generation** - Explores multiple potential output paths concurrently, maximizing quality within constraints
- **Minimal Overhead** - Adds less than 20ms per token, making it suitable for latency-sensitive applications
- **Schema Versatility** - Supports JSON Schema, Pydantic models, custom grammars, and custom state machines for maximum flexibility
- **Framework Agnostic** - Integrates with PyTorch, MLX, TensorFlow, JAX, and more

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
engine.configure(User.schema())

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
