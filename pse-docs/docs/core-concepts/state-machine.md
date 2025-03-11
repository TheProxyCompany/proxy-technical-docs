# State Machine Architecture

The core of PSE is a hierarchical state machine architecture that guides token generation while preserving the LLM's creative capabilities.

## Core Components

PSE's state machine architecture consists of several key components:

### 1. StateMachine Class

The foundation of PSE is the `StateMachine` class, which represents a directed graph of states and transitions. Each state machine:

- Defines a formal model of valid generation paths
- Contains states (nodes) and transitions (edges)
- Manages valid transitions based on token input
- Can be composed hierarchically with other state machines

### 2. Stepper System

The `Stepper` system is responsible for tracking positions within state machines:

- Maintains the current state and traversal history
- Consumes tokens and advances through valid transitions
- Manages sub-steppers for hierarchical state machine traversal
- Uses an immutable pattern where operations produce new Stepper instances

### 3. Token Processing

During generation, PSE processes tokens by:

- Evaluating which transitions (and therefore tokens) are valid next
- Modifying logit distributions to enforce grammatical constraints
- Supporting token healing for partial matches
- Selecting the optimal path based on model probabilities

## How It Works

1. PSE builds a state machine from your schema or grammar
2. The Stepper system tracks the current position in the state machine
3. During generation, PSE manages state transitions based on tokens
4. Invalid tokens are masked, ensuring the output always conforms to your schema
5. The LLM's creativity is preserved within the constraints of the schema

## State Machine Types

PSE includes a variety of state machine types for different parsing needs:

### Base State Machines

Basic building blocks for constructing more complex state machines:

- **AnyStateMachine**: Allows choosing between multiple state machines
- **ChainStateMachine**: Combines state machines in sequence
- **LoopStateMachine**: Repeats a state machine with configurable count limits
- **PhraseStateMachine**: Matches specific text sequences
- **WaitFor**: Accumulates text until a specific pattern is detected

### Data Type State Machines

State machines for handling common data types:

- **StringStateMachine**: Handles string parsing with quotation and escaping
- **NumberStateMachine**: Parses numeric values including integers and floats
- **BooleanStateMachine**: Parses boolean values (true/false)
- **ArrayStateMachine**: Handles array structures with arbitrary elements
- **ObjectStateMachine**: Processes object structures with properties

### Format-Specific State Machines

Specialized state machines for structured formats:

- **JSONStateMachine**: State machines for JSON including objects, arrays, and primitives
- **XMLStateMachine**: Handles XML tag structures and attributes
- **GrammarStateMachine**: Supports parsing according to formal grammars

Each state machine type is designed to handle specific patterns and structures, providing a comprehensive toolkit for constraining LLM generation to any desired format.