# API Reference

This section provides detailed reference documentation for the core classes and components of the Proxy Base Agent (PBA).

Understanding these APIs is essential for extending PBA, integrating it into larger systems, or customizing its behavior at a code level.

## Key Components

*   **[Agent](./agent.md):** The main orchestrator class managing the agent's lifecycle, state, memory, tools, and interaction with the LLM backend.
*   **[Tool & ToolCall](./tool.md):** Classes defining external capabilities (`Tool`) and the structure for invoking them (`ToolCall`).
*   **[AgentState](./state.md):** The base class for defining individual states within the agent's state machine and the default states provided by PBA.
