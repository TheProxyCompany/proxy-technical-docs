# State Machine

The Proxy Base Agent's (PBA) behavior is governed by an explicit **Hierarchical State Machine (HSM)**. Unlike traditional agents that rely heavily on prompt chaining, PBA uses this state machine, enforced by the underlying Proxy Structuring Engine (PSE), to ensure reliable and predictable execution flow.

## The Core Loop: Plan -> Act

The default PBA state machine defines a fundamental operational cycle:

1.  **Planning Phase:** The agent first evaluates the task. If planning is needed (or forced), it enters a planning loop. Within each loop iteration, it chooses one of the available planning states (`Thinking`, `Scratchpad`, `InnerMonologue`) to analyze the task, break down problems, or formulate strategy. The agent can cycle through this planning loop multiple times (configurable) to refine its approach. PSE ensures the content generated within these states adheres to their defined delimiters (e.g., ```thinking ... ```).

2.  **Action Phase:** Once planning is sufficient, the agent transitions to the action phase. It selects *one* available action state, such as `ToolCallState` (to use an external tool) or `Python` (to execute code). PSE guarantees that the output for the chosen action state conforms to the required structure (e.g., a valid JSON schema for the selected tool call).

3.  **Completion:** After executing the action, the agent typically transitions to a final state, often awaiting further user input or concluding the task.

```mermaid
flowchart TD
    Start([Start]) --> PlanLoopCheck{Evaluate Task}
    PlanLoopCheck -- Requires Planning --> Plan
    PlanLoopCheck -- Direct Action OK --> Action

    subgraph Plan["Planning Phase (Loop ≤ N times)"]
        direction LR
        PlanningChoice{"Choose planning type"} --> Thinking["Thinking"]
        PlanningChoice --> Scratchpad["Scratchpad"]
        PlanningChoice --> InnerMonologue["Inner Monologue"]
    end

    Plan --> PlanLoopDecision{"More planning needed?"}
    PlanLoopDecision -- "Yes" --> Plan
    PlanLoopDecision -- "No" --> Action

    subgraph Action["Action Phase"]
        direction LR
        ActionChoice{"Choose action type"} --> ToolAction["Tool Call"]
        ActionChoice --> CodeAction["Python Code"]
    end

    Action --> Finish([Finish/Await User])

    classDef phase fill:#DAD0AF,stroke:#0c5460,color:#024645
    classDef decision fill:#024645,stroke:#DAD0AF,color:#DAD0AF,shape:diamond
    classDef state fill:#024645,stroke:#DAD0AF,color:#DAD0AF
    classDef terminal fill:#024645,stroke:#DAD0AF,color:#DAD0AF,shape:stadium

    class Plan,Action phase
    class PlanLoopCheck,PlanLoopDecision,ActionChoice decision
    class PlanningChoice,Thinking,Scratchpad,InnerMonologue,ToolAction,CodeAction state
    class Start,Finish terminal
```

## Why an HSM?

Using an explicit HSM enforced by PSE provides key advantages:

*   **Reliability:** Prevents the agent from getting stuck, hallucinating invalid actions, or deviating from the intended workflow.
*   **Control:** Allows developers to precisely define and constrain the agent's behavior.
*   **Observability:** Makes the agent's internal state and decision-making process transparent.
*   **Extensibility:** Provides a clear structure for adding new states and capabilities.

This state machine architecture is fundamental to PBA's ability to perform complex tasks reliably. You can learn more about extending this base structure in the [Extending the Agent](../extending/index.md) section.