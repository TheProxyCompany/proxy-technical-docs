# State Machine Architecture

The core of PSE is a hierarchical state machine architecture that guides token generation while preserving the LLM's creative capabilities.

## How It Works

1. PSE builds a state machine from your schema or grammar
2. During generation, PSE manages the state transitions based on tokens
3. Invalid tokens are masked, ensuring the output always conforms to your schema
4. The LLM's creativity is preserved within the constraints of the schema