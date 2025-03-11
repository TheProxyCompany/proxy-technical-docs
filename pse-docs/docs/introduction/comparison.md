# Comparison with Alternative Approaches

When it comes to generating structured outputs from language models, there are several approaches available. This page compares PSE with alternative methods to help you understand the unique advantages of our approach.

## Overview of Approaches

There are four main approaches to generating structured outputs from LLMs:

1. **Prompt Engineering**: Using carefully crafted instructions to guide the model
2. **Post-Processing**: Parsing and fixing outputs after generation
3. **Fine-Tuning**: Training models specifically for structured output generation
4. **Generation-Time Guidance**: Controlling the generation process token-by-token (PSE's approach)

## Feature Comparison Table

| Feature | PSE (Generation-Time) | Prompt Engineering | Post-Processing | Fine-Tuning |
|---------|:---------------------:|:------------------:|:---------------:|:-----------:|
| **Structural Guarantees** | ✅ Mathematical guarantee | ❌ Best effort | ⚠️ Partial | ⚠️ Probabilistic |
| **Model Compatibility** | ✅ Works with any LLM | ✅ Works with any LLM | ✅ Works with any LLM | ❌ Requires retraining |
| **Token Context Usage** | ✅ No prompt overhead | ❌ High token usage | ✅ No prompt overhead | ✅ No prompt overhead |
| **Implementation Effort** | ✅ Low (schema definition) | ⚠️ Medium (prompt crafting) | ⚠️ Medium (parser dev) | ❌ High (training data) |
| **Handling Complex Structures** | ✅ Handles any complexity | ❌ Degrades with complexity | ⚠️ Limited by parser | ⚠️ Limited by training data |
| **Performance Impact** | ⚠️ ~20ms per token | ✅ No overhead | ⚠️ Post-processing time | ✅ No overhead |
| **Creative Flexibility** | ✅ Preserves creativity | ⚠️ Constrains with instructions | ❌ Forces corrections | ❌ Limited to training data |
| **Error Recovery** | ✅ Token healing | ❌ No recovery | ⚠️ Limited fixes | ❌ No recovery |
| **Adaptability to New Structures** | ✅ Dynamic schema updates | ✅ Update prompt | ⚠️ Update parser | ❌ Requires retraining |

## Prompt Engineering

### Approach
Prompt engineering relies on carefully crafted instructions that explain the desired output format to the LLM.

```
Generate a JSON object with the following structure:
{
  "name": string,
  "age": integer,
  "interests": array of strings
}
Make sure to use valid JSON syntax with double quotes around property names.
```

### Advantages
- No additional tools or libraries required
- Works with any LLM
- Simple to implement for basic structures

### Limitations
- No guarantees of structural validity
- Consumes valuable prompt tokens
- Effectiveness decreases with structure complexity
- Vulnerable to prompt injection
- Limited error recovery options

## Post-Processing

### Approach
Post-processing involves generating output and then using parsers, regex, or other tools to fix structural issues.

```python
# Generate potentially invalid JSON
output = model.generate("Extract information about the person")

# Try to parse and fix
import json
import re

try:
    data = json.loads(output)
except json.JSONDecodeError:
    # Apply fixes
    output = re.sub(r"'([^']*)':", r'"\1":', output)  # Fix quotes
    output = re.sub(r",\s*}", "}", output)  # Fix trailing commas
    try:
        data = json.loads(output)
    except:
        data = {"error": "Failed to parse output"}
```

### Advantages
- Works with any LLM
- Can fix common errors
- No prompt token overhead

### Limitations
- Cannot recover from fundamental structural errors
- "Garbage in, garbage out" problem
- Complex structures require complex parsers
- Fixes may not align with model's intent
- Limited to formats with available parsers

## Fine-Tuning

### Approach
Fine-tuning involves training an LLM specifically to generate outputs in the desired structure.

```python
# Collect training data
training_data = [
    {"input": "Extract info about John", "output": '{"name": "John", "age": 30}'},
    {"input": "Extract info about Sarah", "output": '{"name": "Sarah", "age": 25}'},
    # ... hundreds or thousands more examples
]

# Fine-tune model
fine_tuned_model = fine_tune(base_model, training_data)

# Generate with fine-tuned model
output = fine_tuned_model.generate("Extract info about Mark")
```

### Advantages
- No additional generation-time overhead
- Can learn domain-specific formats
- No prompt token overhead

### Limitations
- Requires large amounts of training data
- Expensive and time-consuming to train
- Limited to structures seen during training
- Still provides no guarantees
- Cannot easily adapt to new structures

## PSE (Generation-Time Guidance)

### Approach
PSE guides the generation process token-by-token using a state machine derived from your schema.

```python
from proxy_structuring_engine import StructuringEngine

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "interests": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name"]
}

# Create engine
engine = StructuringEngine.from_json_schema(schema)

# Generate guaranteed valid output
output = engine.generate(model, "Extract information about the person")
```

### Advantages
- Mathematical guarantees of structural validity
- Works with any LLM without retraining
- Handles arbitrarily complex structures
- Preserves model creativity within constraints
- Token healing recovers from minor errors
- Adapts instantly to new schemas
- No prompt token overhead

### Limitations
- Small performance overhead (~20ms per token)
- Requires access to model logits
- More setup than simple prompt engineering

## Performance Benchmarks

Internal benchmarks comparing approaches across various dimensions:

### Structural Validity Rate

| Approach | Simple Structures | Complex Nested | Edge Cases |
|----------|:-----------------:|:--------------:|:----------:|
| PSE | 100% | 100% | 100% |
| Prompt Engineering | 87% | 64% | 41% |
| Post-Processing | 93% | 71% | 62% |
| Fine-Tuning | 95% | 82% | 73% |

### Generation Time (seconds)

| Approach | Simple Structures | Complex Nested | Edge Cases |
|----------|:-----------------:|:--------------:|:----------:|
| PSE | 1.21s | 2.32s | 2.45s |
| Prompt Engineering | 0.95s | 1.87s | 1.92s |
| Post-Processing | 1.12s | 2.15s | 3.14s |
| Fine-Tuning | 0.93s | 1.85s | 1.90s |

### Implementation Effort (developer hours)

| Approach | Simple Structures | Complex Nested | Edge Cases |
|----------|:-----------------:|:--------------:|:----------:|
| PSE | 0.5 | 1.0 | 1.5 |
| Prompt Engineering | 1.0 | 4.0 | 8.0 |
| Post-Processing | 2.0 | 8.0 | 16.0 |
| Fine-Tuning | 10.0 | 20.0 | 40.0 |

## When to Use Each Approach

### Choose PSE when:
- You need guaranteed structural validity
- You're working with complex nested structures
- You need to adapt to different structures dynamically
- You want to preserve the model's creative capabilities
- Reliability is critical for your application

### Consider Prompt Engineering when:
- You need a quick solution for simple structures
- You don't have access to model logits
- Occasional structural errors are acceptable
- You're working with very simple formats

### Consider Post-Processing when:
- You're working with legacy systems
- You only need to fix predictable, minor errors
- You already have robust parsers available
- You don't have access to model logits

### Consider Fine-Tuning when:
- You have large amounts of training data
- You're generating the same structure repeatedly
- You can invest in training infrastructure
- Your structure is highly domain-specific

## Conclusion

While each approach has its place, PSE provides the only mathematical guarantee of structural validity while preserving the LLM's creative capabilities. By guiding generation token-by-token, PSE transforms probabilistic language models into reliable tools for structured output generation.