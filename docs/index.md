# Technical Documentation

<div class="hero-content" style="text-align: center; margin: 2em 0;">
  <p style="font-size: 1.5em; max-width: 800px; margin: 0 auto;">
    Documentation Portal for The Proxy Company's Technology
  </p>
</div>

Welcome to the technical documentation portal for The Proxy Company. This site provides comprehensive documentation for our open-source technology. For our company website and general information, please visit [theproxycompany.com](https://theproxycompany.com).

## Documentation Index

<div class="grid cards" markdown>

-   :material-engine-outline: __Proxy Structuring Engine (PSE)__

    ---

    Documentation for our technology that transforms stochastic language models into deterministic systems for reliable structured outputs.
    
    __Key topics:__
    - State machine architecture
    - Token processing
    - Parallel path exploration 
    - JSON Schema integration
    - Framework adapters

    [:octicons-book-24: Browse PSE Documentation](/pse/)

-   :material-robot-outline: __Proxy Base Agent (PBA)__

    ---

    Documentation for our agent framework with advanced memory management and tool integration.
    
    __Key topics:__
    - Agent architecture
    - Tool integration
    - Memory & context systems
    - Planning & reasoning
    - Multi-agent orchestration

    [:octicons-book-24: Browse PBA Documentation](/pba/)

</div>

## Technology Overview

The Proxy Company develops infrastructure technology for making large language models reliable for production use. Our solutions address the inherent unpredictability of LLMs through principled engineering approaches.

### Proxy Structuring Engine

PSE is a library that guarantees LLMs will generate outputs conforming to a specified structure. Using a state machine architecture that works with the LLM's token generation process, PSE enforces structural guarantees while preserving the model's creative capabilities.

```python
from proxy_structuring_engine import StructuringEngine, Schema

# Define a schema for the structured output
schema = Schema.from_json_schema({
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "interests": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "interests"]
})

# Create a structuring engine with the schema
engine = StructuringEngine(schema)

# Generate structured output from the LLM
result = engine.generate(model, "Tell me about yourself")
```

[Read the PSE Documentation →](/pse/){: .md-button .md-button--primary }

### Proxy Base Agent

PBA is a framework for building reliable AI agents. It provides a cognitive architecture for memory management, reasoning, and tool integration that leads to more predictable agent behavior.

```python
from proxy_base_agent import Agent, Tool, Memory

# Define a tool the agent can use
class Calculator(Tool):
    def add(self, a: float, b: float) -> float:
        """Add two numbers together"""
        return a + b

# Create an agent with tools and memory
agent = Agent(
    model="gpt-4",
    tools=[Calculator()],
    memory=Memory()
)

# Interact with the agent
response = agent.run("Calculate 125 + 375 and remember the result")
```

[Read the PBA Documentation →](/pba/){: .md-button .md-button--primary }

## Developer Resources

<div class="grid cards" markdown>

-   :fontawesome-brands-github: __GitHub Repositories__

    ---

    Access source code and contribute to development.

    [:octicons-arrow-right-24: PSE Repository](https://github.com/TheProxyCompany/proxy-structuring-engine)
    [:octicons-arrow-right-24: PBA Repository](https://github.com/TheProxyCompany/proxy-base-agent)

-   :material-book-open-variant: __API References__

    ---

    Comprehensive API documentation.

    [:octicons-arrow-right-24: PSE API Reference](/pse/api/structuring-engine)
    [:octicons-arrow-right-24: PBA API Reference](/pba/api/agent)

</div>

## Additional Resources

- [Company Website](https://theproxycompany.com)
- [GitHub Organization](https://github.com/TheProxyCompany)
- [Developer Blog](https://blog.theproxycompany.com)