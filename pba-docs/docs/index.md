# Proxy Base Agent (Research Preview)

The **Proxy Base Agent (PBA)** is a foundation agent built with the **Proxy Structuring Engine (PSE)**.
It provides a starting point for developers using language models as agents.

By leveraging a customizable **State Graph**—a directed graph composed of states and transitions—the Proxy Base Agent enables **any language model** to function effectively as an agent, capable of structured interactions, multi-step reasoning, and external tool usage.

We invite researchers and developers to experiment with and build upon this foundation.

---

## Usage

```bash
# Start the agent with the interactive setup wizard
python -m agent
```

### API Reference

- [Agent](api/agent.md) - Complete Agent API reference

[View on GitHub](https://github.com/TheProxyCompany/proxy-base-agent){: .md-button .md-button--primary }
[Read the Docs](introduction/overview.md){: .md-button }


---

## Quick Start

To quickly begin experimenting with the Proxy Base Agent, follow these guides:

- [Installation Guide](getting-started/installation.md)
- [Quickstart Tutorial](getting-started/quickstart.md)

---

## Core Concepts

Dive into key ideas behind the Proxy Base Agent to fully harness its capabilities:

- [Overview](concepts/overview.md): High-level introduction to the agent.
- [State Graph](concepts/state-graph.md): Directed graph defining agent states and transitions.
- [State Machine](concepts/state-machine.md): Structured workflow governing agent behavior.
- [States](concepts/states.md): Individual components of agent reasoning and actions.
- [Tools](concepts/tools.md): Extendable external interactions and APIs.

---

## Extending the Agent

Proxy Base Agent is explicitly designed to empower developers to add custom functionality and behaviors:

- [Creating Custom Tools](extending/custom-tools.md): Integrate external APIs or specialized operations.
- [Defining Custom States](extending/custom-states.md): Create new cognitive or action states.
- [Building Custom State Graphs](extending/custom-state-graphs.md): Tailor agent behavior through custom workflows.
- [Model Context Protocol](extending/model-context-protocol.md): The base agent can act as multiple MCP Clients, connecting to multiple MCP Servers.

---

## Architectural Overview

The Proxy Base Agent follows a structured, two-phase workflow:

```
              ┌───────────────────┐
              │                   │
              ▼                   │
  ┌──────────────────────────────────────────────┐
  │                   PLAN                       │ ◀─ loops (configurable)
  │ ┌─────────┐  ┌──────────┐  ┌───────────────┐ │
  │ │THINKING │  │SCRATCHPAD│  │INNER MONOLOGUE│ │
  │ └─────────┘  └──────────┘  └───────────────┘ │
  └────────────────────┬─────────────────────────┘
                       │
                       ▼
      ┌──────────────────────────────┐
      │              ACTION          │
      │ ┌─────────┐      ┌─────────┐ │
      │ │  TOOLS  │      │ PYTHON  │ │
      │ └─────────┘      └─────────┘ │
      └──────────────────────────────┘
                       │
                       ▼
                  ┌────────┐
                  │  DONE  │
                  └────────┘
```

- **Planning Phase**: Iteratively cycles through cognitive states (`Thinking`, `Scratchpad`, `Inner Monologue`) to build reasoning.
- **Action Phase**: Executes tasks via tools or Python code execution, transitioning seamlessly from planning to action.

---

## Installation & Quickstart

Get the Proxy Base Agent running quickly:

```bash
# Install required dependencies
pip install proxy-base-agent

# Launch interactive setup wizard
python -m agent
```

---

[View on GitHub](https://github.com/TheProxyCompany/proxy-base-agent){: .md-button .md-button--primary }
[Read the Docs](introduction/overview.md){: .md-button }
