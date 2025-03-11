# Format-Specific State Machines

PSE includes specialized state machines for common data formats, making it easy to generate structured outputs that conform to standard specifications.

## JSON State Machines

PSE provides a suite of state machines specifically designed for working with JSON data.

### JsonStateMachine

`JsonStateMachine` serves as the entry point for parsing any valid JSON value. It functions as a dispatcher to specialized state machines for different JSON types.

```python
from pse.types.json.json_value import JsonStateMachine

# Create a general JSON state machine that can parse any valid JSON value
json_sm = JsonStateMachine()
```

**Implementation details:**
- Implements a simple two-state machine:
  - State 0: Initial state with multiple outgoing edges to specialized parsers
  - All parsers transition to a single final state ("$") upon completion
- Delegates parsing to specialized state machines for each JSON type:
  - `ObjectStateMachine` for JSON objects
  - `ArrayStateMachine` for JSON arrays
  - `StringStateMachine` for JSON strings
  - `PhraseStateMachine` for "null" literal
  - `BooleanStateMachine` for true/false
  - `NumberStateMachine` for numeric values
- Uses default steppers from each specialized parser
- Provides valid continuations for any valid JSON value

**Usage in the PSE hierarchy:**
- Acts as the root node for all JSON type parsing
- Used as the default value type in JSON arrays when no schema is specified
- Primary entry point for generic JSON parsing without schema validation
- Can be used directly or as part of more complex state machines

### ObjectSchemaStateMachine

`ObjectSchemaStateMachine` implements schema-aware JSON object parsing and generation, extending the base `ObjectStateMachine` to handle JSON Schema validation.

```python
from pse.types.json.json_object import ObjectSchemaStateMachine

# Define a schema for a person object
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer", "minimum": 0},
        "hobbies": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "hobbies"]
}

# Create a schema-based object state machine
person_object_sm = ObjectSchemaStateMachine(person_schema, {})
```

**Implementation details:**
- Parameters:
  - `schema`: JSON Schema dictionary for object validation
  - `context`: Context information for parsing
  - `properties`: Schema properties (default: {})
  - `required_property_names`: List of required properties (default: [])
  - `additional_properties`: Controls whether extra properties are allowed (default: {})
  - `ordered_properties`: Whether properties must be in order (default: True)

- State graph structure:
  - State 0: Accepts "{" to start object
  - State 1: Whitespace handling after opening brace
  - State 2: Property parsing with schema validation
  - State 3: Whitespace after property
  - State 4: Decision point (comma for next property or "}" to end)

- Schema processing:
  - Automatically processes `nullable` and `default` values to determine truly required properties
  - Properties with default values aren't considered required for parsing
  - Special handling for pattern properties and additional properties

- Validation mechanisms:
  - Only allows object closure when all required properties are present
  - Enforces property ordering when `ordered_properties` is true
  - Controls which properties can be included based on schema definitions

**Additional property handling:**
- When `additional_properties` is true (default): Allows any properties beyond the defined ones
- When `additional_properties` is false: Rejects properties not defined in the schema
- When `additional_properties` is a schema object: Validates extra properties against that schema

**Example with property ordering and additional properties:**
```python
from pse.types.json.json_object import ObjectSchemaStateMachine

# Schema with ordered properties and restricted additional properties
contact_schema = {
    "type": "object",
    "properties": {
        "id": {"type": "string"},
        "name": {"type": "string"},
        "email": {"type": "string", "format": "email"}
    },
    "required": ["id", "name"],
    "additionalProperties": {
        "type": "string"  # Additional props must be strings
    },
    "orderedProperties": True  # Must follow schema order
}

contact_sm = ObjectSchemaStateMachine(
    schema=contact_schema,
    context={},
    ordered_properties=True  # Can also be set via constructor
)
```

**Nested schema example:**
```python
# Schema with nested objects
nested_schema = {
    "type": "object",
    "properties": {
        "user": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "address": {
                    "type": "object",
                    "properties": {
                        "street": {"type": "string"},
                        "city": {"type": "string"}
                    },
                    "required": ["street"]
                }
            },
            "required": ["name"]
        }
    },
    "required": ["user"]
}

# Create nested schema state machine
nested_sm = ObjectSchemaStateMachine(nested_schema, {})
```

