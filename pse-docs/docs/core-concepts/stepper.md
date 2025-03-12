# The Stepper System

The Stepper system is a core component of PSE's architecture, responsible for tracking positions within state machines and managing traversal through the grammar.

## What is a Stepper?

A Stepper represents a position within a state machine and maintains information about:

- The current state
- Traversal history
- Accumulated values
- Sub-steppers for hierarchical traversal

Steppers follow an immutable pattern where operations produce new Stepper instances rather than modifying existing ones. This enables concurrent exploration of multiple possible paths through the state machine.

## Key Components

### Stepper

The primary Stepper class tracks:

- **Current State**: The current position within the state machine
- **History**: A record of previously visited states
- **Raw Value**: Accumulated text or data during traversal
- **Remaining Input**: Any input that hasn't been consumed yet
- **Sub-Stepper**: Optional sub-stepper for hierarchical navigation

### StepperDelta

When a Stepper consumes a token, it creates a StepperDelta which represents the result of a state transition. A StepperDelta tracks:

- The resulting Stepper after transition
- The token that was consumed
- Whether token healing was applied
- Score/probability of the transition

## Core Operations

### Cloning

The `clone()` method creates a new Stepper with the same state and history. This is crucial for exploring multiple paths simultaneously:

```python
# Create a branched stepper to explore an alternative path
alternative_stepper = current_stepper.clone()
```

### Consuming Tokens

The `consume()` method processes a token and advances the Stepper through the state machine:

```python
# Consume a token and get possible new steppers
new_steppers = current_stepper.consume("token")
```

### Branching

The `branch()` method creates multiple steppers to explore different paths through the state graph. This branching mechanism is central to PSE's non-deterministic approach:

```python
# Create multiple steppers for different potential paths
branched_steppers = current_stepper.branch()
```

Branching occurs when:
1. Multiple outgoing edges exist from the current state
2. A sub-stepper needs to branch (hierarchical branching)
3. An optional component can be either included or skipped

The branching algorithm recursively explores all possible paths, creating a separate stepper instance for each viable path. This concurrent exploration is what allows PSE to evaluate multiple interpretations simultaneously without the need for backtracking.

### State Queries

Steppers provide several methods to query their current state:

```python
# Check if the stepper has reached an accepting state
if stepper.has_reached_accept_state():
    # Handle completion

# Get valid continuations from the current state
valid_tokens = stepper.get_valid_continuations()

# Check if the stepper can accept more input
can_continue = stepper.can_accept_more_input()
```

## Non-Deterministic Exploration and State Graph Traversal

Steppers form the building blocks for the state graph traversal algorithm, providing critical decision mechanisms that determine how paths are explored:

### Key Path Decisions

The state graph traversal relies on three key decision points:

1. **Token Validation** - Determines if a token is valid for the current grammar position:
   - Checks if the token matches expected patterns
   - When invalid, the current path is abandoned
   - Specialized state machines have custom validation logic

2. **Completion Detection** - Determines when a grammar component is complete:
   - Recognizes when a sub-grammar has reached its accept state
   - Handles optional grammar components appropriately
   - Triggers transitions to the next state in the parent grammar

3. **Path Branching** - Determines when multiple paths should be explored:
   - Identifies multiple valid continuations from the current state
   - Manages optional paths that can be explored in parallel
   - Creates the foundation for non-deterministic exploration

These decision points drive the traversal algorithm, which explores all possible valid paths by:

1. Starting with an initial position and token
2. Creating a queue of all potential paths to process
3. For each path in the queue:
   - Validating the token against grammar expectations
   - Processing the token through appropriate sub-grammars
   - Checking if grammar components have completed
   - Adding new valid paths to the result or queue for further processing

This approach enables PSE to:

- Explore multiple interpretations simultaneously
- Handle ambiguous grammars without backtracking
- Recover gracefully from token mismatches
- Find the most probable valid parsing path

The Stepper system provides the foundation for PSE's advanced [state graph traversal algorithm](state-graph-traversal.md), which efficiently explores multiple paths through complex grammar structures while maintaining linear time complexity in most cases.

## Hierarchical Traversal

The state graph traversal relies heavily on hierarchical composition:

1. **Delegation**:
   - A parent grammar delegates to a sub-grammar for processing a specific component
   - The parent keeps track of where to transition after the sub-grammar completes
   - The immutable design ensures clean separation between different parsing paths

2. **Nested Processing**:
   - Tokens are processed by the appropriate sub-grammar components
   - Each sub-grammar handles its section independently
   - Processing continues hierarchically through nested grammar structures

3. **Completion and Transitions**:
   - When a sub-grammar reaches its accept state, it signals completion
   - The parent grammar transitions to its next state
   - The completed sub-grammar's results are captured in the parsing history
   - Multiple valid paths may branch from this point

This hierarchical composition is central to how PSE handles nested grammars and creates a powerful mechanism for:

- Building complex grammars from simpler components
- Processing nested structures like objects and arrays
- Maintaining context across multiple levels of nesting
- Tracking and extracting structured values

```python
# Example of hierarchical processing
parent_grammar = StateMachine({
    0: [(StringStateMachine(), 1)],  # First expect a string
    1: [(NumberStateMachine(), "$")] # Then expect a number to complete
})

# Process a token through this hierarchical grammar
result = parent_grammar.process_token("hello")  # Handled by StringStateMachine
result = parent_grammar.process_token("42")     # Handled by NumberStateMachine
                                               # Now in accept state
```

This hierarchical processing is orchestrated through a breadth-first exploration approach, ensuring all possible paths are explored efficiently while maintaining context across different grammar levels.

## Stepper in the PSE Workflow

During the PSE generation process:

1. The Engine creates initial Steppers from the state machine
2. As tokens are generated, Steppers advance through the grammar
3. Multiple Steppers may explore different paths simultaneously
4. The best paths are selected based on multiple criteria
5. Invalid tokens are masked in the logit distribution
6. The process continues until an accepting state is reached

This dynamic traversal system enables PSE to maintain grammatical constraints while preserving the language model's creative capabilities.