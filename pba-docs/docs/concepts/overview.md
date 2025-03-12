# Overview

The Proxy Base Agent is designed to be a flexible and extensible foundation for building intelligent agents.

It achieves this through a novel state machine architecture and tool use integration, all powered by the Proxy Structuring Engine (PSE).

## Core Concepts

*   **State Machine:** The agent's behavior is defined by a state machine. Each state represents a specific step in the agent's processing, such as planning, or executing an action. Each state can contain sub-states, which allow for more complex behaviors. Text based delimeters are used to separate the different states, and the language model transitions between states based on these delimeters.

*   **Tools:** The agent can interact with external tools and APIs. Tools are self-contained units of functionality that the agent can call upon to perform specific tasks, such as retrieving information, interacting with services, or executing code.

*   **Proxy Structuring Engine (PSE):** The PSE provides the underlying framework for defining and managing the agent's state machine, tools, and overall execution. It handles the complexities of state transitions, input/output processing, and error handling.


## Base Agent vs. Custom Agents

The Proxy Base Agent is designed to be a *starting point*. It provides a basic set of states and tools, demonstrating the core capabilities of the PSE.  You can extend this base agent by:

*   **Adding Custom Tools:** Integrate new tools to handle specific tasks relevant to your application.
*   **Creating Custom States:** Define new states to model more complex behaviors and workflows.
*   **Modifying Existing Logic:** Adjust the transitions and actions within existing states to fine-tune the agent's behavior.
*   **Adding Custom Logic:** Add custom logic to the base agent to handle specific tasks or workflows.
*   **Use Reinforcement Learning:** Use reinforcement learning to improve the agent's performance over time.
*   **Expirement with different language models:** Try out different language models to see which ones work best for your use case.