### ArraySchemaStateMachine

`ArraySchemaStateMachine` implements schema-aware JSON array processing, extending the base `ArrayStateMachine` to handle JSON Schema validation.

```python
from pse.types.json.json_array import ArraySchemaStateMachine

# Create a JSON array state machine for arrays of strings
string_array_sm = ArraySchemaStateMachine(
    schema={"type": "array", "items": {"type": "string"}},
    context={}
)

# Create a JSON array with length constraints
bounded_array_sm = ArraySchemaStateMachine(
    schema={"type": "array", "items": {"type": "number"}, "minItems": 1, "maxItems": 5},
    context={}
)
```

**Implementation details:**
- Parameters:
  - `schema`: JSON Schema dictionary for array validation
  - `context`: Context for schema resolution containing refs and path information
  
- State graph structure:
  - State 0: Initial state accepting '[' to start the array
  - State 1: Whitespace handling after opening bracket or decision if empty array is valid
  - State 2: Item parsing using schema from 'items' property
  - State 3: Whitespace handling after each item
  - State 4: Decision point (comma for next item or ']' to close)

- Custom stepper implementation:
  - `ArraySchemaStepper` extends `ArrayStepper` with schema validation
  - Tracks item history for uniqueItems enforcement
  - Enforces minItems/maxItems constraints during parsing and generation
  - Preserves item order when filtering duplicates for uniqueItems

- Schema processing:
  - Extracts constraints from schema including minItems, maxItems, and uniqueItems
  - Validates items against 'items' schema property
  - Handles prefixItems and contains constraints
  - Supports tuple validation with different schemas per position

**uniqueItems behavior:**
When `uniqueItems` is true, duplicates are filtered while preserving the order of first occurrence:
```python
# Array with unique items constraint
unique_array_sm = ArraySchemaStateMachine(
    schema={
        "type": "array",
        "items": {"type": "number"},
        "uniqueItems": True
    },
    context={}
)

# This would only allow [1, 2, 3], not [1, 2, 1, 3]
```

**Advanced constraints example:**
```python
# Array with multiple constraints
complex_array_sm = ArraySchemaStateMachine(
    schema={
        "type": "array",
        "items": {
            "type": "object",
            "properties": {
                "id": {"type": "string"},
                "value": {"type": "number"}
            },
            "required": ["id"]
        },
        "minItems": 1,
        "maxItems": 10,
        "uniqueItems": True
    },
    context={"path": "root"}
)
```

**Integration with other state machines:**
```python
# Nested structure with arrays inside objects
nested_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "tags": {
            "type": "array",
            "items": {"type": "string"},
            "uniqueItems": True
        },
        "scores": {
            "type": "array",
            "items": {"type": "number"},
            "minItems": 3
        }
    },
    "required": ["name", "scores"]
}

# The object state machine will automatically use ArraySchemaStateMachine
# for the array properties
nested_sm = ObjectSchemaStateMachine(nested_schema, {})
```

### AnySchemaStateMachine

`AnySchemaStateMachine` provides a powerful way to create state machines from complex JSON Schemas with logical composition operators.

```python
from pse.types.json.any_json_schema import AnySchemaStateMachine

# Define a complex schema with different types using oneOf
complex_schema = {
    "oneOf": [
        {"type": "string"},
        {"type": "number"},
        {
            "type": "object",
            "properties": {
                "status": {"type": "string", "enum": ["success", "error"]},
                "data": {"type": "object"}
            },
            "required": ["status"]
        }
    ]
}

# Create a state machine for the complex schema
complex_sm = AnySchemaStateMachine(
    schemas=[  # Usually derived from the oneOf array
        {"type": "string"},
        {"type": "number"},
        {
            "type": "object",
            "properties": {
                "status": {"type": "string", "enum": ["success", "error"]},
                "data": {"type": "object"}
            },
            "required": ["status"]
        }
    ],
    context={}
)
```

**Implementation details:**
- Parameters:
  - `schemas`: List of JSON Schema objects to validate against
  - `context`: Context for schema resolution containing refs and path information
  
