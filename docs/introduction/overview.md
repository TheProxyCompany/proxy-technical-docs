# Proxy Structuring Engine Overview

## What is PSE?

The **Proxy Structuring Engine (PSE)** is a specialized system designed to transform large language models (LLMs) from stochastic generators into stateful, controllable engines capable of producing reliable structured outputs. At its core, PSE addresses a fundamental challenge in the AI industry: ensuring that language models can produce outputs that conform to specific structural requirements without sacrificing their creative capabilities.

## The Problem PSE Solves

Large language models are incredibly powerful at generating human-like text, but they suffer from a critical limitation: they cannot reliably produce outputs that conform to specific structures or formats. This limitation manifests in several ways:

1. **Format Inconsistency**: LLMs may deviate from requested formats (JSON, XML, etc.)
2. **Schema Violations**: Generated structures often contain invalid fields or values
3. **Missing Required Elements**: Critical fields may be omitted despite explicit instructions
4. **Hallucinatory Structures**: Creation of nonexistent or irrelevant fields
5. **Syntax Errors**: Small but critical errors like missing commas or brackets

These issues render LLMs unsuitable for many production applications where reliability and structural conformity are non-negotiable requirements.

## Traditional Solutions and Their Limitations

Prior to PSE, developers addressed these limitations through various approaches:

### Prompt Engineering

**Approach**: Providing detailed instructions in the prompt to guide the LLM.  
**Limitations**:
- Consumes valuable context tokens
- Still allows deviation from requested formats
- Vulnerable to prompt injection
- Effectiveness varies across models and prompts

### Post-Processing

**Approach**: Cleaning up or correcting LLM outputs after generation.  
**Limitations**:
- Cannot recover from fundamental structural errors
- Complex parsing logic required for each format
- Often introduces new errors during correction
- Adds latency and complexity

### Fine-Tuning

**Approach**: Retraining models on specific formats and structures.  
**Limitations**:
- Resource-intensive and costly
- Creates special-purpose models with reduced general capabilities
- Still provides no guarantees of structural compliance
- Requires retraining for each new structure or format

## The PSE Approach

PSE solves these problems through a fundamentally different approach, using a hierarchical state machine to guide the LLM's generation process in real-time:

### Core Innovation: State Machine Architecture

1. **Structure Definition**: Users define the required output structure using JSON schema, custom grammar, or built-in type definitions.

2. **State Machine Construction**: PSE constructs a hierarchical state machine representing all valid paths through the generation process.

3. **Token-Level Guidance**: During generation, PSE:
   - Tracks the current state in the state machine
   - Identifies valid next tokens based on the current state
   - Masks invalid token probabilities before the LLM samples
   - Advances the state machine based on the selected token

4. **Parallel Path Exploration**: When the structure is ambiguous (e.g., the beginning of a field name), PSE explores multiple possible interpretations in parallel.

5. **Token Healing**: For minor errors, PSE gives partial credit to valid prefixes, allowing for graceful recovery from minor token-level mistakes.

This approach fundamentally transforms how LLMs generate structured outputs, ensuring structural validity while preserving the model's creativity and capabilities.

## Key Differentiators

PSE stands apart from other solutions through several key differentiators:

### 1. Guarantee of Structural Validity

Unlike prompt engineering or post-processing, PSE mathematically guarantees that outputs will conform to the specified structure. This is not a probabilistic improvement but a deterministic guarantee.

### 2. Preservation of Model Capabilities

Unlike fine-tuning, PSE works with any compatible LLM without modifying the model itself. This preserves the general capabilities of the model while adding structural guarantees.

### 3. Technical Performance

PSE is designed for production environments with stringent performance requirements:
- **Latency**: Adds only ~20ms per token 
- **Memory**: Uses zero-copy tensor operations for minimal overhead
- **Scaling**: Linear complexity with grammar size, not exponential
- **First-Token Latency**: Minimal, requiring no preprocessing or index building

### 4. Framework Compatibility

PSE is designed to be framework-agnostic, with implementations for:
- PyTorch
- MLX
- TensorFlow
- JAX

This makes it usable with virtually any modern LLM that exposes logits for token prediction.

### 5. Composability

PSE supports seamless transitions between natural language and structured output, enabling complex workflows like:
- "Thinking" sections followed by structured results
- Mixed formats within a single generation
- Multi-step reasoning with structured intermediates

## Architecture Overview

The PSE architecture consists of several key components:

### 1. Hierarchical State Machine (HSM)

The state machine represents all valid paths through the generation process, with states for different contexts (inside an object, parsing a string, etc.) and transitions between them.

### 2. Stepper System

The stepper tracks the current position within the state machine, maintains generation history, and evaluates which transitions (and therefore tokens) are valid next.

### 3. Parallel Path Exploration

To handle grammatical ambiguity, PSE maintains multiple "steppers" simultaneously, each exploring a different possible interpretation of the generation.

### 4. Token Healing

For minor generation errors, PSE employs sophisticated healing techniques that give partial credit to valid token prefixes, allowing recovery from small mistakes.

### 5. Framework Adapters

Custom implementations for different ML frameworks ensure efficient integration regardless of the underlying model implementation.

## Use Cases

PSE enables a wide range of applications that were previously challenging or impossible with raw LLMs:

### Intelligent Agents

Build reliable agent systems that can:
- Make API calls with guaranteed valid parameters
- Parse and process API responses
- Follow complex workflows with state dependencies

### Data Extraction and Transformation

Create systems that can:
- Convert unstructured text to structured information
- Extract specific entities from documents
- Transform data between different structured formats

### Interactive Applications

Develop interactive experiences with:
- Consistent, validated user interactions
- Structured game state management
- Dynamic content generation within constraints

### Code Generation

Generate code with:
- Syntax constraints ensuring validity
- Type safety and structure
- Context-aware completion

### Conversational AI

Build conversational systems that:
- Produce consistent, structured responses
- Maintain formatted data across turns
- Integrate seamlessly with backend systems

## Getting Started

PSE is designed to be easy to integrate into existing workflows. Basic implementation requires just a few lines of code:

1. Define your structure (JSON schema, custom grammar, etc.)
2. Create a structuring engine
3. Use it to guide generation from your LLM

See the [Quickstart Guide](../getting-started/quickstart.md) for detailed examples.

## Community and Support

PSE is an open-source project under the Apache 2.0 license. We welcome contributions from the community to help improve and extend this technology.

- [GitHub Repository](https://github.com/TheProxyCompany/proxy-structuring-engine)
- [Issue Tracker](https://github.com/TheProxyCompany/proxy-structuring-engine/issues)
- [Community Discussions](https://github.com/TheProxyCompany/proxy-structuring-engine/discussions)

## Next Steps

- Learn more about [Key Features](key-features.md)
- Explore common [Use Cases](use-cases.md)
- See how PSE [compares to alternatives](comparison.md)
- Follow our [Installation Guide](../getting-started/installation.md) to get started