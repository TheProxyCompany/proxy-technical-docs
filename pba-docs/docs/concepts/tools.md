# Tools

Tools are the primary mechanism through which the Proxy Base Agent (PBA) interacts with the external world, performs actions, and accesses capabilities beyond the core language model.

## What are Tools?

In PBA, a Tool represents a specific, callable function or capability. Examples include:

*   **API Wrappers:** Interacting with web services (e.g., weather, search, databases).
*   **Custom Functions:** Performing specific calculations, data processing, or logic defined by the developer.
*   **Code Execution:** Running code snippets (like the built-in `Python` state).
*   **User Interaction:** Sending messages back to the user (like the built-in `send_message` tool).

Each tool is defined with:

1.  **Name:** A unique identifier (e.g., `web_search`, `send_message`).
2.  **Description:** A natural language explanation of what the tool does and when to use it (used in the agent's prompt).
3.  **Schema:** A formal definition (typically JSON Schema derived from Python type hints or Pydantic models) specifying the input arguments the tool requires.
4.  **Implementation:** The actual Python code (callable) that executes the tool's logic.

## Reliable Tool Interaction via PSE

A key differentiator for PBA is how it handles tool interactions using the Proxy Structuring Engine (PSE):

1.  **Tool Selection:** During the Planning Phase, the agent reasons about which tool (if any) is needed to accomplish the current task.
2.  **Structured Invocation:** When the agent transitions to the `ToolCallState`, it must generate output conforming to the JSON schema of *one* of the available tools. PSE *enforces* this structure at runtime.
3.  **Guaranteed Schema:** This means the agent *cannot* hallucinate non-existent tools or provide arguments that don't match the required types or format for the selected tool. Malformed tool calls are prevented *before* they happen.
4.  **Execution:** PBA receives the guaranteed-valid tool call structure (name and arguments) and executes the corresponding tool implementation.
5.  **Result Processing:** The tool's output (often formatted as an `Interaction` object) is returned to the agent's memory and informs the next step in its process.

This PSE-driven approach eliminates a major source of unreliability found in traditional agents, ensuring that tool calls are always structurally correct and executable.

## Adding Custom Tools

You can easily extend PBA's capabilities by adding your own custom tools. See the [Custom Tools](../extending/custom-tools.md) guide for details.

## Model Context Protocol (MCP)

PBA also supports dynamically loading tools at runtime from external servers using the Model Context Protocol (MCP). These tools are integrated seamlessly and benefit from the same PSE schema guarantees. See [MCP Integration](../extending/model-context-protocol.md) (Content Pending).