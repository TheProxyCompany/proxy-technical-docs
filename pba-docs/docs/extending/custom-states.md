# Custom States

While PBA provides default states for Planning (`Thinking`, `Scratchpad`, `InnerMonologue`) and Action (`ToolCallState`, `Python`), you can create entirely new states to model unique phases or capabilities in your agent's workflow.

## Defining a Custom State

Creating a custom state involves subclassing the `agent.state.AgentState` abstract base class.

**Steps:**

1.  **Create a Python File:** Typically within the `agent/state/` directory or a custom subdirectory (e.g., `agent/state/custom/my_state.py`).
2.  **Subclass `AgentState`:** Define a new class inheriting from `AgentState`.
3.  **Implement `__init__`:**
    *   Call `super().__init__(...)` providing:
        *   `identifier`: A unique, lowercase string for the state (e.g., `"summarize"`).
        *   `readable_name`: A human-friendly name (e.g., `"Summarization"`).
        *   `delimiters`: A tuple of start and end strings (e.g., `("```summary\n", "\n```")`).
        *   `color`: A Rich color name for UI styling (e.g., `"blue"`).
        *   `emoji`: An emoji character for UI styling (e.g., `"scroll"`).
    *   Store any state-specific configuration.
4.  **Implement `state_machine` Property:**
    *   This property must return a configured PSE `StateMachine` instance. This machine defines and enforces the structure of the content generated *within* this custom state. You can use any PSE `StateMachine` type (e.g., `FencedFreeformStateMachine`, `JsonStateMachine`, `PythonStateMachine`, or a custom composition).
5.  **Implement `state_prompt` Property:**
    *   This property must return a string containing instructions for the LLM on *how* and *when* to use this state, including how to use the delimiters and expected content structure.

## Example: A Simple "Summarization" State

Let's create a state where the agent generates a concise summary.

```python
# agent/state/custom/summarization.py
from pse.types.misc.fenced_freeform import FencedFreeformStateMachine
from pse_core.state_machine import StateMachine
from agent.state import AgentState

class SummarizationState(AgentState):
    def __init__(self, delimiters: tuple[str, str] | None = None, character_max: int = 500):
        super().__init__(
            identifier="summarize",
            readable_name="Summarization",
            delimiters=delimiters or ("```summary\n", "\n```"),
            color="green",
            emoji="scroll",
        )
        self.character_max = character_max

    @property
    def state_machine(self) -> StateMachine:
        # Use FencedFreeform to allow text within delimiters, enforcing length
        sm = FencedFreeformStateMachine(
            identifier=self.identifier,
            delimiters=self.delimiters,
            char_min=10, # Require at least a short summary
            char_max=self.character_max,
        )
        # Important: Assign the identifier for PBA to recognize it
        sm.identifier = self.identifier
        return sm

    @property
    def state_prompt(self) -> str:
        return f"""
    The Summarization state is used to generate a concise summary of previous interactions or information.
    Keep the summary brief and to the point, adhering to the character limit ({self.character_max}).

    Always encapsulate the summary within {self.delimiters[0]!r} and {self.delimiters[1]!r} tags.
    This state's output might be shown to the user.
        """
```

## Integrating Custom States

To make the agent use your custom state, you need to modify the main `AgentStateMachine` definition in `agent/state_machine.py`:

1.  **Import:** Import your custom state class.
2.  **Instantiate:** Create an instance of your custom state.
3.  **Add to `self.states`:** Add the instance to the `self.states` dictionary in `AgentStateMachine.__init__` so the agent recognizes its identifier.
4.  **Modify State Graph:** Update the `state_graph` dictionary to include transitions *to* and *from* your new state. For example, you might add it as an option in the Planning phase or as a distinct step after the Action phase.

See [Custom State Graphs](./custom-state-graphs.md) for more details on modifying the agent's core workflow.
