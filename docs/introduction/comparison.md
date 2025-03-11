# Comparing PSE with Alternative Approaches

When working with large language models (LLMs) in production environments, ensuring structured output is a common challenge. This page compares the Proxy Structuring Engine (PSE) with alternative approaches to help you understand the trade-offs and advantages of each method.

## Overview of Approaches

There are several established methods for obtaining structured outputs from LLMs:

1. **Prompt Engineering**: Using carefully crafted prompts to instruct the LLM to produce structured outputs
2. **Post-Processing**: Applying regular expressions or parsers to clean up LLM outputs after generation
3. **Fine-Tuning**: Training or fine-tuning models specifically on structured formats
4. **Grammar-Based Methods**: Using formal grammars to constrain generation (including PSE)
5. **Function Calling APIs**: Using specialized APIs like OpenAI's function calling

Let's examine each approach in detail.

## Detailed Comparison

### Prompt Engineering

**Description**: This approach relies on providing detailed instructions in the prompt to guide the LLM toward generating properly structured outputs.

**Example**:
```
Generate a JSON object with the following properties:
- name (string)
- age (integer)
- email (string)
Make sure the output is valid JSON with proper quotes and commas.
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Reliability** | ⭐⭐ | Varies by model quality and prompt precision |
| **Complexity** | ⭐⭐⭐⭐⭐ | Simple to implement, no additional tooling |
| **Performance** | ⭐⭐⭐⭐ | No additional latency beyond model inference |
| **Flexibility** | ⭐⭐⭐⭐ | Works with any text generation model |
| **Guarantees** | ⭐ | No formal guarantees of structural validity |

**Advantages**:
- Works with any text-generating LLM
- No additional libraries or tools required
- Simple to implement and adapt

**Limitations**:
- No guarantee of structural validity
- Consumes valuable context tokens
- Effectiveness varies across models and prompts
- Vulnerable to prompt injection
- May require extensive prompt engineering

### Post-Processing

**Description**: This approach generates unconstrained text from an LLM and then applies regular expressions, parsers, or other cleanup mechanisms to transform it into valid structured output.

**Example**:
```python
# Generate unconstrained text
raw_output = model.generate(prompt)

# Post-process with regex or JSON parser
try:
    # Extract JSON-like content
    json_match = re.search(r'\{.*\}', raw_output, re.DOTALL)
    if json_match:
        json_str = json_match.group(0)
        # Fix common issues
        json_str = json_str.replace("'", '"')
        # Parse and validate
        result = json.loads(json_str)
    else:
        result = {"error": "No JSON found"}
except json.JSONDecodeError:
    result = {"error": "Invalid JSON"}
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Reliability** | ⭐⭐ | Limited by initial output quality |
| **Complexity** | ⭐⭐⭐ | Moderate implementation complexity |
| **Performance** | ⭐⭐⭐ | Additional post-processing latency |
| **Flexibility** | ⭐⭐⭐⭐ | Works with any text generation model |
| **Guarantees** | ⭐⭐ | Can enforce basic structural rules |

**Advantages**:
- Works with any text-generating LLM
- Can fix minor structural issues
- Can be tailored to specific output formats

**Limitations**:
- Cannot recover from fundamental structural errors
- Complex parsing logic required for each format
- Often introduces new errors during correction
- Adds latency and complexity
- Limited to formats that can be reliably parsed

### Fine-Tuning

**Description**: This approach involves further training an existing LLM on examples of properly formatted structured outputs, creating a specialized model that is more likely to generate valid structures.

**Example**:
```python
# Create a dataset of properly formatted examples
training_data = [
    {"prompt": "Extract information about John who is 30 years old", 
     "completion": '{"name": "John", "age": 30}'},
    # Many more examples...
]

# Fine-tune the model
fine_tuned_model = fine_tune(base_model, training_data)

# Generate using fine-tuned model
output = fine_tuned_model.generate(new_prompt)
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Reliability** | ⭐⭐⭐ | Improved but still not guaranteed |
| **Complexity** | ⭐⭐ | Complex to implement and maintain |
| **Performance** | ⭐⭐⭐⭐ | No additional latency during inference |
| **Flexibility** | ⭐⭐ | Limited to formats in training data |
| **Guarantees** | ⭐⭐ | No formal guarantees, just improved probability |

**Advantages**:
- Better inherent understanding of the required format
- No additional inference-time overhead
- Can learn domain-specific formats and conventions

**Limitations**:
- Resource-intensive and costly
- Creates special-purpose models with reduced general capabilities
- Still provides no guarantees of structural compliance
- Requires retraining for each new structure or format
- Needs extensive training data

### Function Calling APIs (e.g., OpenAI)

**Description**: Some commercial API providers like OpenAI offer specialized endpoints for function calling, which provide structured outputs optimized for calling functions or APIs.

**Example**:
```python
# Define function schema
functions = [{
    "name": "get_person_info",
    "description": "Get information about a person",
    "parameters": {
        "type": "object",
        "properties": {
            "name": {
                "type": "string",
                "description": "The person's name"
            },
            "age": {
                "type": "integer",
                "description": "The person's age"
            }
        },
        "required": ["name"]
    }
}]

# Call API with function definition
response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Extract information about John who is 30 years old"}],
    functions=functions,
    function_call="auto"
)
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Reliability** | ⭐⭐⭐⭐ | High but still not guaranteed |
| **Complexity** | ⭐⭐⭐⭐ | Simple API integration |
| **Performance** | ⭐⭐⭐⭐ | Optimized by the provider |
| **Flexibility** | ⭐⭐ | Limited to specific providers and formats |
| **Guarantees** | ⭐⭐⭐ | Provider-dependent quality |

**Advantages**:
- Easy to implement with supported providers
- Well-optimized implementations
- Good documentation and ecosystem

