# Proxy Structuring Engine

The **Proxy Structuring Engine** ensures that language models produce outputs that conform to specific structures while preserving their creative capabilities.

It can be used for common uses cases including tool use, synthetic data generation, API integration, structured output, and more.

## Key Features

- **State Machine Architecture**: Uses a hierarchical state machine to guide generation according to your schema
- **Token Healing**: Automatically recovers from minor errors to maintain structural validity
- **Multi-Token Processing**: Efficiently handles token sequences for optimal generation
- **Framework Agnostic**: Works seamlessly with PyTorch, MLX, TensorFlow, and JAX
- **Minimal Overhead**: Designed for production use with ~20ms per token overhead
- **Schema Flexibility**: Supports JSON Schema, Pydantic models, and custom grammar definitions

## How It Works

PSE uses a novel approach to constrain LLM generation:

1. **Schema Definition**: You define the structure you need using JSON Schema or other formats
2. **State Machine Creation**: PSE converts this schema into a hierarchical state machine with states and transitions
3. **Stepper System**: During generation, the Stepper tracks the current position in the state machine and validates transitions
4. **Token Processing**: PSE directly modifies logit distributions to enforce grammatical constraints
5. **Token Healing**: When tokenization mismatches occur, PSE can recover by finding valid token prefixes
6. **Multi-Token Handling**: PSE efficiently processes token sequences for better performance
7. **Path Selection**: Sophisticated algorithms choose the optimal continuation when multiple paths are valid
8. **Valid Output**: The result is a properly structured output that follows your schema while preserving creativity

This approach gives you the best of both worlds: the creative power of LLMs with the reliability of structured systems.

## Open-Source

PSE is available under the Apache 2.0 license. We welcome contributions from the community to help improve this library.

[View on GitHub](https://github.com/TheProxyCompany/proxy-structuring-engine){: .md-button .md-button--primary }
