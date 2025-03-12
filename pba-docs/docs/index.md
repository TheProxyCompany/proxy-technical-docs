# Proxy Base Agent

<div class="hero-content" style="text-align: center; margin: 2em 0;">
  <p style="font-size: 1.5em; max-width: 800px; margin: 0 auto;">
    A stateful, tool-enabled agent with structured state transitions
  </p>
</div>

The **Proxy Base Agent (PBA)** is a stateful, tool-enabled agent built with the Proxy Structuring Engine. It implements a state machine architecture that guides language models through planning and action phases, creating reliable, structured agent behavior through principled state transitions.

## Architecture

PBA implements a state machine that guides language models through a structured workflow:

```
                    ┌───────────────────┐
                    │                   │
                    ▼                   │
        ┌──────────────────────────────────────────────┐
        │                   PLAN                       │ ◀─ loops (min=x, max=y)
        │ ┌─────────┐  ┌──────────┐  ┌───────────────┐ │
        │ │THINKING │  │SCRATCHPAD│  │INNER MONOLOGUE│ │
        │ └─────────┘  └──────────┘  └───────────────┘ │
        └────────────────────┬─────────────────────────┘
                             │
                             ▼
            ┌───────────────────────────────┐
            │           TAKE ACTION         │
            │ ┌─────────┐        ┌────────┐ │
            │ │  TOOLS  │        │ PYTHON │ │
            │ └─────────┘        └────────┘ │
            └───────────────────────────────┘
                              │
                              ▼
                        ┌─────────┐
                        │  DONE   │
                        └─────────┘
```

The agent transitions between two main phases:

1. **Planning states** (Thinking, Scratchpad, Inner Monologue)
2. **Action states** (Tool calls, Python code execution)

## Features

The Proxy Base Agent provides:

1. **State Machine Architecture**: Guides language models through structured planning and action phases
2. **Stateful Processing**: Maintains conversation history and agent state through multiple interactions
3. **Tool Integration**: Enables safe and controlled use of external tools with schema validation
4. **Python Execution**: Optional ability to execute Python code for complex operations
5. **Pause/Resume**: Ability to pause and resume agent execution for better control

This implementation makes it easy to create reliable, predictable agents capable of handling complex tasks through structured state transitions.

## Installation

```bash
# Clone the repository
git clone https://github.com/TheProxyCompany/agent.git
cd agent

# Install using uv
uv pip install -e .
```

## Usage

```bash
# Start the agent with the interactive setup wizard
python -m agent
```

## Use Cases

- **Research Assistants**: Agents that can reliably perform complex research tasks
- **Data Analysis**: Systems that explore, analyze, and derive insights from datasets
- **Creative Collaboration**: Agents that collaborate effectively with humans on creative tasks
- **Process Automation**: Reliable automation of complex workflows with multiple decision points
- **Knowledge Management**: Systems that organize and synthesize knowledge across domains

## Documentation

Our comprehensive documentation covers everything you need to understand PBA's architecture and implementation:

### Introduction

- [Overview](introduction/overview.md) - A complete introduction to PBA and its approach
- [Key Features](introduction/key-features.md) - Detailed exploration of PBA's capabilities
- [Use Cases](introduction/use-cases.md) - Real-world applications and examples

### Getting Started

- [Installation](getting-started/installation.md) - Setting up PBA in your environment
- [Quickstart](getting-started/quickstart.md) - Your first PBA implementation

### Core Concepts

### API Reference

- [Agent](api/agent.md) - Complete Agent API reference

## Open-Source

PBA is available under the Apache 2.0 license. We welcome contributions from the community to help improve and extend this research.

[View on GitHub](https://github.com/TheProxyCompany/proxy-base-agent){: .md-button .md-button--primary }
[Read the Docs](introduction/overview.md){: .md-button }