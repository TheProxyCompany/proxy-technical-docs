# Token Healing

Token healing is one of the most innovative features of the Proxy Structuring Engine (PSE). This capability allows PSE to recover from minor token-level errors during generation, making the system robust against tokenization inconsistencies while maintaining structural guarantees. This document explains how token healing works and how to optimize it for your use cases.

## The Challenge of Token Misalignment

Large language models (LLMs) use tokenizers that split text into subword units. This tokenization can create challenges when implementing strict structural constraints:

1. **Tokenization Inconsistency**: The same word or phrase might be tokenized differently depending on context
2. **Partial Token Matches**: A semantic unit (like "true") might span multiple tokens
3. **Vocabulary Differences**: Different models tokenize the same text differently
4. **Whitespace Handling**: Tokenizers treat whitespace inconsistently

Without token healing, these issues would cause generation to fail when a token doesn't exactly match what's expected, even if it's part of a valid sequence.

## Token Healing Fundamentals

### What is Token Healing?

Token healing is a technique that allows PSE to accept tokens that are not exact matches but could be part of a valid sequence. It works by:

1. Giving "partial credit" to tokens that form the beginning of valid sequences
2. Looking ahead to see if the current token could start a valid path
3. Allowing the model to "heal" minor tokenization issues during generation

### Example: Healing Boolean Values

Consider generating the JSON boolean value `true`:

- The word "true" might be tokenized as:
  - A single token (`"true"`)
  - Multiple tokens (`"tr"` + `"ue"`)
  - With whitespace (`" true"`)

With token healing:

1. If the model generates `"tr"` when expecting `"true"`, PSE recognizes it as a prefix of `"true"`
2. PSE allows the token and appropriately constrains the next tokens to complete `"true"`
3. The generation continues correctly despite the tokenization mismatch

Without token healing, the generation would fail at the first non-exact match.

## How Token Healing Works

### The Token Healing Algorithm

The PSE token healing process works as follows:

1. **Initial Token Validation**: Check if the token is an exact match for any valid transition
2. **Prefix Matching**: If no exact match, check if the token could be the start of a valid multi-token sequence
3. **Suffix Matching**: Check if the token could be the continuation of an expected sequence
4. **Scoring**: Assign a "healing score" based on how well the token matches expectations
5. **Thresholding**: Accept tokens above a configurable healing threshold
6. **State Adjustment**: Adjust the state machine to account for partially healed tokens

### Prefix Healing Example

```
Expected: "true"
Token sequence: ["tr", "ue"]

Processing "tr":
1. Not an exact match for "true"
2. Is a prefix of "true" → Healing score: 0.7
3. Above threshold → Accept token
4. Adjust state to expect completion of "true"

Processing "ue":
1. In the context of expecting completion of "true" after "tr"
2. "tr" + "ue" = "true" → Complete match
3. Fully healed → Accept token
4. Transition to post-boolean state
```

### Multi-token Healing

PSE can even handle complex cases where multiple tokens need healing:

```
Expected: "temperature"
Token sequence: [" temp", "er", "ature"]

Processing " temp":
1. Not an exact match for "temperature"
2. Is a prefix of "temperature" → Healing score: 0.5
3. Above threshold → Accept token
4. Adjust state to expect completion of "temperature"

Processing "er":
1. In context of continuing "temperature"
2. " temp" + "er" is still a prefix → Continue healing
3. Accept token

Processing "ature":
1. In context of continuing "temperature"
2. " temp" + "er" + "ature" → Complete match
3. Fully healed → Accept token
4. Transition to next state
```

## Token Healing Configuration

PSE provides several configuration options to control token healing behavior:

### Healing Threshold

The healing threshold determines how aggressive the healing should be:

```python
# Configure healing threshold (0.0 to 1.0)
engine = StructuringEngine.from_json_schema(
    schema,
    config={"healing_threshold": 0.7}  # Higher = stricter, lower = more forgiving
)
```

- **Higher Threshold** (e.g., 0.8): More conservative healing, requiring closer matches
- **Lower Threshold** (e.g., 0.4): More aggressive healing, allowing more distant matches

### Maximum Healing Length

You can limit how many tokens can be used in a healing sequence:

```python
# Limit healing to at most 3 tokens
engine = StructuringEngine.from_json_schema(
    schema,
    config={"max_healing_tokens": 3}
)
```

### Healing Modes

PSE supports different healing modes for different use cases:

```python
# Set healing mode
engine = StructuringEngine.from_json_schema(
    schema,
    config={"healing_mode": "aggressive"}  # Options: "conservative", "balanced", "aggressive"
)
```

- **Conservative**: Minimal healing, prioritizing exact matches
- **Balanced**: Default mode, reasonable healing without being too permissive
- **Aggressive**: Maximum healing capability, useful for challenging tokenization

## Advanced Healing Techniques

### Context-Aware Healing

PSE's token healing is context-aware, meaning that the healing behavior adapts based on the current state in the state machine:

- **String Context**: More permissive healing inside strings
- **Keyword Context**: Stricter healing for keywords and structural elements
- **Numeric Context**: Special handling for number tokenization

### Whitespace Normalization

A special case of healing is whitespace normalization:

```python
# Enable whitespace normalization
engine = StructuringEngine.from_json_schema(
    schema,
    config={"normalize_whitespace": True}
)
```

This allows PSE to handle variations in whitespace tokenization gracefully.

### Case-Insensitive Healing

For case-insensitive matching:

```python
# Enable case-insensitive healing
engine = StructuringEngine.from_json_schema(
    schema,
    config={"case_insensitive_healing": True}
)
```

