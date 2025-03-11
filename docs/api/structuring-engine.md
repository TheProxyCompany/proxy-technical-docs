# StructuringEngine API Reference

The `StructuringEngine` class is the primary interface for working with the Proxy Structuring Engine (PSE). This comprehensive reference documents all methods, properties, and configurations available on the `StructuringEngine` class.

## Class Overview

```python
class StructuringEngine:
    """
    A structuring engine that guides LLMs in generating outputs conforming to specific structures.
    
    The StructuringEngine uses a hierarchical state machine to constrain LLM generation,
    ensuring outputs follow the defined structure while maintaining the model's creative capabilities.
    """
```

## Constructor

StructuringEngine instances are typically created using factory methods rather than directly via the constructor. The internal constructor is primarily used by the factory methods.

```python
def __init__(self, state_machine, config=None):
    """
    Initialize a StructuringEngine with the given state machine.
    
    Args:
        state_machine: The state machine to use for guiding generation
        config: Optional configuration dictionary
    """
```

## Factory Methods

### from_json_schema

```python
@classmethod
def from_json_schema(cls, schema, config=None):
    """
    Create a StructuringEngine from a JSON Schema.
    
    Args:
        schema (dict): A valid JSON Schema definition
        config (dict, optional): Configuration options for the engine
        
    Returns:
        StructuringEngine: A structuring engine that will produce outputs matching the schema
        
    Raises:
        SchemaValidationError: If the schema is invalid
        
    Examples:
        >>> schema = {"type": "object", "properties": {"name": {"type": "string"}}}
        >>> engine = StructuringEngine.from_json_schema(schema)
    """
```

### from_grammar

```python
@classmethod
def from_grammar(cls, grammar, config=None):
    """
    Create a StructuringEngine from a grammar definition.
    
    Args:
        grammar (Grammar): A grammar definition object
        config (dict, optional): Configuration options for the engine
        
    Returns:
        StructuringEngine: A structuring engine that will produce outputs matching the grammar
        
    Examples:
        >>> from pse import Grammar, OneOf, Sequence
        >>> grammar = Grammar("command", Sequence(OneOf(["GET", "POST"]), " /users"))
        >>> engine = StructuringEngine.from_grammar(grammar)
    """
```

### from_pydantic

```python
@classmethod
def from_pydantic(cls, model_class, config=None):
    """
    Create a StructuringEngine from a Pydantic model.
    
    Args:
        model_class (Type[BaseModel]): A Pydantic model class
        config (dict, optional): Configuration options for the engine
        
    Returns:
        StructuringEngine: A structuring engine that will produce outputs matching the model
        
    Examples:
        >>> from pydantic import BaseModel
        >>> class User(BaseModel):
        ...     name: str
        ...     age: int
        >>> engine = StructuringEngine.from_pydantic(User)
    """
```

### create_composite_engine

```python
@classmethod
def create_composite_engine(cls, engines, delimiter_tokens=None, config=None):
    """
    Create a composite engine from multiple structuring engines.
    
    Args:
        engines (dict): A mapping of section names to structuring engines
        delimiter_tokens (dict, optional): Tokens that delimit transitions between sections
        config (dict, optional): Configuration options for the composite engine
        
    Returns:
        StructuringEngine: A composite structuring engine
        
    Examples:
        >>> thinking_engine = NaturalLanguageEngine()
        >>> json_engine = StructuringEngine.from_json_schema(schema)
        >>> composite = StructuringEngine.create_composite_engine({
        ...     "thinking": thinking_engine,
        ...     "output": json_engine
        ... }, delimiter_tokens={"thinking_to_output": ["\nJSON Output:\n"]})
    """
```

## Generation Methods

### generate

```python
def generate(self, model, input_ids, max_new_tokens=None, **kwargs):
    """
    Generate structured output using the provided model.
    
    Args:
        model: The language model to use for generation
        input_ids: The input token IDs (format depends on the framework)
        max_new_tokens (int, optional): Maximum number of new tokens to generate
        **kwargs: Additional generation parameters
            - temperature (float): Controls randomness (higher = more random)
            - top_p (float): Nucleus sampling parameter
            - top_k (int): Top-k sampling parameter
            - max_parallel_paths (int): Maximum number of parallel paths to explore
            - healing_threshold (float): Threshold for token healing
        
    Returns:
        Tensor: The generated token IDs
        
    Examples:
        >>> output_ids = engine.generate(model, input_ids, max_new_tokens=100, temperature=0.7)
        >>> output_text = tokenizer.decode(output_ids[0])
    """
```

### generate_with_streaming

