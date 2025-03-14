# Base State Machines

Base state machines provide the fundamental building blocks for constructing more complex state machines in PSE. These components handle common pattern-matching tasks and can be composed together to create sophisticated parsing behaviors.

## AnyStateMachine

`AnyStateMachine` allows choosing between multiple state machines, effectively implementing a logical OR operation for state machine matching.

```python
from pse.types.base.any import AnyStateMachine
from pse.types.string import StringStateMachine
from pse.types.number import NumberStateMachine

# Create a state machine that accepts either a string or a number
any_state_machine = AnyStateMachine([
    StringStateMachine(),
    NumberStateMachine()
])
```

**Key features:**
- Accepts input if any of its child state machines accepts it
- Creates transitions from the initial state to each alternative state machine
- Collects steppers from all possible edges to enable parallel path exploration
- Essential for implementing union types, optional patterns, and alternatives
- Lightweight implementation with no additional parameters beyond the list of state machines

**Implementation details:**
- Creates a state graph where state 0 transitions directly to the end state ("$") through each provided state machine
- Uses a simple graph structure with a single state (0) and multiple transitions
- On input, explores all possible paths in parallel through its steppers
- Returns a simple string representation of "Any" for debugging purposes

## ChainStateMachine

`ChainStateMachine` combines multiple state machines in sequence, requiring each to match in order.

```python
from pse.types.base.chain import ChainStateMachine
from pse.types.base.phrase import PhraseStateMachine
from pse.types.string import StringStateMachine
from pse.types.whitespace import WhitespaceStateMachine

# Create a state machine for parsing a key-value pair like "name: "John""
chain_state_machine = ChainStateMachine([
    StringStateMachine(),  # The key
    WhitespaceStateMachine(),  # Optional whitespace
    PhraseStateMachine(":"),  # The separator
    WhitespaceStateMachine(),  # Optional whitespace
    StringStateMachine()  # The value
])

# Create an optional chain
optional_chain = ChainStateMachine([
    PhraseStateMachine(","),
    WhitespaceStateMachine()
], is_optional=True)
```

**Key features:**
- Enforces sequential matching of multiple patterns
- Propagates state from one sub-machine to the next
- Supports optional chains with the `is_optional` parameter
- Essential for constructing complex sequential patterns
- Used extensively in format-specific state machines

**Implementation details:**
- Creates a linear state graph where each state `i` transitions to state `i+1` through its corresponding state machine
- Automatically sets the final state `len(state_machines)` as the only end state
- Uses a specialized `ChainStepper` class to handle sequential execution
- Minimal implementation that efficiently chains state machines together
- Accurately tracks state transitions through the sequence
- Handles nested chains and complex sequences within larger state machines

## LoopStateMachine

`LoopStateMachine` repeats a state machine a configurable number of times, enabling iteration patterns.

```python
from pse.types.base.loop import LoopStateMachine
from pse.types.number import NumberStateMachine
from pse.types.whitespace import WhitespaceStateMachine

# Create a state machine for a comma-separated list of numbers
numbers_list = LoopStateMachine(
    NumberStateMachine(),
    min_loop_count=1,  # At least one number
    max_loop_count=5,  # Maximum five numbers
    whitespace_seperator=True  # Allow whitespace between elements
)
```

**Key features:**
- Configurable minimum and maximum repetition counts
- Optional whitespace handling between iterations
- Maintains loop count tracking through the specialized `LoopStepper` class
- Implements arrays, lists, and repeated patterns
- Supports unlimited repetition with `max_loop_count=-1` (default)

**Implementation details:**
- Creates two different state graph structures based on `whitespace_seperator`:
  - Without separator: State 0 → State 1 (via state_machine) → back to State 0 (via state_machine again)
  - With separator: State 0 → State 1 (via state_machine) → State 2 (via whitespace) → back to State 1 (via state_machine)
- Uses the `is_optional` parameter internally calculated from `min_loop_count == 0`
- Contains a typo in parameter name ("whitespace_seperator" instead of "separator")
- Specialized `LoopStepper` tracks iteration count with `loop_count` property, incrementing in `add_to_history`
- Whitespace separators are excluded from history and loop count calculation
- Determines acceptance state based on the minimum loop count and sub-stepper state
- Enforces maximum iterations by overriding `can_accept_more_input` and `should_start_step`
- Provides special handling of final state to exclude whitespace separators

