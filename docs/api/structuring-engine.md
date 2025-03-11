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

While StructuringEngine instances are typically created using factory methods, the constructor can be used directly when you have a tokenizer and want to configure the engine separately.

```python
def __init__(
    self,
    tokenizer: PreTrainedTokenizerFast | PreTrainedTokenizerBase,
    whitelist_control_tokens: list[str] | None = None,
    multi_token_sampling: bool = False,
    max_resample_attempts: int = 5,
) -> None:
    """
    Initialize a StructuringEngine with a tokenizer.
    
    Args:
        tokenizer: HuggingFace tokenizer for encoding/decoding
        whitelist_control_tokens: Optional list of control tokens to exclude from masking
        multi_token_sampling: Enable multi-token sampling for better handling of tokenization boundaries
        max_resample_attempts: Maximum number of attempts to resample an invalid token
    """
```

**Example:**
```python
from pse import StructuringEngine
from transformers import AutoTokenizer

# Create engine with tokenizer
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")
engine = StructuringEngine(tokenizer)

# Configure with schema later
engine.configure(person_schema)
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
def configure(
    self,
    structure: JSONSchemaSource | StateMachine,
    **kwargs: Any,
) -> None:
    """
    Configure the structuring engine with a schema or state machine.
    
    Args:
        structure: Either a JSON Schema (dict, string, or Pydantic model) or a StateMachine instance
        **kwargs: Additional keyword arguments for schema processing
        
    Returns:
        None
        
    Examples:
        >>> # Configure with JSON Schema
        >>> engine.configure({
        ...     "type": "object",
        ...     "properties": {
        ...         "name": {"type": "string"},
        ...         "age": {"type": "integer"}
        ...     }
        ... })
        >>> 
        >>> # Configure with state machine directly
        >>> from pse.types.json import ObjectStateMachine
        >>> engine.configure(ObjectStateMachine())
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

### get_structured_output

```python
def get_structured_output(
    self,
    output_type: type[OutputType] | None = None,
    raise_on_error: bool = False,
) -> OutputType | Any:
    """
    Parse and cast the output to the given type.
    
    This method is used after generation to retrieve the structured output.
    
    Args:
        output_type: Optional type to cast the output to (e.g., Pydantic model)
        raise_on_error: Whether to raise exceptions for parsing errors (default: False)
        
    Returns:
        The structured output, optionally cast to the specified type
        
    Examples:
        >>> # Get output as a dictionary
        >>> result = engine.get_structured_output()
        >>> 
        >>> # Get output as a Pydantic model
        >>> from pydantic import BaseModel
        >>> class Person(BaseModel):
        ...     name: str
        ...     age: int
        >>> 
        >>> person = engine.get_structured_output(Person)
    """
```

### get_stateful_structured_output

```python
def get_stateful_structured_output(
    self,
    output_type: type[OutputType] | None = None,
    raise_on_error: bool = False,
) -> Iterator[tuple[str, OutputType | Any]]:
    """
    Get each part of the output labeled with the identifier of the step that produced it.
    
    This is useful for composite engines with multiple sections.
    
    Args:
        output_type: Optional type to cast the output to
        raise_on_error: Whether to raise exceptions for parsing errors
        
    Returns:
        Iterator of (state_identifier, output) tuples
        
    Examples:
        >>> # Get stateful output
        >>> for state_id, value in engine.get_stateful_structured_output():
        ...     print(f"State {state_id}: {value}")
    """
```

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

### sample

```python
def sample(
    self, logprobs: Array_Type, sampler: Callable[..., Array_Type]
) -> Array_Type:
    """
    Sample tokens from logprobs using the provided sampler function.
    
    This low-level method handles the sampling logic during generation.
    
    Args:
        logprobs: 2D array of shape (batch_size, sequence_length) containing log probabilities
        sampler: Callable that implements the sampling strategy
        
    Returns:
        Array of sampled token indices with same type as input logprobs
        
    Notes:
        - Automatically handles device placement (CPU/GPU)
        - Processes each batch individually
        - Parent class expects single-batch input of shape (1, sequence_length)
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

### cast_output

```python
def cast_output(
    self,
    input: str,
    output_type: type[OutputType] | None,
    raise_on_error: bool,
) -> OutputType | Any:
    """
    Cast the output string to the given type.
    
    This method parses JSON and optionally converts it to a specified type.
    
    Args:
        input: String input to cast (typically JSON)
        output_type: Type to cast to (None returns parsed JSON)
        raise_on_error: Whether to raise exceptions for parsing errors
        
    Returns:
        Cast output or original input if casting fails
        
    Notes:
        - Supports Pydantic model validation via model_validate
        - Handles JSON parsing errors with configurable behavior
        - Returns parsed JSON object when output_type is None
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
engine = StructuringEngine(tokenizer)
engine.configure(schema)