- State machine structure:
  - Creates individual state machines for each schema
  - Constructs transitions from the initial state to each schema state machine
  - Accepts if any schema path reaches an accept state

- Parallel path exploration:
  - Maintains multiple steppers to validate against different schemas simultaneously
  - Returns the first successfully validated value
  - Only fails if all schema paths fail to validate
  - Preserves the correctly typed value for the matching schema

**JSON Schema logical composition:**
`AnySchemaStateMachine` is used internally for handling JSON Schema's logical composition operators:

```python
# These schema patterns are automatically processed using AnySchemaStateMachine
schema1 = {
    "oneOf": [  # Must match exactly one schema
        {"type": "string"},
        {"type": "number"}
    ]
}

schema2 = {
    "anyOf": [  # Can match any number of schemas
        {"type": "string"},
        {"type": "number"}
    ]
}

schema3 = {
    "type": ["string", "number"]  # Union type (string OR number)
}

schema4 = {
    "type": "string",
    "nullable": True  # String OR null
}
```

**Usage for complex schema validation:**
```python
# Create a state machine for a payment method schema
payment_method_sm = AnySchemaStateMachine(
    schemas=[
        {  # Credit card schema
            "type": "object",
            "properties": {
                "type": {"type": "string", "enum": ["credit_card"]},
                "card_number": {"type": "string", "pattern": "^[0-9]{16}$"},
                "expiration": {"type": "string", "pattern": "^[0-9]{2}/[0-9]{2}$"},
                "cvv": {"type": "string", "pattern": "^[0-9]{3,4}$"}
            },
            "required": ["type", "card_number", "expiration", "cvv"]
        },
        {  # Bank transfer schema
            "type": "object",
            "properties": {
                "type": {"type": "string", "enum": ["bank_transfer"]},
                "account_number": {"type": "string"},
                "routing_number": {"type": "string"}
            },
            "required": ["type", "account_number", "routing_number"]
        },
        {  # Digital wallet schema
            "type": "object",
            "properties": {
                "type": {"type": "string", "enum": ["digital_wallet"]},
                "provider": {"type": "string", "enum": ["paypal", "venmo", "apple_pay"]},
                "email": {"type": "string", "format": "email"}
            },
            "required": ["type", "provider", "email"]
        }
    ],
    context={"path": "payment_method"}
)
```

**Performance considerations:**
- Shares the token processing pipeline across all paths to minimize overhead
- Designed for efficient exploration of multiple potential schema matches
- Automatically prunes invalid paths as tokens are processed

## XML State Machines

PSE includes state machines for working with XML data.

### XMLTagStateMachine

`XMLTagStateMachine` parses XML opening and closing tags with a specific tag name.

```python
from pse.types.xml.xml_tag import XMLTagStateMachine

# Create an XML opening tag state machine with a specific tag name
person_tag_sm = XMLTagStateMachine(tag_name="person")

# Create an XML closing tag state machine
person_closing_tag_sm = XMLTagStateMachine(tag_name="person", closing_tag=True)
```

**Implementation details:**
- Parameters:
  - `tag_name`: The name of the XML tag to match (required)
  - `closing_tag`: Boolean flag to indicate if it's a closing tag (default: False)
  
- Internal structure:
  - Inherits from `ChainStateMachine`
  - Creates a chain of `PhraseStateMachine` instances that match parts of the tag:
    1. Opening delimiter: `<` for normal tags, `</` for closing tags
    2. The tag name itself
    3. Closing delimiter: `>`
  
- Custom stepper behavior:
  - Implements `XMLTagStepper` that extends `ChainStepper`
  - Overrides `get_valid_continuations()` to return the complete tag as a single valid continuation
  - Ensures proper tag name matching with exact case sensitivity

**Usage notes:**
- Currently focused on basic tag recognition without attributes
- Does not support self-closing tags (e.g., `<br/>`)
- Whitespace is not allowed within tags
- Used as a building block for `XMLEncapsulatedStateMachine`

**Simple example:**
```python
from pse.types.xml.xml_tag import XMLTagStateMachine

# Match a specific opening tag
h1_tag_sm = XMLTagStateMachine(tag_name="h1")

# This will match "<h1>" but not "<h2>" or "<H1>"
```

