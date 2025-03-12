# PSE Core Architecture

The Proxy Structuring Engine is built on a high-performance core that implements a sophisticated non-deterministic state machine system for grammar-based constraints. This page provides a detailed look at the internal architecture of PSE's core implementation, which is distributed as a precompiled binary via PyPI.

## Architectural Foundation

PSE's core implements a non-deterministic finite state automaton (NFA) with several key components working together to enforce structured output.

### Key Components

1. **StateMachine**: Defines grammar rules as directed graphs with states and transitions
2. **Stepper**: Tracks position and traverses through state machines
3. **StepperDelta**: Represents the outcome of state transitions
4. **Engine**: Orchestrates token processing and logit modification for language models
5. **TrieMap**: Efficient string-to-value mapping for tokenization

## Component Deep Dive

### StateMachine

The StateMachine represents grammar as a directed graph where:

- Nodes are grammar states
- Edges are transitions with associated validators
- A start state defines where parsing begins
- End states indicate valid completion points

The StateMachine provides several key functionalities:
- Retrieving possible transitions from a given state
- Creating branched paths for exploring alternatives
- Processing tokens and advancing through the grammar
- Supporting parallel processing of multiple paths
- Enabling hierarchical composition through nested state machines

This hierarchical composition is a powerful feature that allows complex nested grammar structures, where transitions can have their own sub-state machines.

### Stepper

Steppers represent positions within state machines, tracking:
- Current state
- Traversal history
- Accumulated values
- Sub-steppers for hierarchical traversal
- Consumed tokens and input information

The immutable design of Steppers is a key architectural choice - operations create new Stepper instances rather than modifying existing ones. This enables concurrent exploration of multiple possible paths through the state machine.

Key functionalities include:
- Processing tokens and advancing through states
- Creating multiple branches to explore different paths
- Determining valid token continuations from the current position
- Checking for acceptance states 
- Supporting hierarchical traversal with sub-steppers

### StepperDelta

StepperDelta encapsulates the result of a state transition after consuming a token. It tracks:
- The resulting stepper after transition
- The token that was consumed
- Whether token healing was applied
- Score/probability of the transition
- Optional token ID reference

### Path Selection Algorithm

The path selection algorithm implements a hierarchical selection approach that chooses the optimal path from multiple candidates. The selection criteria are applied in strict priority order:

1. **Accept state priority**: Paths that reach accept states are always preferred
2. **Token healing status**: Non-healed tokens are preferred over healed ones
3. **Score comparison**: Higher probability paths are preferred
4. **Token length**: Longer tokens are preferred when scores are effectively equal

This sophisticated approach ensures that PSE can make intelligent decisions when multiple valid paths exist.

### Attractive Path Determination

A path is considered "attractive" if it satisfies at least one of these criteria:
- It reaches an accept state (successfully completes a grammar structure)
- It didn't require token healing (perfect match with expected tokens)

This concept of "attractive paths" is crucial for the Engine's resampling logic. When a token leads to an unattractive path, PSE can resample to find a better continuation.

### Engine

The Engine serves as the central coordinator of the PSE system, managing:
- Token vocabulary mappings
- Active steppers and their states
- Language model integration
- Logit masking and enforcement
- Token healing processing
- Multi-token sequence handling
- Token resampling logic

#### Key Functionalities

1. **Logit Masking**

The Engine identifies valid and invalid tokens based on the current position in the grammar, and modifies the logit distribution from the language model to enforce these constraints. This is done by:
- Finding all valid token continuations from current steppers
- Converting these continuations to token IDs
- Setting probabilities for invalid tokens to negative infinity
- Preserving the original distribution for valid tokens

2. **Token Selection**

When selecting the next token, the Engine follows a sophisticated process:
- Sample tokens from the modified distribution
- Validate each token against the grammar
- Check if the token leads to an "attractive" path
- Resample if needed (up to a configurable limit)
- Return the best token sequence based on the path selection algorithm

3. **Token Consumption**

The token consumption process handles:
- Converting token IDs to their string representations
- Processing multi-token sequences when applicable
- Advancing all active steppers with the token
- Handling token healing for partial matches
- Tracking the resulting paths for future selection

#### Multi-Token Processing

