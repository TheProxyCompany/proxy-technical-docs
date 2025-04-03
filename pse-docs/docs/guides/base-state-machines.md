# Base State Machines

While PSE excels at automatically converting Pydantic models, JSON Schemas, and function signatures into the necessary `StateMachine` structures, it also provides a set of fundamental, composable `StateMachine` base types. These allow developers to define custom grammars or control flows directly, offering more granular control when needed.

These base types are located in `pse.types.base` and are the building blocks used internally by the schema conversion logic. Understanding them is key to advanced usage and creating bespoke structuring logic.

## Core Base Types

*   **`PhraseStateMachine`**:
    *   **Purpose:** Matches an exact sequence of characters (a specific string).
    *   **Use Case:** Defining keywords, delimiters, operators, or fixed string literals within a grammar.
    *   **Example:** `PhraseStateMachine("true")`, `PhraseStateMachine("```json\n")`

*   **`CharacterStateMachine`**:
    *   **Purpose:** Matches characters based on inclusion/exclusion rules (whitelist, blacklist, graylist) with optional length constraints (min/max characters).
    *   **Use Case:** Defining patterns like integers (`whitelist_charset="0123456789"`), whitespace (`whitelist_charset=" \t\n\r"`), or general string content excluding specific characters (`blacklist_charset='"'`).
    *   **Example:** `CharacterStateMachine(whitelist_charset="abc", char_limit=5)`

*   **`ChainStateMachine`**:
    *   **Purpose:** Executes a sequence of other `StateMachine`s in a specific, fixed order. Each machine in the chain must complete successfully before the next one starts.
    *   **Use Case:** Defining structures where elements must appear sequentially, like a key-value pair (`StringStateMachine` -> `WhitespaceStateMachine` -> `PhraseStateMachine(":")` -> `WhitespaceStateMachine` -> `JsonStateMachine`).
    *   **Example:** `ChainStateMachine([PhraseStateMachine("A"), PhraseStateMachine("B")])` requires "AB".

*   **`AnyStateMachine`**:
    *   **Purpose:** Accepts input that matches *any one* of the provided `StateMachine`s. It essentially represents a logical OR condition.
    *   **Use Case:** Defining points in a grammar where multiple different structures are valid (e.g., a JSON value can be a string OR a number OR an object...). Used heavily in handling `anyOf` / `oneOf` in JSON Schema or `Union` types in Pydantic.
    *   **Example:** `AnyStateMachine([StringStateMachine(), NumberStateMachine()])` accepts either a string or a number.

*   **`LoopStateMachine`**:
    *   **Purpose:** Repeats a single `StateMachine` a specified number of times (with optional min/max loop counts). Can include an optional separator `StateMachine` (like whitespace or a comma) between repetitions.
    *   **Use Case:** Defining arrays/lists where an element pattern repeats, potentially separated by commas or whitespace.
    *   **Example:** `LoopStateMachine(JsonStateMachine(), min_loop_count=1, whitespace_seperator=True)` matches one or more JSON values separated by optional whitespace.

*   **`EncapsulatedStateMachine`**:
    *   **Purpose:** Matches content that is wrapped by specific start and end delimiter strings. It uses an inner `StateMachine` to validate the content *between* the delimiters.
    *   **Use Case:** Parsing content within specific tags or fences, like markdown code blocks (` ``` `) or custom XML-like tags.
    *   **Example:** `EncapsulatedStateMachine(JsonStateMachine(), delimiters=("<json>", "</json>"))` matches valid JSON enclosed in `<json>` tags.

*   **`WaitFor`**:
    *   **Purpose:** Consumes arbitrary text until a specific nested `StateMachine` is successfully triggered. Useful for skipping preamble or freeform text before structured content begins.
    *   **Use Case:** Allowing an LLM to "think" or write introductory text before starting a required structured block (like a JSON object fenced by ```json).
    *   **Example:** `WaitFor(PhraseStateMachine("```json"))` consumes all text until it encounters "```json".

## Composition

The power of these base types lies in their composition. By nesting `Chain`, `Any`, `Loop`, etc., and using `Phrase` and `Character` for the terminal elements, developers can construct arbitrarily complex `StateMachine` graphs to represent sophisticated grammars and control flows directly in Python, going beyond the capabilities of standard schema definitions when necessary. The PBA's `AgentStateMachine` is a prime example of this compositional approach.