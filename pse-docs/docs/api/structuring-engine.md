# Structuring Engine API

This page details the API for the main `pse.StructuringEngine` class, which is the primary interface for using the Proxy Structuring Engine.

```python
class pse.StructuringEngine(
    tokenizer: PreTrainedTokenizerFast | PreTrainedTokenizerBase,
    whitelist_control_tokens: list[str] | None = None,
    multi_token_sampling: bool = False,
    max_resample_attempts: int = 5
)
```

Inherits from the core C++ `Engine`. Orchestrates token processing and interfaces with language models.

**Parameters:**

*   **`tokenizer`** (`PreTrainedTokenizerFast | PreTrainedTokenizerBase`):
    An initialized tokenizer instance from the Hugging Face `transformers` library. Used to access the vocabulary, encode text to token IDs, and decode token IDs to text.
*   **`whitelist_control_tokens`** (`list[str] | None`, optional):
    A list of control token strings (e.g., `"<|eot_id|>"`) that should *not* be automatically masked by the engine, even if they might otherwise be considered invalid by the grammar near the end of generation. This prevents the engine from blocking essential control tokens like EOS. Defaults to `None`.
*   **`multi_token_sampling`** (`bool`, optional):
    Enables or disables the Multi-Token Processing optimization. When `True` (default in source, but shown as `False` here - *Correction: Default is `False` in provided `__init__` signature*), allows the engine to potentially return multiple tokens at once if an unambiguous multi-token sequence is required by the grammar. Defaults to `False`.
*   **`max_resample_attempts`** (`int`, optional):
    The maximum number of times the engine will ask the base sampler for a new token if the initially sampled token is invalid according to the grammar. Helps find a valid token when the probability mass is concentrated on invalid options. Defaults to `5`.

---

## Methods

### `configure`

```python
configure(
    structure: JSONSchemaSource | StateMachine,
    **kwargs: Any
) -> None
```

Configures the engine with the desired output structure. This translates the provided schema into the internal `StateMachine` representation used for enforcement.

**Parameters:**

*   **`structure`** (`JSONSchemaSource | StateMachine`):
    The schema definition. Can be a Pydantic `BaseModel` class, a JSON Schema dictionary, a Python callable (function signature), a sequence (`list` or `tuple`) of these types (interpreted as `anyOf`), or a direct `StateMachine` instance. See [Schema Sources Guide](../guides/schema-sources.md).
*   **`**kwargs`**:
    Additional keyword arguments passed to the schema conversion process (e.g., `delimiters` or `buffer_length` when using `EncapsulatedStateMachine` or `WaitFor` implicitly or explicitly).

---

### `process_logits`

```python
process_logits(
    input_ids: Any, # Framework-specific tensor/array
    scores: Any     # Framework-specific tensor/array
) -> Any          # Framework-specific tensor/array
```

The primary logits processing hook. This method should be added to the `logits_processor` list in your generation call. It queries the internal `Stepper`(s) to determine valid next tokens based on the `StateMachine` and masks the `scores` (logits) tensor, setting invalid token probabilities to negative infinity.

**Parameters:**

*   **`input_ids`**: The input token IDs tensor/array provided by the generation framework.
*   **`scores`**: The logits tensor/array (typically shape `(batch_size, vocab_size)`) produced by the LLM for the current step.

**Returns:**

*   The modified logits tensor/array with invalid tokens masked.

---

### `sample`

```python
sample(
    logprobs: Any, # Framework-specific tensor/array
    sampler: Callable[..., Any]
) -> Any       # Framework-specific tensor/array
```

The sampling hook. This method should be used as the `sampler` function in your generation call. It takes the processed logits (`logprobs`), calls the provided base `sampler` function, checks the validity of the sampled token(s), potentially resamples up to `max_resample_attempts`, handles multi-token processing, advances the internal `Stepper`(s), and returns the final chosen token ID(s).

**Parameters:**