### XMLEncapsulatedStateMachine

`XMLEncapsulatedStateMachine` handles complete XML elements with content between matching tags.

```python
from pse.types.xml.xml_encapsulated import XMLEncapsulatedStateMachine
from pse.types.base.phrase import PhraseStateMachine

# Create an XML element with text content
text_element_sm = XMLEncapsulatedStateMachine(
    tag_name="p",  # XML tag name
    state_machine=PhraseStateMachine("Hello world"),  # Content state machine
    min_buffer_length=-1,  # Minimum buffer length (default: -1)
    is_optional=False  # Whether the element is optional (default: False)
)
```

**Implementation details:**
- Parameters:
  - `tag_name`: Name of the XML tag (required)
  - `state_machine`: The inner state machine that processes content between tags (required)
  - `min_buffer_length`: Minimum buffer length before attempting to match (default: -1)
  - `is_optional`: Whether the element is optional (default: False)
  
- State graph structure:
  - State 0: Uses `WaitFor` with `XMLTagStateMachine` to find opening tag
  - State 1: Processes content using the provided inner state machine
  - State 2: Looks for closing tag using `XMLTagStateMachine` with closing_tag=True
  
- Custom stepper behavior:
  - Uses `EncapsulatedStepper` for tracking buffer and inner state
  - Maintains proper nesting by requiring matching opening and closing tags
  - Returns validated content from between the tags

**Complex content example:**
```python
from pse.types.xml.xml_encapsulated import XMLEncapsulatedStateMachine
from pse.types.json.json_value import JsonStateMachine

# XML element containing JSON content
json_in_xml_sm = XMLEncapsulatedStateMachine(
    tag_name="data",
    state_machine=JsonStateMachine()
)

# This will match: <data>{"key": "value"}</data>
```

**Nested XML elements:**
```python
from pse.types.xml.xml_encapsulated import XMLEncapsulatedStateMachine
from pse.types.base.chain import ChainStateMachine
from pse.types.base.phrase import PhraseStateMachine

# Create a nested XML structure for HTML-like content
paragraph_sm = XMLEncapsulatedStateMachine(
    tag_name="p",
    state_machine=PhraseStateMachine("Sample text")
)

# A div containing a paragraph
div_with_paragraph_sm = XMLEncapsulatedStateMachine(
    tag_name="div",
    state_machine=paragraph_sm
)

# This will match: <div><p>Sample text</p></div>
```

**Optional XML element:**
```python
from pse.types.xml.xml_encapsulated import XMLEncapsulatedStateMachine
from pse.types.base.phrase import PhraseStateMachine

# Optional XML element
optional_element_sm = XMLEncapsulatedStateMachine(
    tag_name="optional",
    state_machine=PhraseStateMachine("Some content"),
    is_optional=True
)

# Will match both "<optional>Some content</optional>" and empty string
```

## Grammar State Machines

PSE provides state machines for parsing according to formal grammars.

### LarkGrammarStateMachine

`LarkGrammarStateMachine` implements a character-based parser that validates input against Lark grammar definitions.

```python
from pse.types.grammar.lark import LarkGrammarStateMachine, LarkGrammar
from lark import Lark

# Create a LarkGrammar implementation for arithmetic expressions
class ArithmeticGrammar(LarkGrammar):
    def __init__(self):
        # Define a simple grammar for arithmetic expressions
        arithmetic_parser = Lark("""
            expr: term (op term)*
            term: NUMBER | "(" expr ")"
            op: "+" | "-" | "*" | "/"
            NUMBER: /[0-9]+/

            %import common.WS
            %ignore WS
        """)
        
        super().__init__(
            name="Arithmetic",
            lark_grammar=arithmetic_parser,
            delimiters=None  # No special delimiters
        )

# Create a state machine from the grammar
arithmetic_sm = LarkGrammarStateMachine(ArithmeticGrammar())
```

**Implementation details:**
- Parameters:
  - `grammar`: A `LarkGrammar` instance that encapsulates the Lark parser and validation logic
  