**Limitations**:
- Locked to specific API providers
- Typically requires using their models
- Still probabilistic, not guaranteed
- May have higher costs and rate limits
- Limited customization options

### Proxy Structuring Engine (PSE)

**Description**: PSE uses hierarchical state machines to guide the LLM's generation process in real-time, ensuring that outputs conform to the specified structure while preserving the model's creative capabilities.

**Example**:
```python
# Define structure using JSON Schema
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "required": ["name"]
}

# Create a structuring engine
engine = StructuringEngine.from_json_schema(person_schema)

# Generate structured output
outputs = engine.generate(model, input_ids, max_new_tokens=100)
result = tokenizer.decode(outputs[0])
```

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Reliability** | ⭐⭐⭐⭐⭐ | Mathematically guaranteed structure |
| **Complexity** | ⭐⭐⭐ | Moderate integration complexity |
| **Performance** | ⭐⭐⭐ | ~20ms additional latency per token |
| **Flexibility** | ⭐⭐⭐⭐ | Works with any LLM exposing logits |
| **Guarantees** | ⭐⭐⭐⭐⭐ | Formal guarantees of structural validity |

**Advantages**:
- Guaranteed structural validity
- Works with any LLM that exposes logits
- No model retraining required
- Handles complex nested structures
- Preserves model creativity within constraints
- Supports custom grammars beyond JSON

**Limitations**:
- Requires access to model logits (not black-box APIs)
- Adds some latency to generation (~20ms per token)
- Requires additional library integration
- More complex initial setup

## Feature Comparison Matrix

| Feature | Prompt Engineering | Post-Processing | Fine-Tuning | Function Calling APIs | PSE |
|---------|-------------------|----------------|------------|---------------------|-----|
| **Guaranteed Structure** | ❌ | ❌ | ❌ | ⚠️ (Model dependent) | ✅ |
| **Works with any LLM** | ✅ | ✅ | ⚠️ (Requires training) | ❌ (Provider specific) | ✅ (If logits exposed) |
| **No Additional Latency** | ✅ | ❌ | ✅ | ✅ | ⚠️ (~20ms per token) |
| **Complex Nested Structures** | ⚠️ (Unreliable) | ⚠️ (Hard to parse) | ⚠️ (Format specific) | ✅ | ✅ |
| **Custom Formats Beyond JSON** | ⚠️ (Unreliable) | ⚠️ (Requires custom parsers) | ⚠️ (Requires training data) | ❌ (Limited to API features) | ✅ |
| **Training Free** | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Open Source** | ✅ | ✅ | ⚠️ (Tools may be) | ❌ | ✅ |
| **Token Healing** | ❌ | ⚠️ (Basic corrections) | ❌ | ❌ | ✅ |
| **Framework Agnostic** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Natural Language + Structure** | ⚠️ (Unreliable) | ⚠️ (Hard to parse) | ⚠️ (Format specific) | ⚠️ (Limited support) | ✅ |

## Performance Benchmarks

Based on internal benchmarks comparing PSE to alternative approaches:

### Structural Validity Success Rate

| Approach | Simple JSON | Complex Nested JSON | Custom Format |
|----------|------------|-------------------|--------------|
| Prompt Engineering | 70-85% | 40-60% | 30-50% |
| Post-Processing | 80-90% | 60-70% | 50-70% |
| Fine-Tuning | 85-95% | 70-80% | 60-80% |
| Function Calling APIs | 90-95% | 75-85% | N/A |
| PSE | 100% | 100% | 100% |

### Latency Impact

| Approach | Added Latency |
|----------|--------------|
| Prompt Engineering | 0ms |
| Post-Processing | 50-500ms (format dependent) |
| Fine-Tuning | 0ms (but higher initial cost) |
| Function Calling APIs | 0ms (provider optimized) |
| PSE | ~20ms per token |

## When to Use Each Approach

### Choose Prompt Engineering When:

- You need a quick solution with minimal setup
- The structure is simple and failure is acceptable
- You're using a black-box API without logit access
- You're in early prototyping phases

### Choose Post-Processing When:

- You have existing parser infrastructure
- The expected format is relatively consistent
- You need to work with black-box APIs
- Structure requirements are simple

### Choose Fine-Tuning When:

- You have a large dataset of examples in your target format
- The format is domain-specific and complex
- You're willing to invest in training infrastructure
- You want to optimize for inference performance

### Choose Function Calling APIs When:

- You're already using a provider with this feature
- Your use case fits within their supported formats
- You prioritize ease of implementation
- Cost and provider lock-in aren't concerns

### Choose PSE When:

- Structural validity is mission-critical
- You're working with complex or custom formats
- You need guarantees rather than probabilities
- You want to preserve model creativity while ensuring structure
- You need seamless transitions between natural language and structured output
- You're working with models where you have logit access

## Conclusion

While each approach has its place depending on specific requirements, PSE offers unique advantages for production applications where structural validity is critical. It combines the creativity of large language models with the reliability of formal grammar systems, addressing a fundamental challenge in LLM application development.

The key differentiator of PSE is that it provides mathematical guarantees of structural validity rather than probabilistic improvements. This makes it suitable for mission-critical applications where structural errors would have significant consequences.

For applications where absolute structural guarantees aren't required or where you're limited to using black-box APIs, other approaches may be more appropriate. Consider your specific requirements around reliability, performance, and ease of implementation when choosing the right approach for your use case.

## Next Steps

- Follow our [Installation Guide](../getting-started/installation.md) to get started with PSE
- Try the [Quickstart](../getting-started/quickstart.md) examples
- Explore [Core Concepts](../core-concepts/state-machine.md) to understand how PSE works
- Browse [Use Cases](use-cases.md) for more application ideas