# Generate
prompt = "Extract information about Sarah, who is 29 and works as a software engineer."
input_ids = tokenizer.encode(prompt, return_tensors="pt")
outputs = engine.generate(
    model,
    input_ids,
    max_new_tokens=200,
    temperature=0.7
)

# Get structured result
result = engine.get_structured_output()
print(result)  # {'name': 'Sarah', 'age': 29, 'occupation': 'software engineer'}
```

### Composite Engine with Thinking

```python
from pse import StructuringEngine
from transformers import AutoTokenizer

# Create tokenizer
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Create JSON engine for structured output
json_engine = StructuringEngine(tokenizer)
json_engine.configure(schema)

# Create composite engine
# Note: In newer versions, this would use factory methods or specialized approaches
from pse_core.state_machine import StateMachine
from pse.types.base.wait_for import WaitFor

# Create a state machine that waits for a delimiter then applies the JSON structure
composite_sm = StateMachine(
    {
        "thinking": [(WaitFor("\nJSON Output:\n", json_engine.state_machine), "end")]
    },
    "thinking",
    ["end"]
)

# Create engine with composite state machine
composite_engine = StructuringEngine(tokenizer)
composite_engine.configure(composite_sm)

# Generate with composite engine
outputs = composite_engine.generate(
    model,
    input_ids,
    max_new_tokens=500,
    temperature=0.7
)

# Get structured result
for state_id, value in composite_engine.get_stateful_structured_output():
    if state_id == "end":
        structured_output = value
        print(f"Structured output: {structured_output}")
```

### Advanced Configuration

```python
from pse import StructuringEngine
from transformers import AutoTokenizer

# Create tokenizer
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Create engine with custom token settings
engine = StructuringEngine(
    tokenizer,
    whitelist_control_tokens=["<|im_start|>", "<|im_end|>"],  # Don't mask these tokens
    multi_token_sampling=True,  # Better handling of token boundaries
    max_resample_attempts=10    # Try harder to find valid tokens
)

# Configure with schema and additional parameters
engine.configure(
    schema,
    delimiters=None,             # No delimiters for the schema
    fenced_type_mapping=None     # No special fenced content handling
)

# For framework-specific configuration, use the appropriate adapter class:
from pse.util.torch_mixin import TorchStructuringEngine

# PyTorch-specific engine with custom torch settings
torch_engine = TorchStructuringEngine(
    tokenizer,
    multi_token_sampling=True
)
torch_engine.configure(schema)
```

## Framework-Specific Adapters

The base `StructuringEngine` class is framework-agnostic. For better integration with specific ML frameworks, PSE provides specialized adapters:

### PyTorch

```python
from pse.util.torch_mixin import TorchStructuringEngine
from transformers import AutoTokenizer

# Create PyTorch-specific engine
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")
engine = TorchStructuringEngine(tokenizer)
engine.configure(schema)

# Generate with PyTorch-specific methods
generated_ids = engine.generate(
    model,
    input_ids,
    max_new_tokens=100,
    do_sample=True,
    temperature=0.7
)

# Access generated structured output
result = engine.get_structured_output()
```

### MLX

```python
from pse.util.generate_mlx import MLXStructuringEngine
from transformers import AutoTokenizer

# Create MLX-specific engine
tokenizer = AutoTokenizer.from_pretrained("mlx-community/Mistral-7B-v0.1-hf")
engine = MLXStructuringEngine(tokenizer)
engine.configure(schema)

# Generate with MLX-specific methods
generated_ids = engine.generate(
    model,
    input_ids,
    max_new_tokens=100,
    temperature=0.7
)

# Access generated structured output
result = engine.get_structured_output()
```

### TensorFlow

```python
from pse.util.tf_mixin import TFStructuringEngine
from transformers import AutoTokenizer

# Create TensorFlow-specific engine
tokenizer = AutoTokenizer.from_pretrained("google/t5-v1_1-large")
engine = TFStructuringEngine(tokenizer)
engine.configure(schema)

# Generate with TensorFlow-specific methods
generated_ids = engine.generate(
    model,
    input_ids,
    max_length=100,
    temperature=0.7
)

# Access generated structured output
result = engine.get_structured_output()
```

### JAX

```python
from pse.util.jax_mixin import JAXStructuringEngine
from transformers import AutoTokenizer

# Create JAX-specific engine
tokenizer = AutoTokenizer.from_pretrained("google/t5-v1_1-large")
engine = JAXStructuringEngine(tokenizer)
engine.configure(schema)

# Generate with JAX-specific methods
generated_ids = engine.generate(
    model,
    input_ids,
    max_length=100,
    temperature=0.7
)

# Access generated structured output
result = engine.get_structured_output()
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

- Learn about [Framework Adapters](framework-adapters.md) for framework-specific features
- Review the [State Machine Architecture](../core-concepts/state-machine.md) 
- Understand how [Token Healing](../core-concepts/token-healing.md) works
- Explore the [JSON Schema Guide](../guides/json-schema.md) for practical applications