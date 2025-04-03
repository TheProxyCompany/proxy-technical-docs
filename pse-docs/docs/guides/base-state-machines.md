# Base State Machines

While PSE excels at automatically converting Pydantic models, JSON Schemas, and function signatures into the necessary `StateMachine` structures, it also provides a set of fundamental, composable `StateMachine` base types. These allow developers to define custom grammars or control flows directly, offering more granular control when needed.

These base types are located in `pse.types.base` and are the building blocks used internally by the schema conversion logic. Understanding them is key to advanced usage and creating bespoke structuring logic.

## Core Base Types

*   **`PhraseStateMachine`**:
    *   **Purpose:** Matches an exact sequence of characters (a specific string).
    *   **Use Case:** Defining keywords, delimiters, operators, or fixed string literals within a grammar.
    *   **Example:** `PhraseStateMachine("true")`, `PhraseStateMachine("```json\n")`

```python
# Example Usage: Match the keyword "class"
keyword_sm = PhraseStateMachine("class")

# Example Usage: Match a specific delimiter
delimiter_sm = PhraseStateMachine("---")
```

*   **`CharacterStateMachine`**:
    *   **Purpose:** Matches characters based on inclusion/exclusion rules (whitelist, blacklist, graylist) with optional length constraints (min/max characters).
    *   **Use Case:** Defining patterns like integers (`whitelist_charset="0123456789"`), whitespace (`whitelist_charset=" \t\n\r"`), or general string content excluding specific characters (`blacklist_charset='"'`).
    *   **Example:** `CharacterStateMachine(whitelist_charset="abc", char_limit=5)`

```python
# Example Usage: Match any digit
digit_sm = CharacterStateMachine(whitelist_charset="0123456789")

# Example Usage: Match whitespace (optional, up to 10 chars)
whitespace_sm = CharacterStateMachine(
    whitelist_charset=" \t\n\r",
    char_limit=10,
    is_optional=True
)

# Example Usage: Match any character except quotes
non_quote_sm = CharacterStateMachine(blacklist_charset='"')
```

*   **`ChainStateMachine`**:
    *   **Purpose:** Executes a sequence of other `StateMachine`s in a specific, fixed order. Each machine in the chain must complete successfully before the next one starts.
    *   **Use Case:** Defining structures where elements must appear sequentially, like a key-value pair (`StringStateMachine` -> `WhitespaceStateMachine` -> `PhraseStateMachine(":")` -> `WhitespaceStateMachine` -> `JsonStateMachine`).
    *   **Example:** `ChainStateMachine([PhraseStateMachine("A"), PhraseStateMachine("B")])` requires "AB".

```python
# Example Usage: Match "key: value" pattern
key_value_sm = ChainStateMachine([
    StringStateMachine(),     # Key
    PhraseStateMachine(":"),  # Separator
    WhitespaceStateMachine(), # Optional space
    JsonStateMachine()        # Value
])
```

*   **`AnyStateMachine`**:
    *   **Purpose:** Accepts input that matches *any one* of the provided `StateMachine`s. It essentially represents a logical OR condition.
    *   **Use Case:** Defining points in a grammar where multiple different structures are valid (e.g., a JSON value can be a string OR a number OR an object...). Used heavily in handling `anyOf` / `oneOf` in JSON Schema or `Union` types in Pydantic.
    *   **Example:** `AnyStateMachine([StringStateMachine(), NumberStateMachine()])` accepts either a string or a number.

```python
# Example Usage: Accept 'true', 'false', or 'null'
json_literal_sm = AnyStateMachine([
    PhraseStateMachine("true"),
    PhraseStateMachine("false"),
    PhraseStateMachine("null")
])
```

*   **`LoopStateMachine`**:
    *   **Purpose:** Repeats a single `StateMachine` a specified number of times (with optional min/max loop counts). Can include an optional separator `StateMachine` (like whitespace or a comma) between repetitions.
    *   **Use Case:** Defining arrays/lists where an element pattern repeats, potentially separated by commas or whitespace.
    *   **Example:** `LoopStateMachine(JsonStateMachine(), min_loop_count=1, whitespace_seperator=True)` matches one or more JSON values separated by optional whitespace.

```python
# Example Usage: Match one or more words separated by whitespace
# Assumes CharacterStateMachine is defined elsewhere
word_loop_sm = LoopStateMachine(
    state_machine=CharacterStateMachine(blacklist_charset=" \t\n\r"), # Matches non-whitespace chars
    min_loop_count=1,
    whitespace_seperator=True # Allows whitespace between words
)
# This would match "word1 word2 word3"
```

*   **`EncapsulatedStateMachine`**:
    *   **Purpose:** Matches content that is wrapped by specific start and end delimiter strings. It uses an inner `StateMachine` to validate the content *between* the delimiters.
    *   **Use Case:** Parsing content within specific tags or fences, like markdown code blocks (` ``` `) or custom XML-like tags.
    *   **Example:** `EncapsulatedStateMachine(JsonStateMachine(), delimiters=("<json>", "</json>"))` matches valid JSON enclosed in `<json>` tags.

```python
# Example Usage: Match JSON within markdown code fences
# Assumes JsonStateMachine is defined elsewhere
json_block_sm = EncapsulatedStateMachine(
    state_machine=JsonStateMachine(),
    delimiters=("```json\n", "\n```")
)

# Example Usage: Optional XML-like tag with content
# Assumes StringStateMachine is defined elsewhere
optional_xml_sm = EncapsulatedStateMachine(
    state_machine=StringStateMachine(),
    delimiters=("<data>", "</data>"),
    is_optional=True
)
```

*   **`WaitFor`**:
    *   **Purpose:** Consumes arbitrary text until a specific nested `StateMachine` is successfully triggered. Useful for skipping preamble or freeform text before structured content begins.
    *   **Use Case:** Allowing an LLM to "think" or write introductory text before starting a required structured block (like a JSON object fenced by ```json).
    *   **Example:** `WaitFor(PhraseStateMachine("```json"))` consumes all text until it encounters "```json".

```python
# Example Usage: Skip preamble until "<START>" is found
# Assumes PhraseStateMachine is defined elsewhere
wait_for_start_sm = WaitFor(
    state_machine=PhraseStateMachine("<START>")
    # buffer_length=-1 (default) means it only looks for the start phrase
)

# Example Usage: Require some buffer before looking for JSON
wait_for_json_buffered_sm = WaitFor(
    state_machine=PhraseStateMachine("```json"),
    buffer_length=20 # Requires at least 20 chars before ```json can match
)
```

## Composition

The power of these base types lies in their composition. By nesting `Chain`, `Any`, `Loop`, etc., and using `Phrase` and `Character` for the terminal elements, developers can construct arbitrarily complex `StateMachine` graphs to represent sophisticated grammars and control flows directly in Python, going beyond the capabilities of standard schema definitions when necessary. The PBA's `AgentStateMachine` is a prime example of this compositional approach.