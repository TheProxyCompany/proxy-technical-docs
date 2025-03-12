# Proxy Structuring Engine

The **Proxy Structuring Engine (PSE)** is a foundational research project focused on transforming stochastic language models into reliable, deterministic systems for generating structured outputs.

## Research Challenge

Large language models (LLMs) excel at generating creative, fluent text but struggle with reliability when producing outputs that must conform to specific structures like JSON, XML, or custom grammars. This fundamental limitation has been a critical barrier to deploying LLMs in production environments where reliability is non-negotiable.

Our research addresses this challenge by developing a novel approach that:

1. Maintains the creative capabilities of LLMs
2. Enforces structural guarantees on outputs
3. Minimizes computational overhead
4. Works with any LLM architecture

## Our Approach

PSE introduces a hierarchical state machine architecture that guides token generation while preserving the LLM's creative capabilities:

1. **StateMachine**: We construct a directed graph of states and transitions from the target grammar, creating a formal model that represents all valid generation paths
2. **Stepper Mechanism**: Our Stepper component tracks position within the state machine, consuming tokens and advancing through valid transitions
3. **Logit Modification**: Rather than post-processing, we intervene directly in the token sampling process by modifying logit distributions to enforce grammatical constraints
4. **Token Healing**: Our approach automatically recovers from tokenization mismatches by identifying partially matched tokens and finding valid prefixes

<figure markdown>
  ![PSE Architecture Diagram](/assets/pse-architecture.png)
  <figcaption>PSE's hierarchical state machine architecture for guiding token generation</figcaption>
</figure>

## Research Findings

Our research has demonstrated several key findings:

- **Reliability-Creativity Balance**: We've proven it's possible to maintain LLM creativity while enforcing structural guarantees
- **Grammar Complexity**: We can handle complex, nested grammars with recursive elements
- **Computational Efficiency**: Our approach adds minimal overhead (~20ms per token)
- **Framework Agnosticism**: The approach works across all major ML frameworks (PyTorch, MLX, TensorFlow, JAX)

## Applications

While our research is fundamental in nature, it has immediate applications in several domains:

- **Scientific Computing**: Structure-constrained generation for scientific notation
- **Software Engineering**: Grammar-conforming code generation
- **Data Processing**: Reliable extraction of structured information from unstructured sources
- **Human-AI Interfaces**: Creating reliable AI systems with predictable output formats

## Technical Implementation

The technical implementation of our research is available as an open-source library, documented in detail in our [PSE documentation portal](/pse/).

## Research Publications

Our research findings are being documented in several forthcoming publications:

1. "State Machine Approaches to Reliable Structured Generation in Large Language Models" (in preparation)
2. "Parallel Path Exploration for Handling Ambiguity in Token Generation" (in preparation)

## Future Research Directions

We're actively exploring several promising directions for future research:

- **Multi-modal structuring**: Extending our approach to handle multi-modal inputs and outputs
- **Compositional grammars**: Creating systems that can flexibly combine different grammar components
- **Self-verifying systems**: Exploring approaches where the system can verify its own outputs
- **Formal guarantees**: Developing mathematical proofs about the properties of structure-guided generation

## Collaborate With Us

We welcome collaboration from researchers, engineers, and organizations interested in advancing this work. Please [contact us](/contact) to discuss potential collaborations.