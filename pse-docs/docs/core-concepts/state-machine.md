# State Machine

The `StateMachine` is the core component in PSE responsible for defining the structure or grammar that the language model's output must adhere to. It represents this structure as a graph where states are nodes and transitions between states are edges.

## Key Concepts

*   **Graph Structure:** A `StateMachine` defines a directed graph. Each node represents a specific point or state within the grammar (e.g., "expecting an opening brace," "inside a string," "expecting a comma or closing bracket").
*   **States (`StateId`):** States are identified by either an integer or a string. Every state machine has a designated `start_state` and one or more `end_states` which signify a valid completion of the structure defined by that machine.
*   **Transitions (`Edge`):** An edge represents a valid transition from one state to another. Crucially, each transition is associated with *another* `StateMachine` instance. This nested `StateMachine` must be successfully traversed (i.e., reach its end state) for the transition in the parent machine to be considered valid. This allows for hierarchical and recursive grammar definitions.
*   **Hierarchy:** Because transitions are themselves `StateMachine`s, complex grammars (like nested JSON objects or code structures) can be built by composing smaller, simpler `StateMachine`s.
*   **Traversal:** The actual process of moving through the state machine during generation is handled by `Stepper` objects (see [Stepper Concept](./stepper.md)). The `StateMachine` provides methods like `get_transitions` and `advance_stepper` that the `Stepper` uses to determine valid moves based on incoming tokens.
*   **Properties:** State machines can have properties like `is_optional` (allowing the entire structure they define to be skipped) and `is_case_sensitive` (controlling token matching).

## Role in PSE

When you configure the `StructuringEngine` with a schema (like a Pydantic model or JSON Schema), PSE translates that schema into a root `StateMachine` object. This object, potentially composed of many nested `StateMachine`s, represents the complete grammar. The engine then uses this `StateMachine` graph at runtime to guide the LLM's token generation, ensuring the output strictly conforms to the defined structure. You can also build custom `StateMachine`s directly using PSE's base types for more complex control flows.