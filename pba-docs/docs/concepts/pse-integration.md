# PSE Integration: The Engine Behind Reliability

The Proxy Base Agent (PBA) achieves its reliability and stateful execution guarantees through its deep integration with the **Proxy State Engine (PSE)**. While PBA defines the high-level agent workflow and states, PSE provides the low-level runtime enforcement mechanism.

## How PBA Uses PSE

PSE operates at two critical levels within PBA:

1.  **Enforcing Agent State Transitions:** The main `AgentStateMachine` (defining the Plan -> Act loop) is configured within PBA's `StructuringEngine` (provided by PSE). During generation, PSE's `process_logits` hook ensures that the LLM can only generate tokens that lead to valid state transitions according to the `AgentStateMachine`'s graph. This prevents the agent from getting stuck or taking unexpected paths.

2.  **Enforcing Structure within States:** Each individual `AgentState` (like `Thinking`, `ToolCallState`, `Python`) defines its *own* nested PSE `StateMachine`. This nested machine dictates the required structure for the content generated *while the agent is in that state*.
    *   For `ToolCallState`, this nested machine enforces that the output must be valid JSON matching the schema of one of the available tools.
    *   For `Python`, it ensures syntactically valid Python code.
    *   For planning states (`Thinking`, etc.), it typically enforces that the content is wrapped in the correct delimiters (e.g., ```thinking ... ```).

## The Guarantee

This dual enforcement means:

*   The agent **must** follow the defined high-level workflow (e.g., Plan before Acting).
*   The output generated *within* each state **must** conform to that state's structural requirements (e.g., valid tool call JSON).

PSE's runtime logit masking and state tracking provide the technical foundation for PBA's guarantees, transforming the LLM from a probabilistic text generator into a more reliable, controllable execution engine within the defined state machine boundaries.

## Further Reading

For a deeper understanding of the underlying mechanisms:

*   Refer to the [Proxy State Engine Documentation](https://docs.theproxycompany.com/pse/) for details on PSE's core concepts (HSM, Steppers, Engine, Token Healing).

This tight integration ensures not only that the agent follows the correct high-level steps but also that each individual step (like a tool call or code generation) is structurally sound, drastically reducing runtime errors and increasing overall system reliability.