The Engine implements sophisticated multi-token handling through its mapping system:
1. During initialization, it analyzes valid token sequences in the grammar
2. It creates mappings from the first token in a sequence to the complete sequence
3. When a token is generated that matches a mapped sequence start, it can process the entire sequence
4. For ambiguous sequences with common prefixes, it handles the overlapping portion correctly

This mapping allows PSE to:
- Recognize when a token is the first in a multi-token sequence
- Automatically handle the full sequence during generation
- Efficiently advance multiple tokens in one step

#### Resampling Logic

The resampling strategy is a key part of PSE's robustness:

1. Sample a token from the model's modified distribution
2. Process the token through all active steppers
3. Check if any resulting path is "attractive" (reaches accept state or didn't require healing)
4. If no attractive path is found, resample up to a configurable number of times
5. If resampling limit is reached, select the best available path based on hierarchical criteria

This resampling approach balances grammar conformance with model preferences, ensuring high-quality output even with complex grammars.

## Core Design Patterns

PSE's architecture employs several sophisticated design patterns:

### Non-deterministic Automaton Pattern

The core architecture implements a non-deterministic finite state automaton (NFA), allowing multiple possible paths to be explored simultaneously. This enables the system to:

- Handle ambiguous grammars elegantly
- Explore alternative tokenizations
- Choose the most probable valid path
- Recover from partial token matches

### Immutable Object Pattern

Operations produce new objects rather than modifying existing ones, enabling concurrent exploration of multiple possible grammar paths. This pattern:

- Ensures thread safety
- Supports parallel processing
- Enables backtracking without state corruption
- Maintains clean separation between paths

### Composite Pattern

Grammar rules can be composed hierarchically with sub-grammars embedded within states. This allows:

- Reuse of common grammar components
- Modular construction of complex grammars
- Clear separation of concerns
- Tractable handling of deeply nested structures

### Strategy Pattern

Used in path selection algorithms to choose optimal continuations. The system can:

- Rank paths by multiple criteria
- Prefer paths that reach accept states
- Consider token probabilities from the LLM
- Balance constraint satisfaction with model preferences

## Advanced Features

### Memory Management

PSE uses efficient reference counting to manage object lifetimes, ensuring proper resource management even with complex cyclical references between state machines and steppers.

### Token Healing

As described in the [Token Healing](token-healing.md) section, PSE handles cases where token boundaries don't align with grammar rules by:

1. Finding the closest valid token prefix/suffix
2. Considering alternative tokenizations
3. Ranking potential healing paths by similarity

### Multi-token Processing

The system handles cases where a single grammar token corresponds to multiple model vocabulary tokens through:

- Mapping between individual tokens and sequences
- Specialized sequence tracking
- Optimized path selection for token sequences

For a detailed explanation, see the [Multi-Token Processing](multi-token-processing.md) section.

### Parallel Path Processing

PSE can process multiple possible paths concurrently, improving performance with large numbers of steppers and complex grammars.

## Data Flow

The core workflow follows this pattern:

1. **Grammar Definition**:
   - Define states and transitions in a StateMachine
   - Set start and end states
   - Configure hierarchical composition

2. **During Generation**:
   - Engine receives logits from a language model
   - Token masking modifies the distribution
   - Valid tokens are sampled according to constraints
   - Steppers advance through the state machine
   - Path selection chooses optimal continuations

3. **During Parsing**:
   - Engine receives tokens to validate
   - Steppers traverse the state machine
   - Token healing repairs mismatches when needed
   - Final state validation determines if input is valid

## Python Integration

PSE's core is exposed to Python through a clean, efficient interface:

- Python classes can subclass core components
- Memory management is handled automatically
- Type conversions happen seamlessly between languages
- Comprehensive docstrings and type hints aid development
- Full support for Python's garbage collection

## Performance Considerations

PSE is designed for optimal performance:

- **Memory Efficiency**: Reference counting minimizes overhead
- **Parallel Processing**: Concurrent path exploration
- **Efficient Data Structures**: Fast token prefix matching
- **Tensor Type Support**: Handling of multiple numeric formats
- **Minimal Copy Operations**: Implemented with minimal copies

This high-performance design enables PSE to constrain LLM outputs with minimal overhead (~20ms per token), making it suitable for production applications.