- Internal structure:
  - Extends `CharacterStateMachine` with minimum character requirement of 1
  - Uses the provided `LarkGrammar` for token validation
  - Maintains a character buffer for incremental validation
  
- Custom stepper behavior:
  - `LarkGrammarStepper` extends `CharacterStepper`
  - Validates input incrementally using the grammar's `validate` method
  - Handles partial inputs through non-strict validation mode
  - Properly tracks state between token processing steps

**Validation modes:**
- Strict mode: Requires complete, syntactically valid input
- Non-strict mode: Allows partial inputs that could potentially be completed into valid syntax

**Example with delimiters:**
```python
from pse.types.grammar.lark import LarkGrammarStateMachine, LarkGrammar
from lark import Lark

# Create a LarkGrammar with markdown-style delimiters
class SQLGrammar(LarkGrammar):
    def __init__(self):
        sql_parser = Lark("""
            query: select_stmt
            select_stmt: "SELECT" columns "FROM" table
            columns: column ("," column)*
            column: CNAME | "*"
            table: CNAME
            
            %import common.CNAME
            %import common.WS
            %ignore WS
        """)
        
        super().__init__(
            name="SQL",
            lark_grammar=sql_parser,
            delimiters=("```sql\n", "\n```")  # Markdown-style delimiters
        )

# Create state machine with SQL grammar
sql_sm = LarkGrammarStateMachine(SQLGrammar())

# This will match:
# ```sql
# SELECT id, name FROM users
# ```
```

**Creating custom grammar implementations:**
```python
from lark import Lark
from pse.types.grammar.lark import LarkGrammar, LarkGrammarStateMachine

class CustomGrammar(LarkGrammar):
    def __init__(self):
        # Define your custom grammar
        my_grammar = Lark("""
            # Your grammar rules here
        """)
        
        super().__init__(
            name="MyGrammar",
            lark_grammar=my_grammar,
            delimiters=None
        )
    
    def validate(self, input: str, strict: bool = False, start: str | None = None) -> bool:
        # Customize validation logic if needed
        try:
            self.lark_grammar.parse(input, start=start)
            return True
        except Exception:
            if not strict:
                # Custom logic for partial inputs
                # Return True if the partial input could be valid
                pass
            return False

# Create a state machine with the custom grammar
custom_sm = LarkGrammarStateMachine(CustomGrammar())
```

**Integration with other state machines:**
```python
from pse.types.base.encapsulated import EncapsulatedStateMachine
from pse.types.grammar.lark import LarkGrammarStateMachine
from pse.types.grammar.default_grammars.python import PythonGrammar

# Create a state machine for code blocks containing Python code
python_code_block = EncapsulatedStateMachine(
    left_delimiter="```python\n",
    right_delimiter="\n```",
    state_machine=LarkGrammarStateMachine(PythonGrammar())
)
```

### PythonStateMachine

`PythonStateMachine` is a pre-configured instance of `LarkGrammarStateMachine` that specializes in parsing valid Python code.

```python
from pse.types.grammar.default_grammars.python import PythonStateMachine

# Use the pre-configured Python state machine
python_sm = PythonStateMachine

# Use with encapsulation for markdown-style code blocks
from pse.types.base.encapsulated import EncapsulatedStateMachine
python_block_sm = EncapsulatedStateMachine(
    state_machine=PythonStateMachine,
    left_delimiter="```python\n",
    right_delimiter="\n```"
)
```

**Implementation details:**
- Based on `LarkGrammarStateMachine` using a specialized `PythonGrammar` class
- Uses a comprehensive Lark grammar file (`python.lark`) that covers Python 3.x syntax
- Employs a custom Python indentation handler for proper handling of indentation-sensitive code
- Default delimiters for markdown-style code blocks: `"```python\n"` and `"\n```"`
- Implements special validation logic for Python syntax

**Python-specific validation features:**
- Intelligent handling of incomplete code during generation
- Special processing for indent/dedent tokens
- Proper handling of unclosed quotes, brackets, and parentheses
- Support for all Python syntax including:
  - Function and class definitions
  - Control flow statements
  - List/dict/set comprehensions
  - Async/await syntax
  - Type annotations
  - Decorators and lambda expressions

**Example: Python code validation**
```python
from pse.types.grammar.default_grammars.python import PythonStateMachine

