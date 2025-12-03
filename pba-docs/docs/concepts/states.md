# Agent States

Agent States are the building blocks of the Proxy Base Agent's (PBA) behavior, defined within its core [State Machine](./state-machine.md). Each state represents a distinct phase or capability within the agent's operational cycle.

## State Structure

Every `AgentState` in PBA typically includes:

*   **Identifier:** A unique machine-readable name (e.g., `thinking`, `tool_call`).
*   **Readable Name:** A human-friendly name for display (e.g., "Thinking", "External Tool Use").
*   **Delimiters:** A pair of strings (e.g., `("```thinking\n", "\n```")`) used by the agent to signal the start and end of content generated within that state.
*   **State Machine (via PSE):** A nested Proxy State Engine (PSE) `StateMachine` that defines and enforces the *structure* of the content allowed *within* that state.
*   **State Prompt:** Instructions provided to the LLM explaining the purpose of the state and how to use its delimiters and structure.
*   **UI Properties:** Color and emoji for visual representation in interfaces.

## Default States in PBA

The standard PBA includes several pre-defined states grouped into Planning and Action phases:

### Planning States

These states are used within the agent's planning loop for internal reasoning and strategy formulation. The content generated here is typically *not* shown directly to the user.

*   **`Thinking`:** For deliberate, analytical thought processes (System 2 thinking). Simulates conscious reflection, reasoning about the task, and planning the next steps. Uses a `FencedFreeformStateMachine` to allow relatively unstructured text within its delimiters.
*   **`Scratchpad`:** For quick notes, temporary calculations, or outlining steps. Mimics jotting down ideas. Also uses a `FencedFreeformStateMachine`.
*   **`InnerMonologue`:** For more detailed, narrative-style internal dialogue. Allows the agent to explore nuances and build a coherent mental model. Uses a `FencedFreeformStateMachine`.

### Action States

These states are used when the agent needs to interact with the external environment or execute specific tasks after planning.

*   **`ToolCallState`:** The state for invoking external tools. Its internal PSE `StateMachine` is dynamically built based on the schemas of all currently available tools, ensuring the LLM generates a valid call structure (tool name + arguments matching one tool's schema).
*   **`Python`:** (Optional) Allows the agent to generate and request the execution of Python code snippets within a sandboxed environment. Uses a `PythonStateMachine` (via PSE's grammar types) wrapped in delimiters to ensure syntactically valid Python code.

## Role of PSE within States

Crucially, the nested PSE `StateMachine` associated with each `AgentState` enforces the structure *within* that state's output. For example:

*   The `ToolCallState`'s machine guarantees the output is valid JSON matching a known tool schema.
*   The `Python` state's machine guarantees the output is syntactically valid Python code.
*   The planning states' machines guarantee the output is correctly enclosed within the specified delimiters.

This ensures that even the agent's internal steps and action requests are structurally sound and reliable.

## Extending with Custom States

You can define and integrate your own custom `AgentState` classes to add unique capabilities or modify the agent's workflow. See [Custom States](../extending/custom-states.md).
