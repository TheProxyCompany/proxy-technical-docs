# State Machine Architecture

The hierarchical state machine architecture is the foundation of the Proxy Structuring Engine (PSE). This document explains how PSE uses state machines to guide language model generation, ensuring structural validity while preserving the model's creative capabilities.

## Introduction to State Machines

A state machine is a mathematical model of computation that consists of states, transitions between those states, and rules that govern when transitions occur. PSE uses a specialized form of state machine called a **hierarchical state machine** (HSM) to represent the structure of outputs.

### Key Concepts in PSE's State Machine Implementation

- **States**: Represent different contexts in the generation process (e.g., "parsing a JSON object," "inside a string," "reading an integer")
- **Transitions**: Define the possible moves between states
- **Tokens**: Map to transitions, determining which state changes can occur
- **Hierarchy**: States can contain nested sub-states, creating a hierarchical structure

## How State Machines Drive Generation

During the generation process, PSE's state machine serves as a dynamic guide for the language model:

1. **Current State Tracking**: The system maintains the current state within the machine
2. **Valid Next Token Identification**: Based on the current state, PSE identifies which tokens would represent valid transitions
3. **Probability Masking**: The system modifies the LLM's next-token probabilities, zeroing out invalid tokens
4. **Sampling**: The model samples from the remaining valid tokens based on their relative probabilities
5. **State Update**: After a token is selected, the state machine updates to the new state

This process repeats for each generated token, ensuring that the output always follows the defined structure.

## Hierarchical State Representation

PSE's state machines have a hierarchical structure that mirrors the nested nature of many data formats:

```
JsonObject
├── OpenBrace
├── FieldName
│   ├── Quote
│   ├── NameCharacters
│   └── Quote
├── Colon
├── Value
│   ├── StringValue
│   │   ├── Quote
│   │   ├── StringCharacters
│   │   └── Quote
│   ├── NumberValue
│   │   ├── Digits
│   │   └── OptionalDecimal
│   └── ... (other value types)
├── OptionalComma
└── CloseBrace
```

This hierarchy allows PSE to maintain context at multiple levels simultaneously, tracking both the immediate token context and the broader structural position.

## State Machine Construction

### From JSON Schema

When you create a structuring engine from a JSON schema, PSE:

1. Parses the schema definition
2. Converts type definitions into state machine components
3. Links components based on the schema structure
4. Builds a complete state machine representing all valid paths

Example:

```python
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "required": ["name"]
}

engine = StructuringEngine.from_json_schema(schema)
```

The resulting state machine would represent:
- A JSON object with opening and closing braces
- Field name "name" (required) with a string value
- Optional field name "age" with an integer value
- Appropriate commas, colons, and formatting

### From Custom Grammars

For custom grammars, PSE:

1. Processes the grammar definition
2. Creates state transitions for grammar rules
3. Builds a state machine that represents the complete grammar

Example:

```python
from pse import Grammar, OneOf, Sequence, ZeroOrMore

command_grammar = Grammar(
    "command", 
    Sequence(
        OneOf(["GET", "POST", "PUT", "DELETE"]),
        "/",
        ZeroOrMore(
            Sequence(
                Grammar("resource", r"[a-zA-Z0-9]+"),
                Optional("/", Grammar("id", r"[a-zA-Z0-9]+"))
            )
        )
    )
)

engine = StructuringEngine.from_grammar(command_grammar)
```

## The Stepper System

The "Stepper" is PSE's mechanism for traversing the state machine during generation:

### Single Stepper Operation

1. **Initialization**: The stepper starts at the root state
2. **Token Processing**: For each token:
   - The stepper identifies valid transitions from the current state
   - It moves to the new state based on the selected token
   - It records the token and state history
3. **State Management**: The stepper maintains all necessary state context

### Key Components of the Stepper

- **Current State**: The present location in the state machine
- **Transition History**: Record of how the stepper arrived at the current state
- **Valid Transitions**: Set of allowed next moves from the current state
- **Lookahead Information**: Context for potential future states

## Multiple Path Exploration

One of PSE's most powerful features is its ability to explore multiple possible paths through the state machine simultaneously:

### Why Multiple Paths?

Ambiguity is common in generation, especially at decision points like:
- The start of a field name (which field comes next?)
- The type of a value (string, number, object, etc.)
- Optional elements (should they be included?)

### Parallel Stepper Management

PSE handles ambiguity through parallel exploration:

1. **Stepper Replication**: At ambiguous points, PSE creates multiple steppers exploring different paths
2. **Probability Management**: Each path is assigned a probability based on the LLM's token preferences
3. **Path Pruning**: Less likely paths are pruned to maintain efficiency
4. **Best Path Selection**: The most probable valid path is ultimately chosen

This approach allows PSE to handle complex, ambiguous structures without requiring deterministic parsing.

## C++ Implementation Details

PSE's state machine is implemented in C++ for maximum performance:

### Core Classes

- **StateMachine**: Represents the overall state machine structure
- **State**: Represents individual states with their transitions
- **Transition**: Represents moves between states with token constraints
- **Stepper**: Manages traversal of the state machine
- **StepperDelta**: Represents incremental updates to steppers

