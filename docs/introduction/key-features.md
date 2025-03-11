# Key Features of the Proxy Structuring Engine

The Proxy Structuring Engine (PSE) offers a comprehensive set of features designed to transform how developers work with large language models in production environments. This page provides an in-depth look at PSE's core capabilities and what sets it apart from other approaches.

## Guaranteed Structural Compliance

### JSON Schema Support

PSE provides first-class support for [JSON Schema](https://json-schema.org/) (Draft 7), allowing you to:

- Define complex object structures with nested properties
- Specify required vs. optional fields
- Set constraints on string formats, number ranges, and array lengths
- Support advanced JSON Schema features like oneOf, anyOf, and allOf

```python
# Example JSON Schema definition
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer", "minimum": 0, "maximum": 120},
        "address": {
            "type": "object",
            "properties": {
                "street": {"type": "string"},
                "city": {"type": "string"},
                "zipcode": {"type": "string", "pattern": "^\\d{5}(-\\d{4})?$"}
            },
            "required": ["street", "city"]
        },
        "tags": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "age"]
}

# Create a structuring engine from this schema
engine = StructuringEngine.from_json_schema(person_schema)
```

### Custom Grammar Definition

Beyond JSON, PSE supports custom grammar definitions for any structured format:

- Define formats like CSV, XML, programming languages, or custom DSLs
- Create grammars programmatically with an intuitive Python API
- Support context-sensitive features that traditional parsers struggle with

```python
# Example custom grammar definition for a simple command language
from pse import Grammar, OneOf, Sequence, ZeroOrMore, Optional

command_grammar = Grammar(
    "command", 
    Sequence(
        OneOf(["GET", "POST", "PUT", "DELETE"]),
        "/",
        ZeroOrMore(
            Sequence(
                OneOf(["users", "items", "orders"]),
                Optional("/", OneOf([":id", ":uuid"]))
            )
        )
    )
)

# Create engine from custom grammar
engine = StructuringEngine.from_grammar(command_grammar)
```

### Pydantic Integration

For Python developers, PSE offers seamless integration with Pydantic models:

- Convert Pydantic models directly to PSE state machines
- Leverage Python's type system for structure definition
- Reuse existing data models across your application

```python
from pydantic import BaseModel, Field
from pse import StructuringEngine

class Address(BaseModel):
    street: str
    city: str
    zipcode: str

class Person(BaseModel):
    name: str
    age: int = Field(ge=0, le=120)
    address: Address
    tags: list[str] = []

# Create a structuring engine from the Pydantic model
engine = StructuringEngine.from_pydantic(Person)
```

## Intelligent Token Processing

### Token Healing

PSE employs sophisticated healing techniques that allow for recovery from minor generation errors:

- Partial credit for valid token prefixes (e.g., "tru" → "true")
- Multi-token lookahead for ambiguous generation paths
- Automatic correction of common mistakes
- Configurable healing thresholds for different use cases

### Parallel Path Exploration

For ambiguous structures, PSE maintains multiple possible interpretations simultaneously:

- Explores multiple valid paths in parallel
- Ranks paths based on model probabilities
- Maintains diversity of potential interpretations
- Automatically prunes unlikely paths for efficiency

### State-Aware Generation

Unlike simple regex or template-based approaches, PSE maintains a complete understanding of the generation context:

- Tracks nested structure depth (e.g., objects within arrays within objects)
- Maintains type awareness throughout generation
- Enforces context-specific constraints (e.g., field naming within objects)
- Supports forward references and complex interdependencies

## Framework Compatibility

### PyTorch Integration

Seamless integration with the PyTorch ecosystem:

- Compatible with Hugging Face Transformers models
- Supports custom PyTorch model architectures
- Optimized tensor operations for minimal overhead
- Works with PyTorch's sampling and generation utilities

```python
from pse.util.torch_mixin import TorchStructuringEngine

# Create engine with PyTorch-specific implementation
engine = TorchStructuringEngine.from_json_schema(schema)

# Generate with PyTorch-specific methods
generated_ids = engine.generate(model, input_ids, max_length=100)
```

### MLX Support

Native support for Apple's MLX framework for local LLM inference:

- Optimized for Apple Silicon (M1/M2/M3)
- Leverages MLX's efficient memory model
- Supports MLX's generation APIs
- Enables high-performance local inference

```python
from pse.util.generate_mlx import MLXStructuringEngine

# Create engine with MLX-specific implementation
engine = MLXStructuringEngine.from_json_schema(schema)

# Generate with MLX-specific methods
generated_ids = engine.generate(model, input_ids, max_length=100)
```

### TensorFlow and JAX

Additional support for other major frameworks:

- TensorFlow integration via dedicated adapter
- JAX support for research applications
- Consistent API across all frameworks
- Framework-specific optimizations

## Advanced Composition

### Natural Language + Structure

Seamlessly combine natural language and structured output:

- "Thinking" sections for model reasoning before structured output
- Configurable delimiters for transitions between modes
- Controlled scratchpad areas for complex reasoning
- Maintains context across format transitions

```python
# Create an engine with a natural language "thinking" section
# followed by structured JSON output
engine = StructuringEngine.create_composite_engine({
    "thinking": NaturalLanguageEngine(),
    "output": StructuringEngine.from_json_schema(schema)
}, 
delimiter_tokens={"thinking_to_output": ["\nJSON Output:\n"]}
)
```

### Multi-Step Generation

Support for complex, multi-stage generation processes:

- Pipeline multiple generation steps with different structures
- Share context and state between generation phases
- Transform intermediate outputs as inputs to subsequent steps
- Maintain coherence across the entire generation process

### Interactive Generation

Enable interactive workflows with stateful generation:

- Continue generation from previous outputs
- Modify state machines on-the-fly based on user input
- Stream tokens while maintaining structural guarantees
- Support for interactive editing and refinement

## Performance Optimization

### Minimal Overhead

PSE is designed for production environments with stringent performance requirements:

- **Per-Token Latency**: Only ~20ms additional processing time
- **Memory Efficiency**: Zero-copy tensor operations minimize memory usage
- **Scaling**: Linear complexity with grammar size, not exponential
- **First-Token Latency**: Minimal startup cost, no preprocessing required

### Configurable Trade-offs

Fine-tune performance characteristics for your specific use case:

- Adjust maximum parallel paths for complexity vs. speed
- Configure token healing thresholds
- Control beam search parameters
- Set custom timeouts and resource limits

### Optimized C++ Core

The heart of PSE is implemented in high-performance C++:

- Intrusive reference counting for memory safety
- Cache-friendly data structures
- SIMD optimizations where applicable
- Efficient state representation

## Developer Experience

### Intuitive Python API

PSE provides a developer-friendly API designed for ease of use:

- Consistent interface across all functionality
- Comprehensive error messages and debugging
- Progressive disclosure of advanced features
- Extensive documentation and examples

### Rich Debugging Tools

Troubleshoot complex generation scenarios with ease:

- Visualization of state machine traversal
- Detailed logging of token choices and probabilities
- Inspection of parallel paths during generation
- Performance profiling for optimization

### Comprehensive Error Handling

Robust error handling for production systems:

- Graceful fallbacks for generation failures
- Detailed error information for debugging
- Timeout handling for resource management
- Customizable error responses

## Next Steps

- Explore [Use Cases](use-cases.md) to see PSE in action
- See how PSE [compares to alternatives](comparison.md)
- Follow our [Installation Guide](../getting-started/installation.md) to get started
- Try the [Quickstart](../getting-started/quickstart.md) examples