# Parse a simple Python function
code = """
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n-1)
"""

# Get steppers and advance through the code
steppers = PythonStateMachine.get_steppers()
for char in code:
    steppers = PythonStateMachine.advance_all_steppers(steppers, char)

# Check if any stepper successfully parsed the code
valid = any(s.has_reached_accept_state() for s in steppers)
```

**Example: Integration with structuring engine**
```python
from pse import StructuringEngine
from pse.types.grammar.default_grammars.python import PythonStateMachine
from pse.types.base.encapsulated import EncapsulatedStateMachine

# Create a Python code block parser
python_block = EncapsulatedStateMachine(
    state_machine=PythonStateMachine,
    left_delimiter="```python\n",
    right_delimiter="\n```"
)

# Create structuring engine with the Python block state machine
engine = StructuringEngine().configure(python_block)

# Generate code with LLM
response = engine.generate("Write a function to calculate the Fibonacci sequence", model="claude-3-sonnet-20240229")
```

**Example: Partial code validation during generation**
```python
from pse.types.grammar.default_grammars.python import PythonStateMachine

# Even incomplete code is accepted during non-strict validation
incomplete_code = "def factorial(n):\n    if n <= 1:"
steppers = PythonStateMachine.get_steppers()
steppers = PythonStateMachine.advance_all_steppers(steppers, incomplete_code)

# Steppers remain valid for incomplete but syntactically correct code
assert len(steppers) > 0
```

### BashStateMachine

`BashStateMachine` is a pre-configured instance of `LarkGrammarStateMachine` that specializes in parsing and generating Bash shell code.

```python
from pse.types.grammar.default_grammars.bash import BashStateMachine

# Use the pre-configured Bash state machine
bash_sm = BashStateMachine

# Use with encapsulation for markdown-style code blocks
from pse.types.base.encapsulated import EncapsulatedStateMachine
bash_block_sm = EncapsulatedStateMachine(
    state_machine=BashStateMachine,
    left_delimiter="```bash\n",
    right_delimiter="\n```"
)
```

**Implementation details:**
- Based on `LarkGrammarStateMachine` using a specialized `BashGrammar` class
- Uses a comprehensive Lark grammar file (`bash.lark`) that covers Bash shell syntax
- Default delimiters for markdown-style code blocks: `"```bash\n"` and `"\n```"`
- Implements special validation logic for Bash-specific syntax structures

**Bash-specific validation features:**
- Intelligent handling of incomplete commands during generation
- Special processing for unclosed quotes and control structures
- Support for all Bash syntax including:
  - Control flow (if/then/else, for/while/until loops, case statements)
  - Variables and parameter expansion (`$var`, `${var}`)
  - Command substitution (`$(command)`) and subshells
  - I/O redirections (`>`, `>>`, `<`, `2>&1`, etc.)
  - Function definitions
  - Arithmetic expressions (`$(( expr ))`)
  - Comments and shebangs

**Example: Bash script validation**
```python
from pse.types.grammar.default_grammars.bash import BashStateMachine

# Parse a simple Bash script
script = """
#!/bin/bash

function greet() {
    local name=$1
    echo "Hello, $name!"
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <name>"
    exit 1
fi

greet $1
"""

# Check if the script is valid
is_valid = BashStateMachine.grammar.validate(script, strict=True)
```

**Example: Integration with structuring engine**
```python
from pse import StructuringEngine
from pse.types.grammar.default_grammars.bash import BashStateMachine
from pse.types.base.encapsulated import EncapsulatedStateMachine

# Create a Bash code block parser
bash_block = EncapsulatedStateMachine(
    state_machine=BashStateMachine,
    left_delimiter="```bash\n",
    right_delimiter="\n```"
)

# Create structuring engine with the Bash block state machine
engine = StructuringEngine().configure(bash_block)

# Generate shell script with LLM
response = engine.generate(
    "Write a Bash script to find the largest files in a directory", 
    model="claude-3-sonnet-20240229"
)
```

**Example: Handling incomplete Bash code**
```python
from pse.types.grammar.default_grammars.bash import BashStateMachine

