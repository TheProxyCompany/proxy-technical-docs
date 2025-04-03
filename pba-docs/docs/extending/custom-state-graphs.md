# Custom State Graphs

Modifying the core **State Graph** of the Proxy Base Agent (PBA) allows for fundamental changes to its operational workflow beyond just adding tools or individual states. This provides advanced control over the agent's execution loop, enabling complex custom behaviors.

## Understanding the State Graph

The main state graph is defined within the `__init__` method of the `agent.state_machine.AgentStateMachine` class. It's a Python dictionary where:

*   **Keys:** Represent the *origin* state's identifier (e.g., `"plan"`, `"take_action"`).
*   **Values:** Are lists of transitions originating from that state. Each transition is a tuple: `(StateMachine, TargetStateId)`.
    *   `StateMachine`: An instance of a PSE `StateMachine` (often an `AgentState`'s `.state_machine` property, or a composer like `LoopStateMachine` or `AnyStateMachine`) that governs the transition *and* the structure of the output generated during that transition.
    *   `TargetStateId`: The identifier of the state the agent will move to *after* successfully completing the transition governed by the `StateMachine`.

**Default Graph Structure (Simplified):**

```python
# Inside AgentStateMachine.__init__

planning_states = [...] # List of StateMachine instances for Thinking, etc.
action_states = [...]   # List of StateMachine instances for ToolCall, Python

state_graph = {
    "plan": [
        (
            LoopStateMachine( # Governs the planning loop
                AnyStateMachine(planning_states), # Allows any planning state
                min_loop_count=int(force_planning),
                max_loop_count=max_planning_loops,
                # ...
            ),
            "take_action", # Target state after planning loop completes
        )
    ],
    "take_action": [
        # Each tuple represents a possible action transition
        (action_state.state_machine, "done") for action_state in action_states
    ],
    # "done" is a terminal state (defined in end_states)
}

super().__init__(
    state_graph=state_graph,
    start_state="plan",
    end_states=["done"],
)
```

## Modifying the Graph

You can customize the agent's flow by directly editing this `state_graph` dictionary within `agent/state_machine.py`.

**Common Modifications:**

1.  **Changing the Planning Loop:**
    *   Adjust `min_loop_count` / `max_loop_count` in the `LoopStateMachine` within the `"plan"` state's transitions.
    *   Change the `AnyStateMachine(planning_states)` to a `ChainStateMachine` to enforce a specific *order* of planning states.
    *   Replace the planning loop entirely with a direct transition or a different structure.

2.  **Adding a New Top-Level State:**
    *   Define your new `CustomState` (see [Custom States](./custom-states.md)).
    *   Add a new key to the `state_graph` for your state's identifier (e.g., `"summarize"`).
    *   Define transitions *from* your new state (e.g., `("summarize", [(SummarizationState().state_machine, "done")])`).
    *   Modify existing transitions to point *to* your new state (e.g., change the target of the `"plan"` state's transition from `"take_action"` to `"summarize"`).
    *   Remember to add your `CustomState` instance to the `self.states` dictionary so the agent recognizes it.

3.  **Creating Conditional Transitions:**
    *   This is more advanced and typically involves creating a custom `StateMachine` subclass **in Python** (by inheriting from `pse_core.StateMachine` or composing base Python types like `ChainStateMachine`, `AnyStateMachine`, etc.) that implements logic to choose the `TargetStateId` based on the content generated or the agent's internal memory/context. The default PBA structure relies on the LLM choosing between parallel paths (like different tools in `take_action`).

4.  **Adding Parallel Action Paths:**
    *   Instead of `AnyStateMachine` for actions (implicitly handled by listing multiple transitions from `take_action`), you could define parallel structures if needed, though the default usually suffices as the LLM selects only one action path.

## Important Considerations

*   **PSE Knowledge:** Modifying the state graph effectively requires understanding how PSE `StateMachine` types (`Chain`, `Loop`, `Any`, etc.) compose and how transitions work. Refer to the [PSE Documentation](https://docs.theproxycompany.com/pse/).
*   **State Recognition:** Ensure any new state identifiers added to the graph keys or as `TargetStateId` values correspond to `AgentState` instances added to the `self.states` dictionary in `AgentStateMachine.__init__`.
*   **Prompting:** Update the system prompt (`agent/llm/prompts/base.txt` or your custom prompt) to accurately reflect the new workflow and instruct the LLM on how to navigate the modified state graph and use any new states.
*   **Complexity:** While powerful, overly complex state graphs can become difficult for the LLM to follow reliably, even with PSE's enforcement. Aim for clarity and logical flow.

Modifying the state graph offers deep control but should be done carefully, considering the impact on the agent's overall behavior and the LLM's ability to navigate the new structure.