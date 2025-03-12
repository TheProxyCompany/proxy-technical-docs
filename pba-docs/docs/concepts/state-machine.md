# State Machine

The Proxy Base Agent's core logic is driven by a state machine. This state machine defines the different states the agent can be in and the transitions between those states.

## States

The base agent includes the following pre-defined states:

*   **Thinking:** An initial state where the agent analyzes the input and begins formulating a plan.
*   **Scratchpad:**  A state for storing intermediate thoughts, calculations, and data.
*   **Inner Monologue:** A state where the agent reflects on its progress and refines its plan.
*   **Tool Call:** A state for interacting with external tools. The agent selects a tool and provides input.
*   **Python:** A state for executing Python code. This allows for dynamic computation and manipulation of data.
*   **Done:**  A terminal state indicating the agent has completed its task.

## Transitions

Transitions between states are governed by conditions and events. For example:

*   The agent might transition from `Thinking` to `Scratchpad` after processing the initial input.
*   The agent might transition from `Inner Monologue` to `Tool Call` if it determines that a tool is needed to achieve its goal.
*   The agent might transition from `Tool Call` to `Python` to process the results returned by a tool.
*   The agent might transition to `Done` when it has successfully completed its task or encountered an unrecoverable error.

## State Machine Definition

The state machine is defined using the Proxy Structuring Engine (PSE). The PSE provides a declarative way to specify states, transitions, and actions.  While the specifics of the PSE are covered in the PSE documentation, understanding the basic structure is helpful for extending the agent.

## Extending the State Machine

You can extend the state machine by:

*   **Adding New States:** Define new states to represent additional steps in your agent's workflow.
*   **Modifying Transitions:** Change the conditions that trigger transitions between states.
*   **Adding Actions:** Define actions to be performed when entering or exiting a state.

See [Extending the Agent](../extending/custom-states.md) for more details.
