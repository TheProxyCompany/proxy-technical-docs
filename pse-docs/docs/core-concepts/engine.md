# Engine

The `StructuringEngine` (Python class `pse.StructuringEngine`, inheriting from the core `Engine`) is the central orchestrator within PSE. It acts as the primary interface for developers, managing the interaction between the language model, the defined structure (`StateMachine`), and the tokenization process.

## Key Responsibilities

*   **Configuration:** Accepts high-level schema definitions (Pydantic models, JSON Schema, function signatures, or custom `StateMachine` objects) via its `configure` method. It translates these definitions into the internal `StateMachine` representation used for enforcement.
*   **LLM Integration:** Provides the necessary hooks (`process_logits`, `sample`) to integrate with language model generation loops (e.g., Hugging Face `transformers`).
    *   `process_logits`: Modifies the LLM's output logit distribution at each step, masking tokens that would violate the structure defined by the current state(s) of the active `Stepper`(s). This is the core of the structural guarantee.
    *   `sample`: Wraps the base sampling logic. It receives the processed logits, calls the base sampler, and then uses the sampled token ID(s) to advance the internal `Stepper`(s) according to the `StateMachine`. It handles multi-token processing and path selection (`StepperDelta`) internally.
*   **State Management:** Maintains the set of active `Stepper` objects, representing all valid hypotheses about the structure being generated according to the `StateMachine`.
*   **Tokenization Awareness:** Uses the provided tokenizer (e.g., from `transformers`) to map between token IDs and strings, enabling features like Token Healing and Multi-Token Processing by understanding the vocabulary.
*   **Output Retrieval:** Provides methods (`get_structured_output`, `get_stateful_structured_output`) to retrieve the final generated string (reconstructed accurately using token history) and parse/validate it against the target schema (e.g., into a Pydantic model).

## Role in PSE

The `StructuringEngine` ties all the components of PSE together:

1.  It takes the user-defined **Structure** (via `configure`).
2.  It uses the **Tokenizer** to understand the LLM's vocabulary.
3.  It manages the **Steppers** navigating the **StateMachine**.
4.  It modifies the **LLM's Output** (logits) at runtime.
5.  It handles **Sampling** and advances the state.
6.  It provides the final, **Guaranteed Structured Output**.

Developers primarily interact with the `StructuringEngine` instance to set up PSE and retrieve the results, while the underlying `StateMachine` and `Stepper` objects manage the detailed state traversal and validation internally.