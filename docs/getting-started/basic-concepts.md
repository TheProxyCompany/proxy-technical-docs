# Basic Concepts

This guide introduces the fundamental concepts behind the Proxy Structuring Engine (PSE) to help you understand how it works and how to use it effectively. Understanding these core concepts will help you make the most of PSE's capabilities.

## The Problem PSE Solves

Large Language Models (LLMs) are powerful at generating text, but they struggle with producing outputs that consistently follow specific structures. While you can ask an LLM to generate JSON, XML, or custom formats through prompting, the results are often inconsistent:

- The LLM may omit required fields
- It might produce invalid syntax (missing commas, unmatched brackets)
- Field types might be incorrect (strings where numbers are expected)
- The output may deviate from the requested format entirely

These issues are particularly problematic in production applications where reliability is essential.

## The PSE Approach

PSE solves this problem through a fundamentally different approach than prompt engineering or post-processing. Instead of asking the LLM to produce structured output or fixing its output after generation, PSE **guides the generation process itself** to ensure structural validity.

The key innovation is using hierarchical state machines to constrain the LLM's generation in real-time, ensuring outputs conform to your specified structure while preserving the model's creative capabilities.

## Core Components

Let's explore the key components that make up PSE:

### 1. State Machine Architecture

At the heart of PSE is a hierarchical state machine that represents all possible valid paths through the generation process:

- **States** represent different contexts in the generation process (e.g., "inside a JSON object", "parsing a field name", "parsing an integer")
- **Transitions** define valid moves between states
- **Tokens** are mapped to transitions, determining which ones are valid next

This state machine serves as a blueprint that guides the LLM's generation, ensuring it only produces outputs that follow the defined structure.

### 2. Structuring Engine

The `StructuringEngine` is PSE's main interface, responsible for:

- Converting schemas and grammars into state machines
- Connecting to the underlying LLM
- Managing the generation process
- Providing a user-friendly API

You'll primarily interact with the `StructuringEngine` class when using PSE.

### 3. Type System

PSE includes a comprehensive type system that defines how different data types should be structured:

- **Primitive Types**: String, Number, Integer, Boolean
- **Container Types**: Object, Array
- **Special Types**: Enum, Whitespace, Custom types

The type system is used to build the state machine based on your specified schema or grammar.

### 4. Framework Adapters

PSE is designed to work with multiple ML frameworks through specialized adapters:

- `TorchStructuringEngine` for PyTorch
- `MLXStructuringEngine` for Apple's MLX
- Adapters for TensorFlow and JAX

These adapters ensure PSE integrates seamlessly with your preferred framework.

## Key Mechanisms

### Token Masking

During generation, PSE:

1. Tracks the current state in the state machine
2. Identifies which tokens would be valid next
3. Creates a mask that allows only valid tokens
4. Applies this mask to the LLM's next-token probabilities
5. Lets the LLM sample from the valid tokens
6. Updates the state based on the chosen token

This process ensures that every token generated is consistent with the overall structure, while still allowing the LLM to determine the content within structural constraints.

### Parallel Path Exploration

When the grammar is ambiguous (meaning multiple valid interpretations exist), PSE:

1. Maintains multiple "steppers" (state trackers) simultaneously
2. Each stepper explores a different possible interpretation
3. The system ranks paths based on the LLM's probabilities
4. Less promising paths are pruned for efficiency
5. The most likely valid path is ultimately selected

This parallel exploration enables PSE to handle complex and ambiguous structures effectively.

### Token Healing

For minor generation errors or ambiguous tokenization, PSE employs token healing:

1. If no exact token matches are valid, PSE looks for partial matches
2. It gives "partial credit" to tokens that form valid prefixes
3. This allows recovery from minor tokenization issues
4. The process happens automatically during generation

Token healing makes PSE robust against tokenization inconsistencies without compromising structural guarantees.

## The Generation Process

Let's walk through a simplified version of how PSE generates structured output:

1. **Setup**: You define the structure (JSON schema, custom grammar, etc.) and create a structuring engine
2. **State Machine Construction**: PSE builds a hierarchical state machine representing your structure
3. **Initialization**: When generation begins, PSE initializes state trackers
4. **Token-by-Token Generation**: For each new token:
   - PSE identifies valid next tokens based on the current state
   - It masks the LLM's probability distribution to allow only valid tokens
   - The LLM samples from the valid tokens based on the masked probabilities
   - PSE updates the state based on the selected token
