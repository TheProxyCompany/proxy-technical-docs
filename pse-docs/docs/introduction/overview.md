# Proxy Structuring Engine Overview

The Proxy Structuring Engine (PSE) is a pioneering technology that transforms stochastic language models into deterministic, state-driven systems for generating reliable structured outputs.

## The Structured Output Challenge

Language models excel at generating fluent, creative text but struggle with producing outputs that conform to precise structures. Common challenges include:

- Generating syntactically valid JSON, XML, or YAML
- Maintaining schema compliance with specific fields and data types
- Preserving nested structures and relationships
- Handling complex validation rules and constraints
- Avoiding hallucinated fields or inconsistent structures

These challenges limit the use of LLMs in production systems where reliability and consistency are essential.

## What is PSE?

PSE provides a solution by acting as an intermediary layer between language models and structured output requirements:

![PSE Architecture Diagram](../assets/images/pse-architecture.svg)

At its core, PSE is a sophisticated state machine system that:

1. **Defines grammar constraints** from schemas or specifications
2. **Guides model generation** by modifying token probabilities during generation
3. **Ensures structural validity** by enforcing grammatical constraints
4. **Preserves model creativity** within the bounds of the structure

## How PSE Works

PSE operates through a unique combination of non-deterministic state machines, token-level constraints, and a sophisticated stepper system:

### 1. Schema Conversion

First, PSE converts your schema or grammar specification into a hierarchical state machine:

```
JSON Schema → StateMachine Graph → Runtime Constraints
```

This state machine defines all valid paths through the target structure, handling nested objects, arrays, and primitive types.

### 2. Token-Level Intervention

During generation, PSE intercepts the model's logit distribution before each token is sampled:

```python
# Simplified PSE intervention flow
def generate_next_token(model, input_ids):
    # Get logits from model
    logits = model(input_ids).logits[:, -1]
    
    # PSE modifies logits to enforce grammar
    modified_logits = pse_engine.mask_invalid_tokens(logits)
    
    # Sample from modified distribution
    next_token = sample(modified_logits)
    
    return next_token
```

This intervention ensures that only tokens that maintain grammatical validity can be generated.

### 3. Parallel Path Exploration

PSE's non-deterministic state machine can explore multiple valid paths simultaneously:

```
Input: "{"
Possible valid continuations: 
  → Object key (string)
  → Empty object ("}") 
  → etc.
```

The system tracks these paths through steppers, which maintain position in the state machine and handle transitions between states.

### 4. Token Healing

When tokenization boundaries don't align with grammar boundaries, PSE's token healing recovers gracefully:

```
Grammar expects: "function"
Model generates: "func" + "tion"

PSE recognizes "func" as partial match
→ Accepts "func"
→ Waits for completion
→ Accepts "tion" to complete "function"
```

This makes PSE robust to the subword tokenization used by modern language models.

## Key Components

PSE consists of several key components working together:

- **StructuringEngine**: The main interface for integrating with language models
- **StateMachine**: Hierarchical state machines that define grammar rules
- **Stepper**: Components that track positions within state machines
- **Adapters**: Framework-specific integrations for PyTorch, MLX, TensorFlow, and JAX
- **Schema Sources**: Converters for JSON Schema, Pydantic, and other schema formats

## Benefits Over Alternative Approaches

PSE offers several advantages over traditional methods for structured generation:

| Approach | Reliability | Model Freedom | Complexity | Performance |
|----------|-------------|--------------|------------|-------------|
| **Prompt Engineering** | Low | High | Simple | Fast |
| **Post-Processing** | Medium | High | Medium | Medium |
| **JSON Mode** | Medium | Medium | Simple | Fast |
| **PSE** | High | High | Medium | Fast |

PSE achieves this unique combination of benefits through its state machine architecture and token-level intervention.

## Use Cases

PSE is designed for applications where structured outputs are critical:

- **API Integration**: Ensure agents produce valid API calls with correct parameters
- **Data Extraction**: Convert unstructured text to validated structured formats
- **Code Generation**: Generate syntactically valid code in any programming language
- **Report Generation**: Create properly formatted reports with consistent structure
- **Game Systems**: Define and enforce complex rules for game AI

## Getting Started

To start using PSE, see the [Quickstart Guide](../getting-started/quickstart.md) or explore the [Core Concepts](../core-concepts/state-machine.md) for a deeper understanding.