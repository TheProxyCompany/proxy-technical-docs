# Token Healing

Token healing is a sophisticated error recovery mechanism in PSE that enables robust handling of tokenization mismatches between language model tokens and grammar rules.

## What is Token Healing?

Token healing allows PSE to recover from situations where a model generates tokens that don't perfectly align with the grammar's expected tokens. Instead of rejecting these tokens outright, PSE can "heal" them by finding valid prefixes and continuing generation.

This is crucial because language models use subword tokenization, which may split words in ways that don't align with the logical boundaries required by the grammar.

## How Token Healing Works

Token healing is a multi-step process designed to bridge the gap between model tokenization and grammar requirements:

1. **Token Validation**: When a token is generated, PSE tries to advance each stepper with the token
2. **Partial Match Detection**: If a stepper can only partially consume a token, PSE tracks what portion was consumed
3. **Prefix Analysis**: PSE calculates how much of the token was consumed and what parts were valid
4. **Vocabulary Lookup**: PSE finds the longest valid prefix in its vocabulary that matches what was consumed
5. **Healed Path Creation**: If a valid prefix is found, PSE marks this path as "healed" for tracking
6. **Preference Tracking**: Healed paths are given lower priority during path selection to prefer exact matches when available

## Example: Token Healing in Action

Consider a JSON grammar expecting the keyword `true`, but the model tokenizes it as `t` + `rue`:

### Without Token Healing:

1. LLM generates token "t"
2. PSE attempts to advance parsing with "t":
   - The grammar expects the full token "true"
   - Partial match found, but no token healing enabled
3. All parsing paths fail to advance
4. PSE must resample, possibly multiple times
5. Generation quality suffers

### With Token Healing:

1. LLM generates token "t"
2. PSE attempts to advance parsing with "t":
   - Partial match detected against the expected "true" 
   - PSE recognizes that only part of the token was consumed
3. Token healing activates:
   - Finds the longest valid prefix matching "t"
   - Creates a valid but "healed" parsing path
4. During path selection:
   - Healed path is valid but marked for lower priority
   - If better paths exist, they're preferred
   - If no better paths exist, healing allows generation to continue
5. Next token ("rue") can be processed normally

This example demonstrates how token healing allows generation to continue even when token boundaries don't align perfectly with grammar expectations.

## Path Selection with Healed Tokens

After tokens are processed (and potentially healed), PSE uses a sophisticated path selection algorithm that considers multiple factors:

### Path Ranking Criteria (in order of priority):

1. **Accept States**: Paths that reach completion states in the grammar are prioritized
2. **Healing Status**: Non-healed paths are preferred over healed ones
3. **Probability Score**: Higher probability paths from the model are preferred
4. **Token Length**: Longer tokens are preferred when scores are equal

### Attractive Paths

A path is considered "attractive" if it satisfies at least one of these criteria:
- It reaches an accept state (successfully completes a grammar structure)
- It didn't require token healing (perfect match with expected tokens)

Attractive paths are preferred during generation as they represent more confident parsing of the grammar.

## Token Healing vs. Multi-Token Processing

PSE implements two complementary mechanisms for handling tokenization challenges:

### Token Healing
- **Purpose**: Recover from partial token matches during consumption
- **When Used**: During token validation (after sampling)
- **How It Works**: Uses HAT-trie to find longest valid prefix
- **Result**: Marks tokens as "healed" for path selection

### Multi-Token Processing (MTP)
- **Purpose**: Handle cases where grammar tokens map to multiple model tokens
- **When Used**: During logit processing (before sampling)
- **How It Works**: Maps first token to full token sequences
- **Result**: Auto-completes token sequences during generation

## Configuration Options

Token healing is configurable to match your needs:

```python
# Enable/disable token healing
engine = StructuringEngine.from_json_schema(schema, token_healing=True)

# Configure generation behavior
output = engine.generate(
    model,
    input_ids,
    token_healing=True,           # Enable token healing
    max_healing_attempts=3,       # Max healing attempts per token
    resampling_limit=5,           # Max resampling attempts before accepting best path
    prefer_healed_paths=False     # Prefer non-healed paths when available
)
```

## Performance Impact

Token healing generally improves generation quality with minimal performance impact:

- **Success Rate**: Significantly higher completion rate for complex grammars
- **Generation Speed**: Slight overhead during token processing, offset by reduced resampling
- **Memory Usage**: Negligible additional memory for vocabulary lookups

## When to Use Token Healing

Token healing is most beneficial when:

- Working with complex grammars with specific keywords
- Generating code or formal languages
- Using models with tokenization that doesn't align well with your grammar
- Requiring high success rates for structured generation

It can be disabled when:
- Working with extremely simple grammars
- Maximum performance is critical
- Using custom tokenizers aligned with your grammar