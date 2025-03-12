# Multi-Token Processing

Multi-Token Processing (MTP) is a powerful feature in PSE that efficiently handles cases where grammar elements map to multiple LLM tokens, optimizing generation for tokenization differences.

## The Multi-Token Challenge

Language models tokenize text into subword units, which often don't align with logical grammar elements:

```
Grammar element: "function"
Possible tokenization: ["func", "tion"] 
```

When generating text that must follow exact grammar rules, this mismatch creates challenges:
- The model might generate only the first part of a multi-token element
- Generation might fail because partial matches don't satisfy the grammar
- Multiple resampling attempts may be needed to find valid continuations

## How Multi-Token Processing Works

Multi-Token Processing addresses these challenges by:

1. **Creating Token Mappings**: PSE builds mappings from initial tokens to complete sequences
2. **Token Sequence Handling**: When the model generates the start of a known sequence, PSE can intelligently handle the complete sequence
3. **Optimizing Generation**: By recognizing token patterns, PSE can advance multiple steps at once

### Multi-Token Processing Flow

1. **Initialization**: During setup, PSE analyzes valid grammar continuations to identify strings that require multiple tokens
2. **Mapping Creation**: PSE creates mappings where:
   - The first token in a sequence serves as the key
   - The complete sequence of tokens serves as the value
3. **Common Prefix Detection**: For ambiguous sequences starting with the same token (like "greater_than" vs "greater_than_or_equal"), PSE:
   - Finds the common token prefix between the sequences
   - Stores only the common prefix to handle both cases correctly
4. **Detection During Generation**: When PSE encounters a token that starts a known sequence
5. **Sequence Construction**: PSE processes the entire token sequence as a unit
6. **Efficient Processing**: The complete multi-token sequence is handled in a single step

This on-the-fly processing happens during each token generation step, allowing PSE to dynamically handle complex token sequences that might otherwise be split awkwardly by the LLM's tokenizer.

## Multi-Token Processing in Action

Consider a grammar that expects the keyword `function`:

### Without Multi-Token Processing:
1. Model might tokenize "function" as ["func", "tion"]
2. PSE checks if "func" is a valid token (it's not, since it expects "function")
3. Token healing might allow "func" to be accepted as partial match
4. Next token "tion" would need to be processed separately
5. Extra resampling might be needed at each step

### With Multi-Token Processing:
1. PSE analyzes valid continuations and finds "function" is a valid token
2. During initialization, PSE breaks "function" into its token sequence: ["func", "tion"]
3. PSE builds mapping: token_id("func") → [token_id("func"), token_id("tion")]
4. When model generates the "func" token ID, PSE:
   - Recognizes it as the key in the multi-token mapping
   - Concatenates the string representation of all tokens in the sequence
   - Processes "function" as a single unit through the state machine
5. The output is correctly processed without additional resampling or healing

### Handling Ambiguous Sequences

For ambiguous cases like `greater_than` and `greater_than_or_equal`:

1. PSE identifies both are valid and maps:
   - token_id("greater") → [token_id("greater"), token_id("_than")]
   - token_id("greater") → [token_id("greater"), token_id("_than"), token_id("_or"), token_id("_equal")]

2. PSE detects the conflict (same starting token) and:
   - Finds the common prefix: [token_id("greater"), token_id("_than")]
   - Updates the mapping to just this common prefix

3. When generating, after "greater_than" is processed:
   - The stepper advances to a state where more specific continuations are possible
   - The model can then generate either nothing (for just "greater than") or "_or_equal"

## Benefits of Multi-Token Processing

MTP provides several advantages:

1. **Reduced Resampling**: Fewer token rejections and resampling attempts
2. **Better Performance**: Can advance multiple tokens at once for known sequences
3. **More Natural Generation**: Model can follow its natural tokenization patterns
4. **Higher Success Rate**: Especially for grammars with specific keywords

## Configuration Options

Multi-Token Processing can be configured based on your needs:

```python
# Enable/disable multi-token processing when creating the engine
engine = StructuringEngine.from_json_schema(
    schema,
    multi_token_processing=True  # Default is True
)

# Configure during generation
output = engine.generate(
    model,
    input_ids,
    multi_token_processing=True,  # Enable MTP
    max_multi_token_length=5      # Maximum tokens in a sequence
)
```

## Comparing Token Healing and Multi-Token Processing

These two features work together to handle tokenization challenges:

| Feature | Token Healing | Multi-Token Processing |
|---------|---------------|------------------------|
| **Purpose** | Recover from partial matches | Handle multi-token sequences |
| **When applied** | After token generation | During token sampling |
| **Mechanism** | Finds valid prefixes in vocabulary | Maps initial tokens to sequences |
| **Primary benefit** | Error recovery | Optimization |
| **Example use case** | Handling unexpected tokens | Known keywords split across tokens |

## Performance Considerations

Multi-Token Processing has minimal overhead:
- Memory usage scales with the number of multi-token sequences
- Processing overhead is negligible compared to model inference
- Significant performance benefits from reduced resampling

## When to Use Multi-Token Processing

MTP is most beneficial when:

- Your grammar contains specific keywords that might be split across tokens
- You're generating programming languages or formal syntax
- You want to maximize generation efficiency
- You need high success rates for complex structures

It can be disabled when:
- Working with very simple grammars
- Using custom tokenizers that align perfectly with your grammar
- Memory usage is extremely constrained