This is useful for formats where case doesn't matter, like HTTP methods.

## Token Healing in Different Contexts

### JSON Structure Healing

In JSON contexts, healing helps with:

- **Quoted Strings**: Handling different quotation tokenization
- **Boolean Values**: Addressing "true"/"false" tokenization variants
- **Number Formats**: Managing decimal, scientific notation, etc.
- **Keywords**: Dealing with "null" and other special values

### Custom Grammar Healing

For custom grammars, healing provides:

- **Keyword Recognition**: Flexibly matching grammar keywords
- **Pattern Completion**: Helping complete regex patterns across tokens
- **Delimiter Handling**: Managing delimiters that might split across tokens

### Natural Language Boundaries

At the boundaries between natural language and structured formats:

- **Format Markers**: Healing helps with format indicators (e.g., "```json")
- **Transition Tokens**: Manages transitions between free text and structure
- **Special Sequences**: Handles markdown and other formatting constructs

## Debugging Token Healing

PSE provides tools to inspect and debug token healing behavior:

### Healing Logs

```python
# Enable healing logs
engine = StructuringEngine.from_json_schema(
    schema,
    config={"debug_healing": True}
)

# Generate with healing logs
outputs = engine.generate(model, input_ids, max_tokens=100)

# Access healing logs
healing_events = engine.get_healing_events()
```

### Visualization Tools

```python
# Visualize healing during generation
from pse.debug import visualize_healing

engine = StructuringEngine.from_json_schema(schema)
healing_viz = visualize_healing(engine, model, input_ids)
```

## Performance Implications

Token healing has performance implications to consider:

### Computational Overhead

- **String Matching**: Prefix and suffix matching adds computational cost
- **Multiple Paths**: Healing often creates additional parallel paths to explore
- **Lookahead**: May require examining future tokens

### Memory Usage

- **State Tracking**: Healing requires tracking partial matches
- **Parallel States**: Multiple healing paths consume memory
- **History**: Keeping track of healing history for debugging

### Optimization Strategies

To optimize performance while maintaining healing capabilities:

- **Targeted Healing**: Apply healing only where needed most
- **Cached Results**: Cache common healing patterns
- **Threshold Tuning**: Adjust thresholds based on performance requirements

## Best Practices

### When to Use Aggressive Healing

- **Multilingual Content**: Different languages tokenize very differently
- **Technical Content**: Programming languages, formulas, etc.
- **Domain-Specific Terminology**: Medical, legal, and scientific terms
- **Custom Tokenizers**: When using tokenizers not trained for your format

### When to Use Conservative Healing

- **Security-Critical Applications**: Where exact matches matter
- **Simple Formats**: Well-tokenized formats with minimal ambiguity
- **Performance-Critical Systems**: Where speed is paramount
- **Format Validation**: When validating against strict standards

### Balancing Healing and Structure

The key to effective token healing is finding the right balance:

- **Start Conservative**: Begin with minimal healing and increase as needed
- **Test Thoroughly**: Validate healing behavior across diverse inputs
- **Monitor Healing Rate**: Track how often healing occurs in production
- **Adapt Dynamically**: Consider adjusting healing thresholds based on context

## Examples of Token Healing in Action

### Example 1: Boolean Healing

```python
# Define a schema with boolean field
schema = {
    "type": "object",
    "properties": {
        "is_active": {"type": "boolean"}
    }
}

# Create engine with default healing
engine = StructuringEngine.from_json_schema(schema)

# Generate with potential tokenization issues
prompt = 'Create a JSON object with the field "is_active" set to true'
output = generate_with_engine(engine, model, prompt)

# Even if "true" is tokenized as ["tr", "ue"], healing ensures correct output
# Result: {"is_active": true}
```

### Example 2: Number Healing

```python
# Define a schema with numeric field
schema = {
    "type": "object",
    "properties": {
        "temperature": {"type": "number"}
    }
}

# Example where scientific notation might be split across tokens
prompt = 'Create a JSON with the temperature as 1.5e-6'

# With healing, correctly handles ["1", ".", "5e", "-", "6"] tokenization
output = generate_with_engine(engine, model, prompt)

# Result: {"temperature": 1.5e-6}
```

### Example 3: Custom Grammar Healing

```python
# Define a custom grammar for SQL-like commands
sql_grammar = Grammar(
    "sql_statement",
    Sequence(
        "SELECT ",
        OneOf(["*", "COUNT(*)", "SUM(...)"]),
        " FROM ",
        Grammar("table_name", r"[a-zA-Z_][a-zA-Z0-9_]*"),
        Optional(
            " WHERE ",
            Grammar("condition", r"[a-zA-Z0-9_\.]+ = [a-zA-Z0-9_\.]+")
        )
    )
)

# With healing, handles tokenization of SQL keywords across tokens
engine = StructuringEngine.from_grammar(sql_grammar)
```

## Conclusion

Token healing is a powerful feature that enables PSE to bridge the gap between the rigid requirements of structured formats and the messy reality of tokenization. By giving partial credit to tokens that could be part of valid sequences, PSE maintains structural guarantees while accommodating the inherent variability of language model tokenization.

This capability is especially important when working with diverse models, languages, and formats, making PSE robust across a wide range of generation scenarios.

## Next Steps

- Review the [State Machine Architecture](state-machine.md) to understand PSE's core design
- Explore the [JSON Schema Guide](../guides/json-schema.md) for practical applications
- Check out the [Structuring Engine API](../api/structuring-engine.md) documentation