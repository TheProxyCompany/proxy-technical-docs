# Core Concepts

The Proxy Base Agent (PBA) is built upon several core concepts that enable its reliable and extensible nature. Understanding these concepts is key to effectively using and customizing the agent.

## 1. State Machine Architecture

PBA's behavior is not driven by simple prompt chains, but by a formal **Hierarchical State Machine (HSM)**. This machine defines distinct phases (like Planning and Action) and specific states (like Thinking, Tool Call) the agent transitions through.

*   **Reliability:** The HSM structure, enforced by the underlying Proxy Structuring Engine (PSE), guarantees that the agent follows the defined workflow predictably.
*   **Control:** Developers have explicit control over the agent's execution flow.

[Learn more about the State Machine](./state-machine.md)

## 2. Agent States

Each step in the agent's HSM is represented by an **Agent State**. These states encapsulate specific functionalities:

*   **Planning States:** `Thinking`, `Scratchpad`, `InnerMonologue` allow the agent to reason and plan internally.
*   **Action States:** `ToolCallState`, `Python` enable the agent to interact with the external environment or execute code.

Each state uses its own nested PSE `StateMachine` to define and enforce the structure of the content generated *within* that state.

[Learn more about States](./states.md)

## 3. Tools

Tools are external capabilities the agent can invoke during its Action Phase. They allow the agent to interact with APIs, databases, code interpreters, or perform specialized tasks.

*   **Reliable Invocation:** PBA uses PSE to guarantee that the arguments provided to a tool call match the tool's defined schema *before* execution.
*   **Extensibility:** New tools can be easily added to expand the agent's capabilities.

[Learn more about Tools](./tools.md)

## 4. Proxy Structuring Engine (PSE) Integration

PSE is the foundational technology that makes PBA's reliability possible.

*   **Runtime Enforcement:** PSE integrates into the LLM's generation loop, using the defined HSMs (both the main agent HSM and the nested state HSMs) to constrain the LLM's output at runtime.
*   **Guarantees:** This ensures structurally valid outputs for states and tool calls, and enforces valid transitions between agent states.

Understanding PSE concepts enhances your ability to customize PBA. [See PSE Documentation](https://docs.theproxycompany.com/pse/)

## 5. Model Context Protocol (MCP)

PBA supports dynamic tool integration at runtime using the Model Context Protocol (MCP).

*   **Adaptability:** Agents can connect to MCP servers to gain access to new tools without restarting or retraining.
*   **Reliability:** Tools loaded via MCP are integrated into the `ToolCallState` and benefit from the same PSE-guaranteed schema enforcement.

[Learn more about MCP Integration](../extending/model-context-protocol.md)

These core concepts work together to create an agent framework focused on engineered reliability, control, and adaptability.
