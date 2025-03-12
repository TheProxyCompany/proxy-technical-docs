# State Machine Architecture

The heart of PSE is a sophisticated non-deterministic finite state automaton (NFA) that guides token generation while preserving the LLM's creative capabilities.

## The Non-Deterministic Approach

PSE takes a fundamentally different approach to structured generation compared to traditional constraint systems:

**Deterministic approaches** follow a single path through a grammar, which can easily lead to dead ends when a token sequence doesn't match expectations exactly. These approaches often require backtracking, which is inefficient and can lead to exponential time complexity.

**PSE's non-deterministic approach** explores multiple possible paths simultaneously, considering all valid continuations at each step. This allows PSE to:

- Handle ambiguity gracefully without backtracking
- Tolerate tokenization mismatches through token healing
- Select the most probable valid path based on model preferences
- Maintain linear time complexity in most cases
- Scale efficiently to complex grammars
- Recover gracefully from partial matches

## Core Components

PSE's state machine architecture consists of several key components that work together:

### 1. StateMachine

At the foundation is the StateMachine, which represents a directed graph of states and transitions:

- **States**: Points in the grammar (like "inside an object" or "expecting a property name")
- **Transitions**: Valid moves between states (like consuming a "{" token)
- **Start State**: The beginning point for parsing
- **End States**: Valid completion points for the grammar

The power of StateMachine comes from its composability - complex grammars can be built by combining simpler state machines hierarchically.

### 2. Stepper System

The Stepper system is responsible for tracking positions within state machines:

- Each Stepper represents a possible interpretation of the input so far
- Multiple Steppers can exist simultaneously, exploring different paths
- Steppers maintain their own state and history independently
- When a token is consumed, it may create multiple new Steppers for ambiguous cases
- Steppers follow an immutable pattern, creating new instances rather than modifying state

This non-deterministic approach is what allows PSE to handle ambiguity so effectively - rather than having to guess which path is correct, it can pursue all promising paths at once. The immutable design ensures thread safety and enables parallel processing of multiple paths.

### 3. Path Selection

When multiple valid paths exist, PSE uses sophisticated selection criteria through the `StepperDelta` component, which tracks the results of state transitions including tokens, healing status, and scores:

1. Paths reaching accept states (successful completion) are prioritized
2. Paths using non-healed tokens are preferred over healed ones
3. Higher probability paths (based on model scores) are favored
4. Longer token matches are preferred when scores are similar
5. When scores are effectively equal, additional factors like history length may be considered

This hierarchical ranking system ensures PSE finds the most natural and accurate path through the grammar without resorting to costly backtracking.

## Design Philosophy

PSE's architecture embodies several key design philosophies:

### 1. Separation of Concerns

The system cleanly separates:
- **Grammar definition** (StateMachine)
- **Position tracking** (Stepper)
- **Path selection** (StepperDelta)
- **Orchestration** (Engine)

This modular design enables specialized implementations for different use cases.

### 2. Fast Core, Extensible Interface

PSE follows a "fast core, extensible interface" philosophy:
- The performance-critical components are implemented in a high-performance core
- Python interfaces allow for customization and extension
- Users can subclass core components to implement specialized behavior
- The Python API exposes the full power of the system without performance penalty

### 3. Immutability for Concurrency

Operations create new objects rather than modifying existing ones:
- Enables safe parallel exploration of multiple paths
- Prevents state corruption during non-deterministic processing
- Simplifies reasoning about complex token handling scenarios
- Allows for efficient implementation of advanced features

## How It Works

1. **Grammar Construction**: PSE converts your schema into a hierarchical state machine
2. **Initialization**: The engine creates initial Steppers at the start state
3. **For each generation step**:
   - PSE identifies valid next tokens from all active Steppers
   - It masks invalid tokens in the LLM's logit distribution
   - The model samples from the modified distribution
   - PSE processes the token through all potential paths using breadth-first exploration
   - Token healing is applied if needed for partial matches
   - Multiple interpretations are ranked using the hierarchical selection criteria
   - The best path(s) are selected and new Steppers are created to represent the next state
   - If no attractive paths are found, the system may resample (request another token)

