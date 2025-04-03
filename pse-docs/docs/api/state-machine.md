# StateMachine API

This page details the API for the `pse_core.StateMachine` class, which is the base class for defining grammars and structures within PSE. While you often configure the `StructuringEngine` with higher-level schemas (Pydantic, JSON Schema), you can also create or subclass `StateMachine` directly for advanced control.

```python
class pse_core.StateMachine(
    state_graph: StateGraph | None = None,
    start_state: StateId = 0,
    end_states: list[StateId] | None = None,
    is_optional: bool = False,
    is_case_sensitive: bool = True,
    identifier: str | None = None
)
```

Defines a grammar as a finite state machine graph.

**Parameters:**

*   **`state_graph`** (`StateGraph | None`, optional):
    A dictionary mapping state IDs (`StateId`) to lists of transitions (`Edge`). An `Edge` is a tuple `(StateMachine, StateId)` representing a transition validated by the nested `StateMachine` leading to the target `StateId`. Defaults to an empty graph.
*   **`start_state`** (`StateId`, optional):
    The identifier of the initial state for this machine. Defaults to `0`.
*   **`end_states`** (`list[StateId] | None`, optional):
    A list of state IDs that represent valid completion points for this machine. Defaults to `["$"]`.
*   **`is_optional`** (`bool`, optional):
    If `True`, this entire state machine can be skipped during traversal. Defaults to `False`.
*   **`is_case_sensitive`** (`bool`, optional):
    If `True`, token matching within this machine (e.g., by nested `PhraseStateMachine`s) is case-sensitive. Defaults to `True`.
*   **`identifier`** (`str | None`, optional):
    A human-readable identifier for this state machine instance, useful for debugging and stateful output retrieval. Defaults to `None`.

---

## Methods

### `get_new_stepper`

```python
get_new_stepper(
    state: StateId | None = None
) -> Stepper
```

Creates a new `Stepper` instance initialized to traverse this `StateMachine`.

**Parameters:**

*   **`state`** (`StateId | None`, optional):
    The state ID to start the stepper at. If `None`, uses the machine's `start_state`. Defaults to `None`.

**Returns:**

*   (`Stepper`): A new stepper instance.

---

### `get_steppers`

```python
get_steppers(
    state: StateId | None = None
) -> list[Stepper]
```

Creates one or more initial `Stepper` instances for this machine. Can return multiple steppers if the starting state allows for different initial paths (e.g., via an `AnyStateMachine` transition).

**Parameters:**

*   **`state`** (`StateId | None`, optional):
    The state ID to start the steppers at. If `None`, uses the machine's `start_state`. Defaults to `None`.

**Returns:**

*   (`list[Stepper]`): A list of new stepper instances.

---

### `get_edges`

```python
get_edges(
    state: StateId
) -> list[Edge]
```

Returns the list of outgoing transitions (`Edge` tuples) from the specified state.

**Parameters:**

*   **`state`** (`StateId`): The state ID to query.

**Returns:**

*   (`list[Edge]`): A list of `(StateMachine, StateId)` tuples representing valid transitions.

---

### `get_transitions`

```python
get_transitions(
    stepper: Stepper
) -> list[tuple[Stepper, StateId]]
```

Gets the possible initial sub-steppers and target states for transitions originating from the given stepper's current state.

**Parameters:**

*   **`stepper`** (`Stepper`): The stepper whose current state's transitions are being queried.

**Returns:**

*   (`list[tuple[Stepper, StateId]]`): A list where each tuple contains a new sub-stepper (for validating the transition) and the target state ID in the parent machine.

---

### `advance_stepper`

```python
advance_stepper(
    stepper: Stepper,
    token: str
) -> list[Stepper]
```

Advances a given stepper by consuming a token string. This is primarily used internally by `Stepper.consume`.

**Parameters:**

*   **`stepper`** (`Stepper`): The stepper to advance.
*   **`token`** (`str`): The token string to consume.

**Returns:**

*   (`list[Stepper]`): A list of new steppers representing the possible states after consuming the token.

---

### `branch_stepper`

```python
branch_stepper(
    stepper: Stepper,
    token: str | None = None
) -> list[Stepper]
```

Creates multiple branched steppers from a given stepper, exploring different possible transitions simultaneously. Used internally by `Stepper.branch`.

**Parameters:**

*   **`stepper`** (`Stepper`): The stepper to branch from.
*   **`token`** (`str | None`, optional): An optional token to consider when determining valid branches. Defaults to `None`.

**Returns:**

*   (`list[Stepper]`): A list of new steppers representing different branches.

---

### `advance_all` (Static Method)

```python
@staticmethod
advance_all(
    steppers: list[Stepper],
    token: str,
    vocab: TrieMap | None = None,
    token_healing: bool = True
) -> list[StepperDelta]
```

Advances multiple steppers simultaneously with a single token. Handles token healing if `vocab` is provided. This is primarily used internally by the `StructuringEngine`.

**Parameters:**

*   **`steppers`** (`list[Stepper]`): The list of active steppers to advance.
*   **`token`** (`str`): The token string to consume.
*   **`vocab`** (`TrieMap | None`, optional): The vocabulary TrieMap for token healing. Defaults to `None`.
*   **`token_healing`** (`bool`, optional): Whether to enable token healing. Defaults to `True`.

**Returns:**

*   (`list[StepperDelta]`): A list of `StepperDelta` objects representing the results of the transitions for each input stepper.

---

### `advance_all_basic` (Static Method)

```python
@staticmethod
advance_all_basic(
    steppers: list[Stepper],
    token: str
) -> list[Stepper]
```

A simplified version of `advance_all` that only returns the resulting steppers, discarding metadata like healing status.

**Parameters:**

*   **`steppers`** (`list[Stepper]`): The list of active steppers to advance.
*   **`token`** (`str`): The token string to consume.

**Returns:**

*   (`list[Stepper]`): A list of the resulting steppers after consuming the token.

---

## Properties

*   **`state_graph`** (`StateGraph`):
    The dictionary defining the state transitions. Read/write.
*   **`start_state`** (`StateId`):
    The identifier of the starting state. Read/write.
*   **`end_states`** (`list[StateId]`):
    The list of identifiers for valid end states. Read/write.
*   **`is_optional`** (`bool`):
    Whether the state machine is optional. Read/write.
*   **`is_case_sensitive`** (`bool`):
    Whether token matching should be case-sensitive. Read/write.
*   **`identifier`** (`str | None`):
    The human-readable identifier for this instance. Read/write.