*   **`logprobs`**: The processed logits tensor/array (shape `(batch_size, vocab_size)`) after `process_logits` has been applied.
*   **`sampler`**: The base sampling function from your framework (e.g., `torch.multinomial`, `jax.random.categorical`, `tf.random.stateless_categorical`) which takes the logits and returns sampled token ID(s).

**Returns:**

*   A tensor/array containing the chosen token ID(s) for the current step.

---

### `get_structured_output`

```python
get_structured_output(
    output_type: type[OutputType] | None = None,
    raise_on_error: bool = False
) -> OutputType | Any
```

Retrieves the final generated output string from the engine's state, parses it (primarily as JSON), and optionally validates/casts it to a specified Python type (like a Pydantic model).

**Parameters:**

*   **`output_type`** (`type[OutputType] | None`, optional):
    The target Python type (e.g., a Pydantic `BaseModel` subclass) to parse and validate the output against. If `None`, the raw parsed JSON object (or string if JSON parsing fails) is returned. Defaults to `None`.
*   **`raise_on_error`** (`bool`, optional):
    If `True`, raises an error if JSON parsing or Pydantic validation fails. If `False`, logs the error and returns the raw string or partially parsed object. Defaults to `False`.

**Returns:**

*   An instance of `output_type` if provided and validation succeeds, otherwise the parsed JSON object, or the raw string if parsing fails and `raise_on_error` is `False`.

---

### `get_stateful_structured_output`

```python
get_stateful_structured_output(
    output_type: type[OutputType] | None = None,
    raise_on_error: bool = False
) -> Iterator[tuple[str, OutputType | Any]]
```

Retrieves the generated output segmented by the state identifier that produced each part. Useful for complex state machines (like in PBA) where different parts of the output correspond to different logical steps (e.g., "thinking", "tool_call").

**Parameters:**

*   **`output_type`** (`type[OutputType] | None`, optional):
    The target Python type to parse/validate each segment against (applied individually). Defaults to `None`.
*   **`raise_on_error`** (`bool`, optional):
    Whether to raise errors during parsing/validation of segments. Defaults to `False`.

**Returns:**

*   An iterator yielding tuples of `(state_identifier: str, parsed_output: OutputType | Any)`.

---

### `get_live_structured_output`

```python
get_live_structured_output() -> tuple[str, str] | None
```

Attempts to retrieve the *current*, potentially *incomplete* output being generated, along with the identifier of the state currently being processed. Useful for streaming or live display. Relies on `Stepper.get_token_safe_output`.

**Returns:**

*   A tuple `(state_identifier, current_output_string)` if available, otherwise `None`.

---

### `reset`

```python
reset(
    hard_reset: bool = False
) -> None
```

Resets the engine's internal state, clearing active `Stepper`s. If `hard_reset` is `True`, it also removes the configured `StateMachine`.

**Parameters:**

*   **`hard_reset`** (`bool`, optional): If `True`, removes the configured `StateMachine` in addition to resetting steppers. Defaults to `False`.

---

## Properties

*   **`has_reached_accept_state`** (`bool`, read-only):
    Returns `True` if any of the active `Stepper`s have reached a valid end state according to the configured `StateMachine`.
*   **`state_machine`** (`StateMachine | None`):
    The currently configured root `StateMachine` instance. Can be set directly or via `configure`.
*   **`steppers`** (`list[Stepper]`):
    The list of currently active `Stepper` objects representing the engine's state within the `StateMachine`. Can be read or set directly (advanced use).
*   **`vocabulary`** (`TrieMap`, read-only):
    The vocabulary map (string to token ID list) used by the engine, derived from the tokenizer.
*   **`reverse_vocabulary`** (`dict[int, str]`, read-only):
    The reverse vocabulary map (token ID to string).
*   **`multi_token_mapping`** (`dict[int, list[int]]`):
    The internal mapping used for multi-token processing. Can be read or set (advanced use).