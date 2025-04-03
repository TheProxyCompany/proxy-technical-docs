# Stepper

If the `StateMachine` defines the *state map*, the `Stepper` is the *navigator* that tracks the current position within that map during generation. It represents an active state or hypothesis about the structure being generated.

## Key Concepts

*   **Position Tracking:** A `Stepper` holds the `current_state` within its associated `StateMachine`. It knows where it is in the state graph.
*   **Immutability:** Steppers generally follow an immutable pattern. Operations like consuming a token (`consume`) or branching (`branch`) typically return *new* `Stepper` instances representing the subsequent state(s), rather than modifying the original stepper. This is crucial for exploring multiple valid paths simultaneously in non-deterministic grammars.
*   **Hierarchical Traversal:** When a `StateMachine` transition involves a nested `StateMachine`, the parent `Stepper` creates and manages a `sub_stepper` to traverse the nested machine. The parent stepper only advances its own state (`current_state` -> `target_state`) once the `sub_stepper` successfully reaches an end state.
*   **History:** A `Stepper` maintains a `history` list, which stores the sequence of completed sub-steppers that led to its current state. This allows reconstruction of the generated structure.
*   **Value Accumulation:** Steppers accumulate the raw string output (`_raw_value`) corresponding to the path they've taken. Methods like `get_current_value` can parse this raw string into appropriate Python types (though final parsing is usually handled by the `StructuringEngine`).
*   **State Checks:** Steppers provide methods to query their status:
    *   `has_reached_accept_state()`: Checks if the stepper (and its sub-stepper, if active) is currently in a valid end state according to its `StateMachine`.
    *   `can_accept_more_input()`: Checks if further tokens can be consumed based on grammar rules (e.g., character limits).
    *   `is_within_value()`: Indicates if the stepper is actively consuming characters for a specific value (e.g., inside a string literal).
    *   `get_valid_continuations()`: Returns the set of strings that are valid next steps from the current state.
*   **Interaction with StateMachine:** Steppers use their associated `StateMachine` to determine valid transitions (`get_transitions`) and to advance their state (`advance_stepper`).

## Role in PSE

During generation, the `StructuringEngine` maintains a list of active `Stepper` objects. When processing logits, it queries these steppers (via `get_valid_continuations`) to determine which tokens are allowed next. When sampling a token, the engine uses the steppers' `consume` method to generate the next set of active steppers, reflecting the updated positions in the grammar graph. The engine manages potentially multiple active steppers simultaneously to handle grammatical ambiguity, eventually selecting the best path based on criteria like reaching an accept state and token probabilities (see `StepperDelta`).