## PhraseStateMachine

`PhraseStateMachine` matches specific text sequences exactly, validating input against the target string.

```python
from pse.types.base.phrase import PhraseStateMachine

# Create a state machine that matches only the text "Hello, World!"
greeting = PhraseStateMachine("Hello, World!")

# Create an optional phrase that may or may not appear
optional_phrase = PhraseStateMachine("Optional text", is_optional=True)

# Create a case-insensitive phrase
case_insensitive = PhraseStateMachine("HELLO", is_case_sensitive=False)
```

**Key features:**
- Matches exact character sequences with character-by-character validation
- High-efficiency implementation for literal text using optimized prefix matching
- Support for Unicode characters and multi-byte sequences
- Case sensitivity configuration with the `is_case_sensitive` parameter
- Can be marked as optional with the `is_optional` parameter
- Used for keywords, delimiters, and fixed tokens throughout PSE

**Implementation details:**
- Requires a non-empty phrase string (raises `ValueError` if empty)
- Uses a specialized `PhraseStepper` that tracks position with `consumed_character_count`
- Sets target state directly to end state ("$") in the stepper
- Implements prefix matching with the optimized `_get_valid_match_length` method
- Processes partial matches by accepting as much of the input as matches the phrase
- Returns the exact remaining portion of the phrase for valid continuations
- String representation includes the phrase value: `Phrase('value')`
- Completion is determined when `consumed_character_count == len(phrase)`
- Can check for equality with other PhraseStateMachine instances
- Essential building block for many other state machines in PSE

## WaitFor

`WaitFor` accumulates arbitrary text until a specific pattern is detected, enabling flexible pattern recognition in mixed content.

```python
from pse.types.base.wait_for import WaitFor
from pse.types.base.phrase import PhraseStateMachine

# Create a state machine that accumulates text until "```json" is encountered
# Useful for finding JSON code blocks in Markdown
json_block_start = WaitFor(
    PhraseStateMachine("```json"),
    buffer_length=0  # No minimum buffer required
)

# Create a state machine with strict validation
# If the pattern starts but is interrupted, the match will fail
strict_pattern = WaitFor(
    PhraseStateMachine("BEGIN DATA"),
    buffer_length=10,  # Require at least 10 characters before matching pattern
    strict=True  # Fail if pattern is interrupted
)
```

**Key features:**
- Buffers text until target pattern is detected
- Configurable minimum buffer length with `buffer_length` parameter
- Strict mode for handling invalid inputs with the `strict` parameter
- Perfect for delimiter-based parsing of mixed content
- Enables flexible handling of unstructured text before structured elements

**Implementation details:**
- Uses a direct transition structure with the target pattern transitioning to end state ("$")
- `get_transitions` creates transitions directly from the nested state machine's steppers
- Specialized `WaitForStepper` maintains accumulated text in a `buffer` property
- Sets `target_state = "$"` in the stepper initialization
- Implements `accepts_any_token()` based on buffer length and sub-stepper state
- `should_start_step()` checks:
  - Buffer length requirements
  - Presence of remaining input
  - Current processing state
- When `strict=True`, rejects entire input if the pattern is interrupted
- When `strict=False`, allows pattern matching to restart after interruption
- With `buffer_length=-1`, only accepts tokens that match the target pattern
- With `buffer_length=0`, accepts any token while watching for the pattern
- With `buffer_length>0`, requires buffer to reach minimum length before allowing match
- Provides specialized handling of valid and invalid continuations
- Efficiently processes tokens by finding valid prefixes using token partitioning

## CharacterStateMachine

`CharacterStateMachine` matches individual characters based on character sets, allowing precise control over which characters are accepted.

```python
from pse.types.base.character import CharacterStateMachine

# Create a state machine that matches any character (no restrictions)
any_char_sm = CharacterStateMachine()

# Create a state machine that matches only lowercase letters a-z
alpha_sm = CharacterStateMachine(whitelist_charset="abcdefghijklmnopqrstuvwxyz")

# Create a state machine that matches any character except digits
no_digits_sm = CharacterStateMachine(blacklist_charset="0123456789")

# Create a state machine with multiple constraints
identifier_sm = CharacterStateMachine(
    whitelist_charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_",
    char_min=1,          # At least one character
    char_limit=64,       # Maximum of 64 characters
    case_sensitive=True  # Case-sensitive matching
)

