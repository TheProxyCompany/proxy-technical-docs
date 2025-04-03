# Extending the Proxy Base Agent

The Proxy Base Agent (PBA) is designed as a foundation. While it provides a robust core loop for planning and action, its true power lies in its extensibility. You can tailor PBA to specific tasks and domains by adding custom capabilities and modifying its core behavior.

## Key Extension Points

There are several ways to extend and customize PBA:

1.  **[Custom Tools](./custom-tools.md):**
    *   **What:** Define new Python functions that the agent can call to interact with external APIs, databases, or perform specialized computations.
    *   **Why:** This is the most common way to add new capabilities and ground the agent in specific data or services relevant to your application.
    *   **How:** Create a Python file in `agent/tools/`, define your function with type hints and a docstring. PBA automatically discovers it, generates a schema, and makes it available to the `ToolCallState`.

2.  **[Custom States](./custom-states.md):**
    *   **What:** Define entirely new `AgentState` classes with their own unique logic, prompts, delimiters, and internal PSE `StateMachine` for structure enforcement.
    *   **Why:** Allows you to add distinct phases or modes of operation to the agent beyond the default Planning/Action states (e.g., a "Summarization" state, a "User Feedback" state).
    *   **How:** Subclass `agent.state.AgentState`, implement the required properties (`state_machine`, `state_prompt`), and integrate it into the main `AgentStateMachine`.

3.  **[Custom State Graphs](./custom-state-graphs.md):**
    *   **What:** Modify the main `AgentStateMachine` definition in `agent/state_machine.py`.
    *   **Why:** Change the agent's core workflow. You could alter the planning loop, add parallel action paths, introduce conditional transitions, or create entirely different high-level agent architectures.
    *   **How:** Directly edit the `state_graph` dictionary within the `AgentStateMachine` class, defining new states and transitions using existing or custom `AgentState` instances. Requires understanding PSE `StateMachine` composition.

4.  **[Model Context Protocol (MCP)](./model-context-protocol.md):**
    *   **What:** Connect the agent to external MCP servers at runtime.
    *   **Why:** Dynamically load tools and capabilities from other services without modifying the agent's core code. Enables building distributed, adaptive agent systems.
    *   **How:** Use the built-in `list_mcp_servers` and `add_mcp_server` tools. PBA handles the connection and dynamic reconfiguration of the `ToolCallState`.

## Choosing the Right Extension Method

*   For adding specific actions or API interactions: Start with **Custom Tools**.
*   For adding new distinct phases or modes to the agent's workflow: Use **Custom States** and modify the **State Graph**.
*   For fundamentally changing the agent's core execution loop: Modify the **State Graph**.
*   For integrating external, dynamically available capabilities: Use **MCP**.

By leveraging these extension points, you can transform the Proxy Base Agent from a general foundation into a specialized agent tailored precisely to your needs.