```python
def generate_with_streaming(self, model, input_ids, callback=None, max_new_tokens=None, **kwargs):
    """
    Generate structured output with streaming callback.
    
    Args:
        model: The language model to use for generation
        input_ids: The input token IDs
        callback (callable): Function called for each new token
        max_new_tokens (int, optional): Maximum number of new tokens
        **kwargs: Additional generation parameters
        
    Returns:
        Tensor: The generated token IDs
        
    Examples:
        >>> def on_token(token_id, text):
        ...     print(text, end="", flush=True)
        >>> output_ids = engine.generate_with_streaming(model, input_ids, callback=on_token)
    """
```

### prepare_inputs_for_generation

```python
def prepare_inputs_for_generation(self, input_ids, **kwargs):
    """
    Prepare inputs for generation with this engine.
    
    This is a lower-level method used by the generate methods.
    
    Args:
        input_ids: The input token IDs
        **kwargs: Additional preparation parameters
        
    Returns:
        dict: The prepared inputs
    """
```

### update_state_for_generation

```python
def update_state_for_generation(self, input_ids, state=None, **kwargs):
    """
    Update the generation state based on new input tokens.
    
    This is a lower-level method used by the generate methods.
    
    Args:
        input_ids: The new input token IDs
        state (dict, optional): The current generation state
        **kwargs: Additional update parameters
        
    Returns:
        dict: The updated generation state
    """
```

## Configuration Methods

### configure

```python
def configure(self, **config):
    """
    Update the engine's configuration.
    
    Args:
        **config: Configuration parameters to update
        
    Returns:
        StructuringEngine: Self, for method chaining
        
    Examples:
        >>> engine.configure(healing_threshold=0.8, max_parallel_paths=4)
    """
```

### with_config

```python
def with_config(self, **config):
    """
    Create a new engine with updated configuration.
    
    Unlike configure(), this method returns a new engine instance.
    
    Args:
        **config: Configuration parameters to update
        
    Returns:
        StructuringEngine: A new engine with the updated configuration
        
    Examples:
        >>> new_engine = engine.with_config(healing_threshold=0.8)
    """
```

## Utility Methods

### logits_processor

```python
def logits_processor(self, input_ids, scores, **kwargs):
    """
    Process logits during generation to enforce structure.
    
    This method is used by some framework-specific adapters.
    
    Args:
        input_ids: The current input token IDs
        scores: The logits/scores from the model
        **kwargs: Additional processing parameters
        
    Returns:
        Tensor: The processed logits/scores
    """
```

### get_state_machine

```python
def get_state_machine(self):
    """
    Get the underlying state machine.
    
    Returns:
        StateMachine: The state machine used by this engine
    """
```

### get_parallel_paths

```python
def get_parallel_paths(self):
    """
    Get the current parallel paths being explored.
    
    This is useful for debugging and visualization.
    
    Returns:
        list: The current parallel paths
    """
```

### get_healing_events

```python
def get_healing_events(self):
    """
    Get the token healing events from the last generation.
    
    Returns:
        list: A list of healing events
    """
```

### is_valid_continuation

```python
def is_valid_continuation(self, sequence):
    """
    Check if a token sequence is a valid continuation.
    
    Args:
        sequence: A sequence of tokens
        
    Returns:
        bool: True if the sequence is valid
    """
```

### get_valid_continuation_tokens

```python
def get_valid_continuation_tokens(self, sequence=None):
    """
    Get all valid continuation tokens for a sequence.
    
    Args:
        sequence (list, optional): A sequence of tokens
        
    Returns:
        list: Valid continuation tokens
    """
```

## Configuration Options

The StructuringEngine accepts various configuration options that control its behavior:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `healing_threshold` | float | 0.6 | Threshold for token healing (0.0 to 1.0) |
| `max_healing_tokens` | int | 3 | Maximum number of tokens in a healing sequence |
| `healing_mode` | str | "balanced" | Healing mode: "conservative", "balanced", or "aggressive" |
| `normalize_whitespace` | bool | True | Whether to normalize whitespace during healing |
| `case_insensitive_healing` | bool | False | Whether to use case-insensitive healing |
| `max_parallel_paths` | int | 4 | Maximum number of parallel paths to explore |
| `path_pruning_threshold` | float | 0.2 | Threshold for pruning unlikely paths |
| `debug_healing` | bool | False | Whether to log healing events |
| `debug_state_transitions` | bool | False | Whether to log state transitions |
| `generation_chunk_size` | int | 20 | Chunk size for batch generation |

## Example Usage

### Basic JSON Generation

```python
from pse import StructuringEngine
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
        "occupation": {"type": "string"}
    },
    "required": ["name", "age"]
}

# Create engine
engine = StructuringEngine.from_json_schema(schema)

# Generate
prompt = "Extract information about Sarah, who is 29 and works as a software engineer."
input_ids = tokenizer.encode(prompt, return_tensors="pt")
outputs = engine.generate(
    model,
    input_ids,
    max_new_tokens=200,
    temperature=0.7
)
result = tokenizer.decode(outputs[0])
print(result)
```

