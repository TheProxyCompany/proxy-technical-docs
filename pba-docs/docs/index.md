# Proxy Base Agent (Research Preview)

The **Proxy Base Agent (PBA)** is a foundation agent built with the **Proxy Structuring Engine (PSE)**, and is intended to be a starting point for developers and researchers looking to build agents using language models.

The base agent enables **any language model** to function effectively as an agent, capable of structured interactions, multi-step reasoning, and external tool usage. We invite researchers and developers to experiment with and build upon this foundation.

## What is an Agent?

> An agent is a system that takes actions in an environment.

The Proxy Base Agent, in simple terms, combines state machine logic with language model inference to create a system that can reason and take actions in an environment.

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

## Running the Agent

The agent is designed vertically, meaning that the model and all data is stored on the machine running the agent.

Run the agent with:

```bash
python -m agent
```

which will launch an interactive setup wizard in your terminal.

---

## Language Models

LLMs from your local huggingface cache will be used, or you can download a model from the Huggingface Hub during setup.

Ideally any model that is supported by the Huggingface Transformers library will work with the base agent; with agentic/instruct tuned models performing best.

---

## API Inference

We do not currently provide a hosted version of the base agent, or an off-the-shelf API.

The base agent currently supports multiple inference frontends via the Huggingface Transformers library; with tested support for MLX & PyTorch; with planned support for VLLM, SGLang, TensorFlow, and Jax.

The base agent requires access to a language models tokenizer and sampling logic - this is currently only supported for local models.

---

[View on GitHub](https://github.com/TheProxyCompany/proxy-base-agent){: .md-button .md-button--primary }