This process continues until an accept state is reached or generation is complete.

### Token Healing

Token healing is a crucial feature that addresses mismatches between tokenization boundaries and grammar expectations:

1. When a token can't be fully consumed, PSE identifies how much of the token could be matched
2. It uses a vocabulary trie to find the longest valid prefix that matches
3. The matched portion is processed, creating a "healed" path marked for lower priority
4. The remaining portion can be processed in subsequent steps

This allows PSE to gracefully handle cases where token boundaries don't align with grammar boundaries.

## State Machine Types

PSE includes a rich library of state machine components:

### Base State Machines

Fundamental building blocks for constructing more complex machines:

- **AnyStateMachine**: Represents a choice between multiple alternatives (logical OR)
- **ChainStateMachine**: Combines state machines in sequence (logical AND)
- **LoopStateMachine**: Repeats a state machine with configurable count limits (like regex `*` or `+`)
- **PhraseStateMachine**: Matches specific literal text sequences
- **WaitForStateMachine**: Accumulates text until a specific pattern is detected

### Data Type State Machines

Specialized machines for handling common data types:

- **StringStateMachine**: Handles string parsing with quotation and escaping
- **NumberStateMachine**: Parses numeric values including integers and floats
- **BooleanStateMachine**: Parses boolean values (true/false)
- **ArrayStateMachine**: Handles array structures with arbitrary elements
- **ObjectStateMachine**: Processes object structures with properties

### Format-Specific State Machines

Ready-to-use machines for common formats:

- **JSONStateMachine**: Handles JSON objects, arrays, and primitive types
- **XMLStateMachine**: Processes XML elements, attributes, and nested structures
- **GrammarStateMachine**: Supports parsing according to formal grammar specifications

Each state machine type is designed to integrate seamlessly with the others, allowing you to build complex grammars from simple components.

## The Power of Hierarchical Composition

The true power of PSE's architecture becomes apparent when you combine state machines into hierarchical structures:

```
JSONObjectStateMachine
├── PropertyNameStateMachine
├── PropertyValueStateMachine
│   ├── StringStateMachine
│   ├── NumberStateMachine
│   ├── BooleanStateMachine
│   ├── ArrayStateMachine
│   │   └── (recursive nesting of value types)
│   └── ObjectStateMachine
│       └── (recursive nesting)
```

This hierarchical composition allows PSE to handle arbitrarily complex nested structures while maintaining efficient processing and clean separation of concerns.

## Debugging and Visualization

PSE state machines provide helpful debugging capabilities:

- The `to_readable()` method shows a hierarchical representation of the state machine structure
- State machines include detailed string representations for easier inspection
- Steppers can be inspected to see their current state, history, and accumulated values
- Path selection can be traced to understand why certain paths were chosen over others

### Example: Creating and Debugging a State Machine

```python
# Create a state machine for a simple pattern
sm = StateMachine({
    0: [(PhraseStateMachine("hello"), 1)],
    1: [(WhitespaceStateMachine(), 2)],
    2: [(PhraseStateMachine("world"), "$")],
})

# Print the state machine structure
print(sm.to_readable())

# Create initial steppers
steppers = sm.get_steppers()

# Process tokens and examine paths
for token in ["hello", " ", "world"]:
    print(f"Processing token: {token}")
    steppers = sm.advance_all_basic(steppers, token)
    for stepper in steppers:
        print(f"  - Current state: {stepper.get_current_state()}")
        print(f"  - Value so far: {stepper.get_raw_value()}")
```

For more details on the implementation, see the [Core Architecture](core-architecture.md), [Stepper System](stepper.md), and [State Graph Traversal Algorithm](state-graph-traversal.md) documentation.