# Use graylist for characters that terminate a match
word_sm = CharacterStateMachine(
    graylist_charset=" \t\n.,:;!?"  # Space and punctuation terminate words
)
```

**Key features:**
- Highly flexible character-level matching with configurable character sets
- Supports whitelist (explicitly allowed), blacklist (explicitly forbidden), and graylist (allowed but terminates sequence) character sets
- Configurable minimum and maximum character counts
- Case-sensitive or case-insensitive matching
- Efficiently processes longest valid prefixes in input tokens

**Implementation details:**
- Configurable parameters with clear defaults:
  - Empty charsets by default (empty strings)
  - `char_min` defaults to 0 (no minimum length)
  - `char_limit` defaults to 0 (unlimited length)
  - `is_optional` defaults to false
  - `case_sensitive` defaults to true
- Three distinct character set types stored as `set` objects:
  - `charset` (whitelist): Only these characters are allowed
  - `blacklist_charset`: These characters are explicitly forbidden
  - `graylist_charset`: Allowed but terminate matching when after other characters
- Case-insensitive mode converts all characters to lowercase
- `CharacterStepper` sets `target_state="$"` and tracks value with `_raw_value`
- Implements `accepts_any_token()` to return true when no whitelist is defined
- Uses `should_start_step()` to validate the first character against constraints
- Implements efficient prefix matching in `consume()`:
  - Checks each character in token for validity against all constraints
  - Finds longest valid prefix that satisfies all character constraints
  - Efficiently handles blacklist, whitelist, length limits, and graylist checks
  - Preserves remaining input for continued processing
- Returns the complete whitelist charset for valid continuations
- Allows early termination of matching when graylist characters appear

## EncapsulatedStateMachine

`EncapsulatedStateMachine` wraps a state machine between start and end delimiters, enabling parsing of fenced or delimited content.

```python
from pse.types.base.encapsulated import EncapsulatedStateMachine
from pse.types.base.any import AnyStateMachine
from pse.types.string import StringStateMachine
from pse.types.number import NumberStateMachine

# Create a state machine for parsing JSON code blocks in Markdown
json_code_block = EncapsulatedStateMachine(
    ObjectStateMachine(),              # Content state machine for JSON objects
    delimiters=("```json\n", "\n```"),  # Start and end delimiters
    buffer_length=0                     # No minimum buffer before delimiter
)

# Create a state machine for XML tags with content
xml_content = EncapsulatedStateMachine(
    StringStateMachine(),              # Content for the XML element
    delimiters=("<content>", "</content>")  # XML tags
)

# Create a state machine that requires minimum buffer before finding delimiter
delayed_content = EncapsulatedStateMachine(
    StringStateMachine(),              # Content state machine
    delimiters=("<START>", "<END>"),   # Delimiters
    buffer_length=10,                  # Require at least 10 characters before matching delimiter
    is_optional=True                   # Make the entire structure optional
)
```

**Key features:**
- Wraps any state machine between specified start and end delimiters
- Configurable buffer length before matching start delimiter
- Can be optional with the `is_optional` parameter
- Perfect for parsing code blocks, markup elements, and delimited content
- Provides clean token output with delimiters automatically removed

**Implementation details:**
- Implements a three-state process with a clear state graph:
  - State 0: Uses `WaitFor` with `PhraseStateMachine` to find the start delimiter
  - State 1: Processes the inner content using the provided state machine
  - State 2: Matches the end delimiter using a `PhraseStateMachine`
- Default delimiters are ("```", "```") if none are provided
- `buffer_length` parameter is passed to the internal `WaitFor` state machine
- Uses specialized `EncapsulatedStepper` to track state and content
- Maintains an `inner_stepper` reference for the state machine's stepper in state 2
- `is_within_value()` returns true when not in state 0 or when in state 0 with an active sub-stepper
- Provides `get_invalid_continuations()` to prevent end delimiter before processing starts
- Implements the `get_token_safe_output()` helper method which:
  - Efficiently handles both exact and partial delimiter occurrences
  - Optimizes removal by checking for exact matches before using strip operations
  - Processes token IDs history for reliable delimiter removal
- Can handle nested encapsulated content with proper tracking
- Used extensively for parsing structured content like code blocks and XML elements
