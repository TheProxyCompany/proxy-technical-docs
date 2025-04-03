# Model Context Protocol (MCP) Integration

The Proxy Base Agent (PBA) supports dynamic extension of its capabilities at runtime through the **Model Context Protocol (MCP)**. MCP allows PBA to connect to external servers that offer specialized tools and functionalities.

## What is MCP?

MCP is a standardized protocol designed for language models and agents to interact with external services and tools securely and efficiently. An MCP server exposes a set of tools, each with a defined schema, that connected agents can invoke.

Think of MCP servers as plug-and-play capability providers for your agent.

## How PBA Uses MCP

PBA integrates with MCP through a built-in workflow facilitated by specific tools and internal mechanisms:

1.  **Discovery (`list_mcp_servers` Tool):** The agent can use the built-in `list_mcp_servers` tool to discover available MCP servers defined in its configuration (typically `agent/mcp/servers/servers_list.json`). This tool returns information about each server, including its name, description, and identifier.
2.  **Connection (`add_mcp_server` Tool):** Based on its planning and the information from `list_mcp_servers`, the agent can decide to connect to a specific server using the built-in `add_mcp_server` tool, providing the server's unique identifier.
3.  **Runtime Integration:** When `add_mcp_server` is called:
    *   PBA's `MCPHost` establishes a connection to the server using an `MCPClient`.
    *   The agent retrieves the list of tools offered by that server.
    *   These external tools are converted into standard PBA `Tool` objects.
    *   The agent calls its internal `add_tools()` method.
    *   Crucially, `add_tools()` triggers `agent.configure()`, which **rebuilds the `AgentStateMachine` and reconfigures the underlying PSE `StructuringEngine`** with the updated list of tools (including the newly added ones from the MCP server).
4.  **Reliable Usage:** Once connected and configured, the tools from the MCP server are seamlessly available within the agent's `ToolCallState`. The agent can generate calls to these tools, and PSE provides the **same guarantee of structural validity** for these dynamically added tools as it does for locally defined tools.

## Benefits of MCP Integration

*   **Dynamic Adaptability:** Add or remove agent capabilities without restarting or modifying the agent's core code.
*   **Extensibility:** Easily integrate specialized third-party services or internal microservices.
*   **Modularity:** Keep specialized logic separate from the core agent framework.
*   **Reliability:** Dynamically added tools still benefit from PSE's schema enforcement guarantees.

## Managing Servers

*   Available servers are defined in `agent/mcp/servers/servers_list.json`. You can add definitions for custom or private MCP servers here.
*   MCP servers may require specific environment variables for authentication or configuration. PBA attempts to pass these from the agent's environment to the server process during connection (see `agent/mcp/client.py`). Ensure necessary variables are set in the agent's environment.

MCP provides a powerful mechanism for creating adaptive and highly capable agents by decoupling core logic from specialized, dynamically loaded functionalities.