### Performance Optimizations

- **Memory Pooling**: Reuse of memory allocations for steppers
- **Compact State Representation**: Efficient encoding of states and transitions
- **Fast Token Matching**: Optimized algorithms for token validation
- **Parallel Processing**: Efficient management of multiple paths

## Integration with Token Processing

The state machine is tightly integrated with PSE's token processing system:

1. **Token Validation**: The state machine determines which tokens are valid next
2. **Logit Masking**: These validations create masks applied to the LLM's logits
3. **Sampling Control**: The masked logits guide the model's token selection
4. **Token Healing**: When exact matches fail, partial matching helps recover

## Examples in Action

Let's look at a concrete example of the state machine during JSON generation:

### Example: Generating a JSON Object

Starting with the schema:

```python
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "required": ["name"]
}
```

The generation process might proceed as follows:

1. **Initial State**: JsonObject > OpenBrace
   - Valid tokens: `{`
   - LLM generates: `{`
   - New state: JsonObject > AfterOpenBrace

2. **Field Name Start**:
   - Valid tokens: `"` (quote for field name)
   - LLM generates: `"`
   - New state: JsonObject > FieldName > OpenQuote

3. **Field Name Content**:
   - Valid tokens: any character valid in field names
   - Multiple paths are explored:
     - Path 1: Toward "name" field
     - Path 2: Toward "age" field
   - Based on probabilities, LLM chooses: `n`
   - Path 1 becomes more likely
   - New state: JsonObject > FieldName > Characters

4. **Completing Field Name**:
   - LLM generates: `ame"`
   - New state: JsonObject > AfterFieldName

5. **After Field Name**:
   - Valid tokens: `:`
   - LLM generates: `:`
   - New state: JsonObject > AfterColon

6. **Value Start**:
   - Valid tokens: depends on the field ("name" requires string start)
   - LLM generates: `"`
   - New state: JsonObject > StringValue > OpenQuote

The process continues until a complete, valid JSON object is generated.

## Advanced State Machine Features

### State Machine Composition

PSE supports composition of state machines, allowing complex structures to be built from simpler components:

```python
# Create composite engine with thinking and structured output
composite_engine = StructuringEngine.create_composite_engine(
    {
        "thinking": NaturalLanguageEngine(),
        "output": StructuringEngine.from_json_schema(schema)
    },
    delimiter_tokens={
        "thinking_to_output": ["\nJSON Output:\n"]
    }
)
```

This creates a state machine with two major branches, connected by delimiter tokens.

### Conditional Transitions

State machines can include conditional transitions that depend on context:

- **Context-Sensitive Rules**: Transitions that depend on previously generated content
- **Forward References**: References to structures that will be defined later
- **Dependent Types**: Types whose validation depends on other field values

### Non-Deterministic Handling

PSE's state machine handles non-deterministic scenarios through:

- **Parallel Path Exploration**: Maintaining multiple possible interpretations
- **Probabilistic Ranking**: Using model probabilities to rank paths
- **Beam Search**: Keeping top-N most likely paths
- **Backtracking**: Ability to revert to previous states when needed

## Debugging State Machines

PSE provides tools for visualizing and debugging state machines:

### Visualization

```python
# Visualize a state machine
from pse.debug import visualize_state_machine

engine = StructuringEngine.from_json_schema(schema)
visualize_state_machine(engine.state_machine)
```

### State Inspection

```python
# Debug state transitions during generation
from pse.debug import trace_generation

engine = StructuringEngine.from_json_schema(schema)
trace_results = trace_generation(engine, model, input_ids)
```

## Performance Considerations

The state machine architecture is designed for efficiency:

- **Incremental Updates**: Only state changes are computed, not the entire state
- **Lazy Evaluation**: Transitions are evaluated only when needed
- **Memory Efficiency**: Compact representation of states and transitions
- **Linear Scaling**: Performance scales linearly with grammar complexity, not exponentially

Typical overhead is around 20ms per token, making it suitable for real-time applications.

## Best Practices

### State Machine Design

- **Start Simple**: Begin with minimal schemas and expand
- **Test Incrementally**: Verify each component separately
- **Limit Ambiguity**: Reduce parallel paths where possible
- **Consider Tokenization**: Design with the model's tokenization in mind

### Performance Optimization

- **Limit Parallel Paths**: Reduce max_parallel_paths for simple structures
- **Optimize Grammars**: Simplify complex grammars where possible
- **Batch Processing**: Process tokens in batches when appropriate
- **Monitor Path Exploration**: Log and analyze parallel path usage

## Conclusion

The hierarchical state machine architecture is the core innovation that enables PSE to guarantee structural validity while preserving the language model's creative capabilities. By guiding the generation process token by token, PSE transforms probabilistic language models into reliable tools for structured output generation.

## Next Steps

- Understand how [Token Healing](token-healing.md) recovers from errors
- Explore the [JSON Schema Guide](../guides/json-schema.md) for practical applications
- Review the [Structuring Engine API](../api/structuring-engine.md) documentation