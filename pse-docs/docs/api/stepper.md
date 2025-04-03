# Stepper API

This page details the API for the `pse_core.Stepper` class. Steppers track the current position within a `StateMachine` during generation. Developers typically don't instantiate `Stepper`s directly but interact with them via the `StructuringEngine`. Understanding the `Stepper` API can be helpful for debugging or advanced customization.

```python
class pse_core.Stepper(
    state_machine: StateMachine,
    current_state: StateId | None = None
)
```

Represents a position within a state machine and manages traversal.

**Parameters:**

*   **`state_machine`** (`StateMachine`):
    The `StateMachine` instance this stepper will traverse.
*   **`current_state`** (`StateId | None`, optional):
    The initial state ID within the `state_machine`. If `None`, defaults to the `state_machine`'s `start_state`.

---

## Methods

### `clone`

```python
clone() -> Stepper
```

Creates a deep copy of this stepper, including its current state, history, and associated sub-stepper (if any). Essential for exploring multiple grammar paths.

**Returns:**

*   (`Stepper`): A new `Stepper` instance identical to the original.

---

### `consume`

```python
consume(
    token: str
) -> list[Stepper]
```

Consumes a token string and advances the stepper's state according to its `StateMachine`. This is the primary method for processing tokens during generation, often called internally by the `StructuringEngine`. It handles transitions, sub-stepper management, and branching.

**Parameters:**

*   **`token`** (`str`): The token string to consume.

**Returns:**

*   (`list[Stepper]`): A list of new `Stepper` instances representing all possible valid states after consuming the token. Returns an empty list if the token leads to no valid states.

---

### `get_current_value`

```python
get_current_value() -> Any
```

Returns the accumulated value parsed from the raw string generated along the stepper's path so far. Attempts to parse as JSON (number, boolean, object, array) first, falling back to the raw string if JSON parsing fails.

**Returns:**

*   (`Any`): The parsed Python object (e.g., `int`, `float`, `bool`, `dict`, `list`) or the raw `str`. Returns `None` if no value has been accumulated.

---

### `get_raw_value`

```python
get_raw_value() -> str
```

Returns the raw, concatenated string output generated along the stepper's path (including history and any active sub-stepper) without attempting any parsing or type conversion.

**Returns:**

*   (`str`): The raw accumulated string.

---

### `get_valid_continuations`

```python
get_valid_continuations() -> list[str]
```

Returns a list of strings representing all valid token sequences that can legally follow the stepper's current state according to its `StateMachine`. Used by the `StructuringEngine` to determine which tokens to allow during logit processing.

**Returns:**

*   (`list[str]`): A list of valid continuation strings.

---

### `get_invalid_continuations`

```python
get_invalid_continuations() -> list[str]
```

Returns a list of strings that are explicitly *invalid* continuations from the current state. This is less commonly used than `get_valid_continuations` but can be implemented by custom `StateMachine` subclasses for specific exclusion rules.

**Returns:**

*   (`list[str]`): A list of invalid continuation strings.

---

### `has_reached_accept_state`

```python
has_reached_accept_state() -> bool
```

Checks if the stepper (and its sub-stepper, if active) is currently in a state designated as an `end_state` by its `StateMachine`.

**Returns:**

*   (`bool`): `True` if the stepper is in a valid terminal state, `False` otherwise.

---

### `can_accept_more_input`

```python
can_accept_more_input() -> bool
```

Checks if the stepper can consume more tokens based on the rules of its current `StateMachine` (e.g., character limits in a `CharacterStateMachine`).

**Returns:**

*   (`bool`): `True` if more input can be processed, `False` otherwise.

---

### `is_within_value`

```python
is_within_value() -> bool
```

Indicates if the stepper is currently in the process of accumulating characters for a specific value (e.g., inside a string literal, number, etc.), as opposed to being between structural elements.

**Returns:**

*   (`bool`): `True` if actively consuming value characters.

---

### `accepts_any_token`

```python
accepts_any_token() -> bool
```

Indicates if the stepper's current state allows *any* token as a valid continuation (often true for free-form text states).

**Returns:**

*   (`bool`): `True` if any token is currently valid.

---

### `get_identifier`

```python
get_identifier() -> str | None
```

Returns the identifier string associated with the stepper's current `StateMachine` or its active sub-stepper's `StateMachine`. Used by `get_stateful_structured_output`.

**Returns:**

*   (`str | None`): The identifier string, or `None`.

---

### `get_token_ids_history`

```python
get_token_ids_history() -> list[int]
```

Returns the sequence of token IDs that were consumed along the path taken by this stepper and its history. Used for accurate output reconstruction via `get_token_safe_output`.

**Returns:**

*   (`list[int]`): The list of consumed token IDs.

---

### `get_token_safe_output`

```python
get_token_safe_output(
    decode_function: Callable[[list[int]], str]
) -> str
```

Reconstructs the generated string output accurately by decoding the stored `token_ids_history` using the provided `decode_function`. This avoids potential errors from decoding the `raw_value` directly, especially if token healing occurred.

**Parameters:**

*   **`decode_function`** (`Callable[[list[int]], str]`): The tokenizer's decode function.

**Returns:**

*   (`str`): The accurately reconstructed output string.

---

## Properties

*   **`state_machine`** (`StateMachine`):
    The `StateMachine` this stepper is traversing. Read/write.
*   **`current_state`** (`StateId`):
    The current state ID within the `state_machine`. Read/write.
*   **`target_state`** (`StateId | None`):
    The target state ID for an in-progress transition. Read/write.
*   **`sub_stepper`** (`Stepper | None`):
    The active sub-stepper handling a nested `StateMachine` traversal, if any. Read/write.
*   **`history`** (`list[Stepper]`):
    The list of completed sub-steppers that led to the current state. Read/write.
*   **`consumed_character_count`** (`int`):
    The number of characters consumed along this stepper's path. Read/write.
*   **`remaining_input`** (`str | None`):
    Any portion of the last consumed token that was *not* processed by the current step. Read/write.
*   **`_raw_value`** (`str | None`):
    The raw accumulated string value. Use `get_raw_value()` for access. Read/write (internal use primarily).