# Overview

The Proxy Base Agent is designed to be a flexible and extensible foundation for building intelligent agents. It achieves this through a combination of a state machine architecture and tool integration, all powered by the Proxy Structuring Engine (PSE).

## Core Concepts

*   **State Machine:** The agent's behavior is defined by a state machine.  Each state represents a specific step in the agent's processing, such as thinking, planning, or executing an action. Transitions between states are triggered by conditions and events. This allows for complex, multi-step reasoning and action sequences.

*   **Tools:** The agent can interact with external tools and APIs. Tools are self-contained units of functionality that the agent can call upon to perform specific tasks, such as retrieving information, interacting with services, or executing code.

*   **Proxy Structuring Engine (PSE):** The PSE provides the underlying framework for defining and managing the agent's state machine, tools, and overall execution. It handles the complexities of state transitions, input/output processing, and error handling.

## Architecture

The agent's architecture can be visualized as follows:

The agent primarily cycles between **Planning** states (Thinking, Scratchpad, Inner Monologue) and **Action** states (Tool calls, Python code execution). This separation allows the agent to reason about its goals and plan its actions before executing them. The loop in the planning phase allows for iterative refinement of the plan.

## Base Agent vs. Custom Agents

The Proxy Base Agent is designed to be a *starting point*. It provides a basic set of states and tools, demonstrating the core capabilities of the PSE.  You can extend this base agent by:

*   **Adding Custom Tools:** Integrate new tools to handle specific tasks relevant to your application.
*   **Creating Custom States:** Define new states to model more complex behaviors and workflows.
*   **Modifying Existing Logic:** Adjust the transitions and actions within existing states to fine-tune the agent's behavior.
