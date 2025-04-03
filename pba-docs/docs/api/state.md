# AgentState API Reference

The `agent.state.AgentState` class is the abstract base class for defining individual states within the Proxy Base Agent's (PBA) state machine.

## `AgentState` (Abstract Base Class)

All specific states (like `Thinking`, `ToolCallState`, etc.) inherit from this class.

```python
from abc import ABC, abstractmethod
from pse_core.state_machine import StateMachine

class AgentState(ABC):
    def __init__(
        self,
        identifier: str,
        readable_name: str,
        delimiters: tuple[str, str],
        color: str,
        emoji: str,
    ):
        self.identifier = identifier
        self.readable_name = readable_name
        self.delimiters = delimiters
        self.color = color
        self.emoji = emoji

    @property
    @abstractmethod
    def state_machine(self) -> StateMachine:
        # Must return a configured PSE StateMachine
        pass

    @property
    @abstractmethod
    def state_prompt(self) -> str:
        # Must return instructions for the LLM
        pass

    def format(self, string: str) -> str:
        # Helper to wrap content in delimiters
        return f"{self.delimiters[0]}{string}{self.delimiters[1]}"

    def readable_format(self, string: str) -> str:
        # Helper for UI formatting (default: markdown code block)
        return f"```markdown\n{string}\n```"

    def __str__(self) -> str:
        # Used for generating the system prompt section
        return f"{self.readable_name.title()}: {self.state_prompt}"

```

**Key Attributes:**

*   `identifier` (`str`): Unique machine-readable name (e.g., `"thinking"`). Used as keys in the main `AgentStateMachine` graph and for identifying output segments.
*   `readable_name` (`str`): Human-friendly name for UI display (e.g., `"Thinking"`).
*   `delimiters` (`tuple[str, str]`): Start and end strings the LLM uses to enclose content generated for this state. PSE uses these within the nested `state_machine`.
*   `color` (`str`): [Rich](https://rich.readthedocs.io/en/latest/style.html#color) color name for styling in the CLI.
*   `emoji` (`str`): Emoji character for styling in the CLI.

**Abstract Properties (Must be Implemented by Subclasses):**

*   `state_machine` (`property -> StateMachine`): Must return a configured instance of a `pse_core.StateMachine` (or a subclass like `FencedFreeformStateMachine`, `JsonStateMachine`, etc.). This machine defines and enforces the structure of the content *within* this state. It's crucial to set `sm.identifier = self.identifier` on the returned state machine instance so PBA can correctly associate generated output segments.
*   `state_prompt` (`property -> str`): Must return a string containing instructions for the LLM. This text is incorporated into the main system prompt and should explain the purpose of this state, how to use its delimiters, and the expected content/structure.

## Default PBA States

PBA provides the following built-in states inheriting from `AgentState`:

**Planning States:**

*   `agent.state.planning.thinking.Thinking`: For deliberate reasoning. Uses `FencedFreeformStateMachine`.
*   `agent.state.planning.scratchpad.Scratchpad`: For temporary notes. Uses `FencedFreeformStateMachine`.
*   `agent.state.planning.inner_monologue.InnerMonologue`: For detailed internal narrative. Uses `FencedFreeformStateMachine`.

**Action States:**

*   `agent.state.action.tool_call.ToolCallState`: For invoking tools. Dynamically builds a `JsonStateMachine` based on available tool schemas.
*   `agent.state.action.python.Python`: For executing Python code. Uses an `EncapsulatedStateMachine` wrapping a `PythonStateMachine` (from PSE grammar types).

Refer to the source code of these classes for examples of how to implement the `state_machine` and `state_prompt` properties.