5. **Completion**: Generation continues until a complete structure is produced or maximum tokens are reached

This guided approach ensures that the output always conforms to your specified structure.

## Schema Types

PSE supports multiple ways to define the structure you want:

### JSON Schema

The most common approach is using JSON Schema:

```python
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "required": ["name"]
}

engine = StructuringEngine.from_json_schema(schema)
```

### Custom Grammars

For more complex structures or non-JSON formats, you can define custom grammars:

```python
from pse import Grammar, OneOf, Sequence, ZeroOrMore

command_grammar = Grammar(
    "command", 
    Sequence(
        OneOf(["GET", "POST", "PUT", "DELETE"]),
        "/",
        ZeroOrMore(
            Sequence(
                Grammar("resource", r"[a-zA-Z0-9]+"),
                Optional("/", Grammar("id", r"[a-zA-Z0-9]+"))
            )
        )
    )
)

engine = StructuringEngine.from_grammar(command_grammar)
```

### Pydantic Models

Python developers can use Pydantic models for structure definition:

```python
from pydantic import BaseModel, Field
from pse import StructuringEngine

class User(BaseModel):
    name: str
    age: int = Field(ge=0)
    email: str | None = None

engine = StructuringEngine.from_pydantic(User)
```

## Generation Parameters

When generating with PSE, you can control various aspects of the generation process:

- **max_new_tokens**: Maximum number of tokens to generate
- **temperature**: Controls randomness (higher = more creative, lower = more deterministic)
- **top_p/top_k**: Alternative sampling methods to control diversity
- **max_parallel_paths**: Maximum number of paths to explore in parallel (for ambiguous grammars)
- **healing_threshold**: Controls token healing sensitivity

These parameters let you balance between creativity and determinism while maintaining structural guarantees.

## Usage Patterns

### Basic Pattern

The basic pattern for using PSE is:

1. Define your structure (schema, grammar, etc.)
2. Create a structuring engine
3. Prepare your input prompt
4. Generate structured output
5. Decode and use the result

```python
# Define structure
schema = {...}

# Create engine
engine = StructuringEngine.from_json_schema(schema)

# Prepare input
prompt = "Extract information about..."
input_ids = tokenizer.encode(prompt, return_tensors="pt")

# Generate
outputs = engine.generate(model, input_ids, max_new_tokens=200)

# Use result
result = tokenizer.decode(outputs[0])
```

### Composite Engines

For more complex scenarios, you can create composite engines that combine natural language and structured output:

```python
composite_engine = StructuringEngine.create_composite_engine(
    {
        "thinking": NaturalLanguageEngine(),
        "output": StructuringEngine.from_json_schema(schema)
    },
    delimiter_tokens={
        "thinking_to_output": ["\nJSON Output:\n"]
    }
)
```

This allows the LLM to "think" in natural language before producing structured output.

## Conceptual Diagram

Here's a conceptual diagram of how PSE works:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│                 │    │                  │    │                 │
│  Input Prompt   │───▶│  Language Model  │───▶│  Raw Logits     │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └────────┬────────┘
                                                        │
                       ┌──────────────────┐             │
                       │                  │             ▼
                       │  State Machine   │    ┌─────────────────┐
                       │                  │───▶│                 │
                       └──────────────────┘    │  Token Masking  │
                               ▲               │                 │
                               │               └────────┬────────┘
┌─────────────────┐    ┌──────┴───────────┐            │
│                 │    │                  │            ▼
│  JSON Schema    │───▶│  Schema Parser   │    ┌─────────────────┐
│  or Grammar     │    │                  │    │                 │
│                 │    └──────────────────┘    │  Next Token     │
└─────────────────┘                            │                 │
                                               └─────────────────┘
```

1. The input prompt is processed by the language model
2. The schema/grammar is parsed into a state machine
3. The state machine guides generation by masking invalid tokens
4. Only valid tokens can be selected for the next step
5. This process repeats until generation is complete

## Next Steps

Now that you understand the basic concepts behind PSE, you can:

- Try the [Quickstart](quickstart.md) examples to see PSE in action
- Build [Your First PSE Project](first-project.md) for a complete workflow
- Explore [Core Concepts](../core-concepts/state-machine.md) for a deeper understanding
- Check out the [API Reference](../api/structuring-engine.md) documentation
- Browse the [JSON Schema Guide](../guides/json-schema.md) for more advanced usage