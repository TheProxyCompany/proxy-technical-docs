# StructuringEngine API Reference

The `StructuringEngine` class is the primary interface for the Proxy Structuring Engine (PSE). It provides a powerful mechanism to enforce structured output generation from language models by using state machines to constrain token generation.

## Class Definition

```python
class StructuringEngine(Engine):
    """
    A structuring engine that guides language models to produce structured outputs.
    
    The StructuringEngine uses hierarchical state machines to constrain token generation
    while preserving the model's creative capabilities within those constraints.
    It integrates with language model frameworks by masking invalid token logits
    during the generation process.
    """
```

## Basic Usage

```python
from pse.structuring_engine import StructuringEngine
from pse.util.torch_mixin import PSETorchMixin
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# Define model class with PSE integration
class PSE_Torch(PSETorchMixin, AutoModelForCausalLM):
    pass

# Load model and tokenizer
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")
model = PSE_Torch.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define a JSON schema for structured output
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer", "minimum": 0},
        "email": {"type": "string", "format": "email"}
    },
    "required": ["name", "age"]
}

# Create and configure the structuring engine
model.engine = StructuringEngine(tokenizer)
model.engine.configure(person_schema)

# Generate structured output
prompt = "Extract information about Alice who is 28 years old and works at example.com"
input_ids = tokenizer.encode(prompt, return_tensors="pt")
output_ids = model.generate(input_ids, max_new_tokens=100)

# Get the structured result
result = model.engine.get_structured_output()
print(result)  # {"name": "Alice", "age": 28, "email": "alice@example.com"}
```

## Constructor

```python
def __init__(
    tokenizer: PreTrainedTokenizerFast | PreTrainedTokenizerBase,
    whitelist_control_tokens: list[str] | None = None,
    multi_token_sampling: bool = False,
    max_resample_attempts: int = 5,
) -> None
```

**Parameters:**
- `tokenizer`: HuggingFace tokenizer to use for encoding/decoding
- `whitelist_control_tokens`: Optional list of control tokens that should not be masked
- `multi_token_sampling`: Enable multi-token sampling for better handling of tokenization boundaries (default: False)
- `max_resample_attempts`: Maximum number of attempts to resample an invalid token (default: 5)

## Core Methods

### Configure Engine

```python
def configure(
    self,
    structure: JSONSchemaSource | StateMachine,
    **kwargs: Any,
) -> None
```

Configure the engine with a schema or state machine.

**Parameters:**
- `structure`: Either a JSON Schema (dict, string, or Pydantic model) or a StateMachine instance
- `**kwargs`: Additional keyword arguments for schema processing

**Example:**
```python
# Configure with JSON Schema
engine.configure({
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    }
})

# Configure with state machine
from pse.types.json import ObjectStateMachine
engine.configure(ObjectStateMachine())
```

### Process Logits

```python
def process_logits(self, _: Any, raw_logits: Array_Type) -> Array_Type
```

Process model logits to enforce structure by masking invalid tokens.

**Parameters:**
- `_`: Placeholder parameter (not used)
- `raw_logits`: Raw logits from the model

**Returns:**
- Processed logits with the same type/shape as input

### Sample Tokens

```python
def sample(
    self, logprobs: Array_Type, sampler: Callable[..., Array_Type]
) -> Array_Type
```

Sample tokens using a provided sampling function.

**Parameters:**
- `logprobs`: Log probabilities for next token predictions
- `sampler`: Function that implements the sampling strategy

**Returns:**
- Sampled token IDs with same type as input

### Get Structured Output

```python
def get_structured_output(
    self,
    output_type: type[OutputType] | None = None,
    raise_on_error: bool = False,
) -> OutputType | Any
```

Get the parsed structured output from the generated text.

**Parameters:**
- `output_type`: Optional type to cast the output to (e.g., Pydantic model)
- `raise_on_error`: Whether to raise exceptions for parsing errors (default: False)

**Returns:**
- The structured output, optionally cast to the specified type

**Example:**
```python
# Get output as a dictionary
result = engine.get_structured_output()

# Get output as a Pydantic model
from pydantic import BaseModel
class Person(BaseModel):
    name: str
    age: int
    
person = engine.get_structured_output(Person)
```

### Get Stateful Structured Output

```python
def get_stateful_structured_output(
    self,
    output_type: type[OutputType] | None = None,
    raise_on_error: bool = False,
) -> Iterator[tuple[str, OutputType | Any]]
```

Get structured output with state identifiers.

**Parameters:**
- `output_type`: Optional type to cast the output to
- `raise_on_error`: Whether to raise exceptions for parsing errors

**Returns:**
- Iterator of (state_identifier, output) tuples

**Example:**
```python
# Get stateful output
for state_id, value in engine.get_stateful_structured_output():
    print(f"State {state_id}: {value}")
```

### Get Live Structured Output

```python
def get_live_structured_output(self) -> tuple[str, str] | None
```

Get the current structured output during generation.

**Returns:**
- Tuple of (identifier, output) or None if no output available

## Advanced Methods

### Cast Output

```python
def cast_output(
    self,
    input: str,
    output_type: type[OutputType] | None,
    raise_on_error: bool,
) -> OutputType | Any
```

Cast string output to a specific type.

**Parameters:**
- `input`: String input to cast
- `output_type`: Type to cast to (None returns parsed JSON)
- `raise_on_error`: Whether to raise exceptions

**Returns:**
- Cast output or original input if casting fails

### Print Top Logits

```python
def print_top_logits(self, logits: Any, top_n: int = 10, flag: str = "🔵") -> str
```

Format and log the top token probabilities (for debugging).

**Parameters:**
- `logits`: Logits to analyze
- `top_n`: Number of top tokens to show (default: 10)
- `flag`: Flag emoji for log output (default: 🔵)

**Returns:**
- Formatted string representation of top tokens

## Implementation Details

### Token Processing

The `StructuringEngine` guides token generation by:

1. Processing the model's logits to mask tokens that would lead to invalid structures
2. Handling device management for GPU/CPU tensors automatically
3. Maintaining a multi_token_mapping dictionary for token healing

### Output Handling

Output processing involves:

1. Using the tokenizer to decode token IDs into text
2. Parsing JSON for structured outputs
3. Optional validation and casting to Pydantic models
4. Comprehensive error handling with configurable behavior

### Integration with ML Frameworks

The base `StructuringEngine` works with any framework that:
- Provides tokenizers compatible with HuggingFace's interfaces
- Allows for custom logit processing during generation
- Supports custom sampling strategies

For optimized framework-specific implementations, use the specialized classes in PSE's utility modules.