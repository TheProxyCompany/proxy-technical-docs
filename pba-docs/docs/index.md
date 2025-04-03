# Proxy Base Agent

The **Proxy Base Agent (PBA)** is a foundation agent built with the **Proxy Structuring Engine (PSE)**, which provides the underlying framework for managing the agent's state, controlling the flow of execution, and interacting with the language model.

The base agent is designed to **rapidly prototype and develop LLM-powered agents** with a focus on **local execution, stateful interactions, and extensibility**.

The **PSE** augments **language models** at runtime, allowing them to function effectively as agents - capable of adhering to predefined workflows, multi-step reasoning, and external tool usage.

## What is an Agent?

> An agent is a system that takes actions in an environment.

## Proxy Base Agent

The Proxy Base Agent operates through a structured workflow defined by a **state graph**, transitioning through clearly defined **planning** and **action** phases:

```mermaid
flowchart TD
    Start([Start]) --> Plan
    Start -. force_planning = false .-> Action

    subgraph Plan["Planning Phase"]
        PlanningChoice{"Choose planning type"}
        Thinking["Thinking"]
        Scratchpad["Scratchpad"]
        InnerMonologue["Inner Monologue"]

        PlanningChoice --> Thinking
        PlanningChoice --> Scratchpad
        PlanningChoice --> InnerMonologue
    end

    subgraph Action["Action Phase"]
        ActionChoice{"Choose action type"}
        ToolAction["Tool Call"]
        CodeAction["Python Code"]

        ActionChoice -- "Tool" --> ToolAction
        ActionChoice -- "Code" --> CodeAction
    end

    Plan --> PlanLoop{"More planning needed?"}
    PlanLoop -- "Yes" --> Plan
    PlanLoop -- "No" --> Action

    Action --> Finish([Finish])

    classDef phase fill:#DAD0AF,stroke:#0c5460,border-color:#024645
    classDef decision fill:#024645,stroke:#DAD0AF,color:#DAD0AF,border-color:#DAD0AF,shape:diamond
    classDef state fill:#024645,stroke:#DAD0AF,color:#DAD0AF,border-color:#DAD0AF
    classDef terminal fill:#024645,stroke:#DAD0AF,color:#DAD0AF,border-color:#DAD0AF,shape:stadium

    class Plan,Action phase
    class PlanLoop,ActionChoice,StepCheck decision
    class PlanningChoice,Thinking,Scratchpad,InnerMonologue state
    class ToolAction,CodeAction state
    class Start,Finish terminal

    linkStyle default stroke:#024645
```

### Planning Phase

The agent engages in iterative reasoning through multiple cognitive states:

- **Thinking**: High-level reasoning and goal setting.
- **Scratchpad**: Intermediate notes and working memory.
- **Inner Monologue**: Reflective reasoning and self-assessment.

### Action Phase

After sufficient planning, the agent transitions to executing actions:

- **Tool Calls**: Interaction with external APIs or custom tools.
- **Python Code Execution**: Direct execution of Python scripts for complex tasks.

### State Graph

This state graph describes the base behavior of the agent.
It can be extended and modified to support more complex agentic behaviors.

## Key Capabilities

PBA leverages PSE to deliver capabilities beyond conventional agent frameworks:

*   🧠 **True Stateful Execution:** Define and enforce complex workflows using an explicit HSM (Plan ➔ Act). PSE guarantees state consistency.
*   ✅ **100% Reliable Tool Use:** Eliminate runtime errors from malformed API calls or hallucinated arguments via schema validation *during generation*.
*   ⚡ **Dynamic Runtime Adaptation (MCP):** Integrate new tools on-the-fly via the Model Context Protocol with guaranteed reliability.
*   ⚙️ **Predictable Control Flow:** Explicitly define agent reasoning patterns and action sequences for deterministic behavior.
*   🔌 **Universal LLM Compatibility:** Designed for local models using various backends (MLX, PyTorch supported).
*   🧩 **Modular & Extensible:** Build bespoke agents by adding custom tools, states, or modifying the core HSM architecture.

## Installation & Quickstart

Prerequisites:

- Python 3.10 or higher
- Linux, macOS, or Windows
- Hardware requirements vary depending on the underlying language model you are using.

Get the Proxy Base Agent running quickly:

```bash
# Install required dependencies
pip install proxy-base-agent

# Launch interactive setup wizard
python -m agent
```

# More Information

For more detailed guides, see:

- [Installation Guide](getting-started/installation.md)
- [Quickstart Tutorial](getting-started/quickstart.md)

- [Core Concepts](concepts/index.md)
- [Extending the Agent](extending/index.md)
- [Frontends](frontends/index.md)

---

[View on GitHub](https://github.com/TheProxyCompany/proxy-base-agent){: .md-button .md-button--primary }
