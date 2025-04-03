# Agent Class

The `agent.agent.Agent` class is the central component of the Proxy Base Agent framework. It orchestrates the interaction between the language model, the defined state machine, tools, memory, and the user interface.

```python
class Agent:
    def __init__(
        self,
        name: str,
        system_prompt_name: str,
        interface: Interface,
        inference: LocalInference,
        seed: int | None = None,
        tools: list[Tool] | list[str] | None = None,
        python_interpreter: bool = False,
        max_planning_loops: int = 3,
        force_planning: bool = True,
        character_max: int | None = None,
        include_pause_button: bool = True,
        **inference_kwargs,
    ):
        # ... implementation ...
```

## Initialization (`__init__`)

The constructor initializes the agent with its core configuration.

**Parameters:**

*   `name` (`str`): A human-readable name for this specific agent instance (e.g., "ResearchAssistant", "CodeHelper").
*   `system_prompt_name` (`str`): The filename (without extension) of the system prompt template located in `agent/llm/prompts/`. This prompt defines the agent's core instructions, personality, and includes placeholders for state machine details and tools.
*   `interface` (`Interface`): An instance of a class implementing the `agent.interface.Interface` abstract base class (e.g., `CLIInterface`). This handles all input/output with the user.
*   `inference` (`LocalInference`): An instance of `agent.llm.local.LocalInference`, which manages the connection to the local LLM backend (via a `Frontend`) and holds the `StructuringEngine`.
*   `seed` (`int | None`, optional): A seed for the random number generator used during LLM sampling, allowing for reproducible outputs. Defaults to a random integer if `None`.
*   `tools` (`list[Tool] | list[str] | None`, optional): Specifies the tools available to the agent. Can be a list of instantiated `Tool` objects, a list of tool filenames (strings) to load from `agent/tools/`, or `None` to load all tools found in that directory. Defaults to `None`.
*   `python_interpreter` (`bool`, optional): If `True`, enables the `Python` action state, allowing the agent to generate and execute Python code snippets. Defaults to `False`.
*   `max_planning_loops` (`int`, optional): The maximum number of times the agent can cycle through its planning states (`Thinking`, `Scratchpad`, `InnerMonologue`) before being forced to transition to the action phase. Defaults to `3`.
*   `force_planning` (`bool`, optional): If `True`, the agent *must* complete at least one planning loop before taking action. If `False`, the agent can potentially skip planning and go directly to an action if the LLM deems it appropriate. Defaults to `True`.
*   `character_max` (`int | None`, optional): An approximate maximum character limit enforced within certain states (like planning states) via the underlying PSE `StateMachine`. Defaults to `None` (often handled by state-specific defaults).
*   `include_pause_button` (`bool`, optional): If `True`, sets up a keyboard listener (using `pynput`) to allow pausing/resuming agent generation by pressing the spacebar. Defaults to `True`.
*   `**inference_kwargs`: Additional keyword arguments passed directly to the `LocalInference` instance and subsequently to the LLM backend during generation (e.g., `temp`, `max_tokens`, `cache_system_prompt`).

## Key Methods

### `async loop()`

Starts the main interactive loop of the agent.

1.  Prompts the user for input via the configured `interface`.
2.  Adds the user's message to the agent's `memory`.
3.  Enters a processing cycle (`while self.can_act:`):
    *   Calls `generate_action()` to get the next structured output from the LLM (guided by PSE and the `AgentStateMachine`).
    *   Calls `take_action()` to interpret the structured output, execute the corresponding logic (log planning state, call tool, run Python), and update memory.
    *   Increments the internal step counter.
4.  Repeats the processing cycle until `self.can_act` becomes `False` (e.g., max steps reached, or an action state signals completion like `send_message` with `wait_for_response=True`).
5.  Recursively calls `loop()` to wait for the next user input.

### `configure(set_system_prompt: bool = False)`

(Re)configures the agent's state machine and PSE engine. This is called initially during `__init__` and also whenever tools are added/removed (e.g., via MCP).

1.  Creates a new `AgentStateMachine` instance based on the current set of `tools`, `python_interpreter` setting, and planning parameters (`max_planning_loops`, `force_planning`).
2.  Configures the underlying `StructuringEngine` (`self.inference.engine`) with this new `AgentStateMachine`.
3.  Optionally updates the system prompt in the agent's `memory` if `set_system_prompt` is `True`.

### `add_tools(new_tools: list[Tool], reset_system_prompt: bool = False)`

Adds new tools to the agent's available toolset.

1.  Updates the internal `self.tools` dictionary.
2.  Calls `configure(reset_system_prompt=reset_system_prompt)` to rebuild the `AgentStateMachine`, reconfigure the PSE engine with the updated tool schemas, and optionally refresh the system prompt in memory to include the new tools.

*(Other methods like `generate_action`, `take_action`, `use_tool` handle the internal processing steps within the loop.)*