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

    [:octicons-book-24: Browse PSE Documentation](/pse/){: .md-button .md-button--primary }

-   :material-robot-outline: __Proxy Base Agent (PBA)__

    ---

    A cognitive architecture for creating reliable, robust AI agents with advanced memory management and tool integration.

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

PSE is a state-of-the-art system that guarantees LLMs will generate outputs conforming to specified structures. Using a hierarchical state machine architecture with "Stepper" mechanisms and parallel path exploration, PSE works directly with the LLM's token generation process to enforce structural guarantees while preserving the model's creative capabilities. Its token healing mechanism automatically recovers from tokenization mismatches, ensuring reliability even in edge cases.

### Proxy Base Agent

PBA is a framework for building reliable AI agents. It implements a state machine architecture that structures agent behavior into planning states (thinking, scratchpad, inner monologue) and action states (tool usage, code execution). Its event-based memory system maintains conversation history, while its formalized tool integration protocol ensures safe and controlled interaction with external systems. PBA uses the Model Control Protocol (MCP) for connecting to remote tools and services. This comprehensive architecture leads to more predictable and controllable agent behavior, even for complex tasks.

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

</div>

## Additional Resources

- [Company Website](https://theproxycompany.com)
- [GitHub Organization](https://github.com/TheProxyCompany)
- [Developer Blog](https://blog.theproxycompany.com)
- [Contact Us](https://theproxycompany.com/contact)