# The Proxy Company Documentation

<div class="hero-content" style="text-align: center; margin: 2em 0;">
  <p style="font-size: 1.5em; max-width: 800px; margin: 0 auto;">
    Making Language Models Reliable for Production
  </p>
</div>

Welcome to the technical documentation portal for The Proxy Company. We develop infrastructure technology that transforms unpredictable language models into reliable systems for critical applications. Browse our comprehensive documentation to learn how our technology can solve your LLM reliability challenges.

For our company website and general information, please visit [theproxycompany.com](https://theproxycompany.com).

## Our Technologies

<div class="grid cards" markdown>

-   :material-engine-outline: __Proxy Structuring Engine (PSE)__

    ---

    Transform stochastic language models into deterministic systems for reliable structured outputs.
    
    __Key features:__
    - State machine architecture
    - Token healing technology
    - Framework agnostic integration
    - JSON schema support
    - ~20ms per token overhead

    [:octicons-book-24: Browse PSE Documentation](/pse/){: .md-button .md-button--primary }

-   :material-robot-outline: __Proxy Base Agent (PBA)__

    ---

    A cognitive architecture for creating reliable, robust AI agents with advanced memory management and tool integration.
    
    __Key features:__
    - Hierarchical memory system
    - Principled tool integration
    - Structured reasoning
    - Reflexive monitoring
    - Safety guarantees

    [:octicons-book-24: Browse PBA Documentation](/pba/){: .md-button .md-button--primary }

</div>

## The Reliability Challenge

Language models have incredible generative capabilities, but their inherent stochastic nature makes them unreliable for production applications that require:

- Consistent output formats
- Guaranteed structural validity
- Reliable behavior across inputs
- Safe tool and API interactions
- Deterministic control flow

Our technologies address these challenges through principled engineering approaches that preserve the creative power of LLMs while providing the reliability guarantees needed for critical applications.

## Technology Stack

### Proxy Structuring Engine

PSE is a state-of-the-art library that guarantees LLMs will generate outputs conforming to specified structures. Using a hierarchical state machine architecture that works with the LLM's token generation process, PSE enforces structural guarantees while preserving the model's creative capabilities.

```python
from proxy_structuring_engine import StructuringEngine, Schema
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "interests": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "interests"]
}

# Create engine
engine = StructuringEngine.from_json_schema(schema)

# Generate
prompt = "Extract information about Sarah, who is 29 and works as a software engineer."
input_ids = tokenizer.encode(prompt, return_tensors="pt")
outputs = engine.generate(model, input_ids, max_new_tokens=200)
result = tokenizer.decode(outputs[0])
print(result)
```

### Proxy Base Agent

PBA is a framework for building reliable AI agents. It provides a cognitive architecture for memory management, reasoning, and tool integration that leads to more predictable and controllable agent behavior.

```python
from pba import Agent, ToolRegistry
from pba.memory import HierarchicalMemory

# Define tools
tools = ToolRegistry()
tools.register("calculator", Calculator())
tools.register("web_search", WebSearch())

# Create agent with hierarchical memory
memory = HierarchicalMemory()
agent = Agent(
    model="meta-llama/Llama-3-8b-instruct",
    tools=tools,
    memory=memory
)

# Run agent on a task
result = agent.run("Research the latest developments in quantum computing and summarize the key findings.")
print(result)
```

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

-   :material-flask-outline: __Research__

    ---

    Technical research and benchmarks.

    [:octicons-arrow-right-24: PSE Research](/research/pse)
    [:octicons-arrow-right-24: PBA Research](/research/pba)

</div>

## Additional Resources

- [Company Website](https://theproxycompany.com)
- [GitHub Organization](https://github.com/TheProxyCompany)
- [Developer Blog](https://blog.theproxycompany.com)
- [Contact Us](https://theproxycompany.com/contact)