### Composite Engine with Thinking

```python
from pse import StructuringEngine, NaturalLanguageEngine

# Create engines for different sections
thinking_engine = NaturalLanguageEngine()
json_engine = StructuringEngine.from_json_schema(schema)

# Create composite engine
composite_engine = StructuringEngine.create_composite_engine(
    {
        "thinking": thinking_engine,
        "output": json_engine
    },
    delimiter_tokens={
        "thinking_to_output": ["\nJSON Output:\n"]
    }
)

# Generate with composite engine
outputs = composite_engine.generate(
    model,
    input_ids,
    max_new_tokens=500,
    temperature=0.7
)
```

### Advanced Configuration

```python
# Create engine with custom configuration
engine = StructuringEngine.from_json_schema(
    schema,
    config={
        "healing_threshold": 0.8,               # More conservative healing
        "max_parallel_paths": 6,                # Explore more paths
        "normalize_whitespace": True,           # Handle whitespace variations
        "case_insensitive_healing": True,       # Case-insensitive matching
        "debug_healing": True                   # Log healing events
    }
)

# Update configuration later
engine.configure(
    healing_threshold=0.7,
    max_parallel_paths=4
)

# Or create a new engine with updated config
strict_engine = engine.with_config(
    healing_threshold=0.9,
    healing_mode="conservative"
)
```

## Framework-Specific Adapters

The base `StructuringEngine` class is framework-agnostic. For better integration with specific ML frameworks, PSE provides specialized adapters:

### PyTorch

```python
from pse.util.torch_mixin import TorchStructuringEngine

# Create PyTorch-specific engine
engine = TorchStructuringEngine.from_json_schema(schema)

# Generate with PyTorch-specific methods
generated_ids = engine.generate(
    model,
    input_ids,
    max_length=100,
    do_sample=True,
    temperature=0.7
)
```

### MLX

```python
from pse.util.generate_mlx import MLXStructuringEngine

# Create MLX-specific engine
engine = MLXStructuringEngine.from_json_schema(schema)

# Generate with MLX-specific methods
generated_ids = engine.generate(
    model,
    input_ids,
    max_length=100,
    temperature=0.7
)
```

### TensorFlow

```python
from pse.util.tf_mixin import TFStructuringEngine

# Create TensorFlow-specific engine
engine = TFStructuringEngine.from_json_schema(schema)

# Generate with TensorFlow-specific methods
generated_ids = engine.generate(
    model,
    input_ids,
    max_length=100,
    temperature=0.7
)
```

### JAX

```python
from pse.util.jax_mixin import JAXStructuringEngine

# Create JAX-specific engine
engine = JAXStructuringEngine.from_json_schema(schema)

# Generate with JAX-specific methods
generated_ids = engine.generate(
    model,
    input_ids,
    max_length=100,
    temperature=0.7
)
```

## Error Handling

The StructuringEngine may raise various exceptions:

### SchemaValidationError

Raised when a JSON schema fails validation:

```python
try:
    engine = StructuringEngine.from_json_schema(invalid_schema)
except pse.exceptions.SchemaValidationError as e:
    print(f"Schema validation error: {e}")
```

### GrammarError

Raised when there's an issue with a custom grammar:

```python
try:
    engine = StructuringEngine.from_grammar(invalid_grammar)
except pse.exceptions.GrammarError as e:
    print(f"Grammar error: {e}")
```

### GenerationError

Raised when generation fails due to structural constraints:

```python
try:
    outputs = engine.generate(model, input_ids, max_new_tokens=100)
except pse.exceptions.GenerationError as e:
    print(f"Generation error: {e}")
    # Fall back to unconstrained generation
    outputs = model.generate(input_ids, max_new_tokens=100)
```

## Performance Considerations

When using the StructuringEngine, consider these performance factors:

- **Schema Complexity**: More complex schemas require more computation
- **Parallel Paths**: More parallel paths increase accuracy but use more memory
- **Healing Threshold**: Lower thresholds increase robustness but may slow generation
- **Batch Size**: Larger batches improve throughput but use more memory
- **Token Caching**: Consider caching common token sequences for repeated operations

## Thread Safety

The StructuringEngine is not thread-safe by default. For multithreaded environments:

- Create separate engine instances for each thread
- Use the `with_config()` method to create thread-local copies
- Consider using a thread pool with pre-initialized engines

## Next Steps

- Explore the [Type System](types.md) for detailed type information
- Learn about [Framework Adapters](framework-adapters.md) for framework-specific features
- Read about [Grammar Definition](grammar-definition.md) for custom formats
- See [Advanced Topics](../advanced/architecture-deep-dive.md) for implementation details