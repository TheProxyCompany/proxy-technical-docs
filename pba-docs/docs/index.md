# Proxy Base Agent (Research Preview)

The **Proxy Base Agent (PBA)** is a foundation agent built with the **Proxy Structuring Engine (PSE)**, and is intended to be a starting point for developers and researchers looking to build agents using language models.

The base agent uses our patented **Proxy Structuring Engine** to enable **any language model** to function effectively as an agent, capable of structured interactions, multi-step reasoning, and external tool usage.

The agent is designed with a local-first approach, meaning that the model and all data is stored on the machine running the agent. We do not currently provide a hosted version of the agent, or an off-the-shelf API. However, we support multiple inference frontends via the Huggingface Transformers library; with tested support for MLX, PyTorch, TensorFlow, and Jax.

We invite researchers and developers to experiment with and build upon this foundation.

---
## Installation & Quickstart

Get the Proxy Base Agent running quickly:

```bash
# Install required dependencies
pip install proxy-base-agent

# Launch interactive setup wizard
python -m agent
```

For more detailed guides, see:

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

[View on GitHub](https://github.com/TheProxyCompany/proxy-base-agent){: .md-button .md-button--primary }
[Read the Docs](concepts/overview.md){: .md-button }