# Incomplete code that's syntactically valid so far
incomplete_code = "if [ -f /etc/passwd ]; then\n  grep 'root' /etc/passwd"

# In non-strict mode, this should be accepted
is_valid_partial = BashStateMachine.grammar.validate(incomplete_code, strict=False)
assert is_valid_partial  # True

# In strict mode, this would be rejected
is_valid_strict = BashStateMachine.grammar.validate(incomplete_code, strict=True)
assert not is_valid_strict  # False
```

**Performance considerations:**
- Parses Bash syntax incrementally, providing good performance
- Uses efficient path pruning to avoid exploring invalid syntax paths
- Handles complex scripts including nested structures
- Token healing enables recovery from minor syntax errors

## Mixed-Content State Machines

PSE includes state machines for handling mixed content formats.

### FencedFreeformStateMachine

`FencedFreeformStateMachine` allows free-form text between specific delimiters, functioning as an enhanced version of `EncapsulatedStateMachine` that accepts any character content.

```python
from pse.types.misc.fenced_freeform import FencedFreeformStateMachine

# Create a state machine that captures content between markdown-style fences
python_block_sm = FencedFreeformStateMachine(
    identifier="python",  # Specifies fence type (becomes ```python\n and \n```)
)

# Create a state machine with custom delimiters
custom_block_sm = FencedFreeformStateMachine(
    delimiters=("<START>", "<END>"),  # Custom opening and closing delimiters
    char_min=10,  # Minimum content length
    char_max=1000,  # Maximum content length
    is_optional=False  # Whether the content is required
)
```

**Implementation details:**
- Parameters:
  - `identifier`: Optional language identifier (e.g., "python" produces ```python\n and \n``` fences)
  - `delimiters`: Tuple of opening and closing delimiters (overrides identifier-based fences)
  - `char_min`: Minimum number of characters required (default: 0)
  - `char_max`: Maximum number of characters allowed (default: None)
  - `buffer_length`: Controls character buffer size during processing (default: 32768)
  - `is_optional`: Whether the content is optional (default: False)
  
- Internal structure:
  - Extends `EncapsulatedStateMachine` with freeform character acceptance
  - Uses `CharacterStateMachine` internally with a whitelist containing all characters
  - Maintains character counting to enforce min/max constraints
  - Provides a `FencedFreeformStepper` for controlling character processing
  
- Fence behavior:
  - With identifier: Uses markdown-style code fences (```<identifier>\n and \n```)
  - With delimiters: Uses the provided custom delimiters
  - Both can be set to customize fence appearance

**Usage examples:**

**Example: Empty opening delimiter (capture immediately)**
```python
from pse.types.misc.fenced_freeform import FencedFreeformStateMachine

# Create a state machine that accepts arbitrary content until a specific pattern
until_marker_sm = FencedFreeformStateMachine(
    delimiters=("", "END_OF_CONTENT"),  # Start capturing right away, end at marker
)

# This will match any text until "END_OF_CONTENT" is encountered
```

**Example: Character limits**
```python
from pse.types.misc.fenced_freeform import FencedFreeformStateMachine

# Create a state machine for short descriptions (10-50 characters)
description_sm = FencedFreeformStateMachine(
    delimiters=("<desc>", "</desc>"),
    char_min=10,
    char_max=50
)

# This enforces both minimum and maximum length constraints
```

**Example: Integration with other state machines**
```python
from pse import StructuringEngine
from pse.types.misc.fenced_freeform import FencedFreeformStateMachine

# Create a markdown state machine for code blocks
code_block_sm = FencedFreeformStateMachine(identifier="python")

# Configure a document with both structure and freeform content
engine = StructuringEngine().configure(
    {
        "type": "object",
        "properties": {
            "title": {"type": "string"},
            "description": {"type": "string"},
            "code_example": {"type": "string", "contentMediaType": "text/x-python"}
        }
    },
    fenced_type_mapping={"text/x-python": code_block_sm}
)

# The result will be a document with structured fields and a fenced code block
```

**Common applications:**
- Markdown-style code blocks in documentation
- Processing custom template languages
- Extracting specific sections from text
- Allowing structured and unstructured content in the same document
- Creating custom delimited content regions