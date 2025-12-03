# State Graph Traversal

The core of the Proxy State Engine's (PSE) reliability and efficiency lies in its unique approach to navigating the grammar defined by the `StateMachine`. Unlike traditional parsing methods that might rely on backtracking, PSE employs a parallel, forward-only traversal algorithm that explores all valid structural possibilities simultaneously.

## Core Principles

PSE's traversal algorithm is built on these key principles:

1.  **Hierarchical State Machines (HSMs):** Grammars are represented as graphs where transitions between states are themselves governed by nested `StateMachine`s. This allows for representing complex, recursive structures efficiently.
2.  **Active Steppers:** The engine maintains a list of active `Stepper` objects. Each `Stepper` represents a current hypothesis or valid position within the `StateMachine` graph.
3.  **Parallel Exploration:** When a token is processed, *all* active `Stepper`s attempt to consume it. A single token might lead to multiple valid next states, resulting in the creation of new `Stepper` instances. This explores all valid paths concurrently.
4.  **Immutability:** `Stepper` operations (like consuming a token) typically return *new* stepper instances representing the next state, rather than modifying the original. This prevents state interference between parallel paths.
5.  **Deterministic Path Selection:** When multiple valid paths exist after processing a token (represented by multiple `StepperDelta` objects), a deterministic algorithm (`StepperDelta.choose_best_path`) selects the single "best" path based on criteria like reaching an accept state, token healing status, and token probability scores. This resolves ambiguity without backtracking.

## The Traversal Loop (Simplified)

During generation, the process at each step looks roughly like this:

1.  **Get Valid Continuations:** The `StructuringEngine` queries all active `Stepper`s using `get_valid_continuations()` to determine the set of all possible next token strings allowed by the grammar from the current positions.
2.  **Mask Logits:** The engine uses this information to mask the LLM's raw logits, setting the probability of invalid tokens to negative infinity (`process_logits`).
3.  **Sample Token:** The engine calls the base sampler on the masked logits. The sampled token ID is guaranteed to be structurally valid (`sample`).
4.  **Advance Steppers:** The engine uses the sampled token ID(s) to advance the set of active `Stepper`s. This involves:
    *   Decoding the token ID(s) to string(s).
    *   Calling `StateMachine.advance_all` (which internally uses `Stepper.consume`) on the active steppers with the token string. This generates a list of `StepperDelta` objects, representing potential next states.
    *   Applying `StepperDelta.choose_best_path` to select the single best token path and its associated resulting `Stepper`(s).
    *   Updating the list of active `Stepper`s for the next generation step.
5.  **Repeat:** The loop continues until a `Stepper` reaches a designated `end_state` in the root `StateMachine`.

This forward-only, parallel exploration combined with deterministic path selection allows PSE to handle complex and ambiguous grammars efficiently while guaranteeing structural correctness at every step.
