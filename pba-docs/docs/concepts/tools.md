# Tools

Tools are a crucial part of the Proxy Base Agent's capabilities.

They allow the agent to interact with the external world, access information, and perform actions beyond its core logic.

## What are Tools?

Tools are self-contained modules that encapsulate specific functionality.  They can be:

*   **API Wrappers:**  Provide access to external services like weather APIs, search engines, or databases.
*   **Custom Functions:**  Perform specific computations, data manipulations, or other tasks.
*   **Code Executors:** Execute code in different languages (e.g., Python, JavaScript).

## Tool Interaction

The agent interacts with tools through a standardized flow:

1.  **Selects a Tool:** Based on its current state and plan, the agent chooses the appropriate tool to use.
2.  **Provides Input:** The agent prepares the necessary input data for the tool.
3.  **Calls the Tool:** The agent invokes the tool with the provided input.
4.  **Receives Output:** The tool processes the input and returns the results to the agent.
5.  **Processes Output:** The agent integrates the tool's output into its state and continues its processing.
