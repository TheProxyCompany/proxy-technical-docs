# Data Type State Machines

PSE provides specialized state machines for handling common data types, allowing precise control over the format and content of generated values.

## StringStateMachine

`StringStateMachine` handles JSON-style string parsing with double quotation marks and proper escaping of special characters.

```python
from pse.types.string import StringStateMachine

# Create a basic string state machine that matches quoted strings like "hello"
string_sm = StringStateMachine()

# Create a string state machine with length constraints
constrained_string_sm = StringStateMachine(
    min_length=3,  # Minimum string length (excluding quotes)
    max_length=50  # Maximum string length (excluding quotes)
)
```

**Implementation details:**
- State machine structure:
  - Initial state (0): Expects opening double quote (")
  - String contents state (1): Processes regular characters
  - Escape sequence state (2): Handles escape sequences
  - Unicode escape state (3): Processes \uXXXX Unicode escapes

- Escape sequence handling:
  - Standard JSON escape sequences: \", \\, \/, \b, \f, \n, \r, \t
  - Unicode escape sequences: \uXXXX (4 hex digits)
  - Automatically rejects invalid escape sequences

- Character handling:
  - Properly validates all string content
  - Automatically rejects control characters that must be escaped
  - Maintains proper JSON string compliance

**StringSchemaStateMachine extension**:
For JSON Schema integration, the StringSchemaStateMachine adds pattern and format validation:

```python
from pse.types.json.json_string import StringSchemaStateMachine

# Create a string state machine with JSON Schema constraints
email_string_sm = StringSchemaStateMachine(
    schema={"type": "string", "format": "email"},
    context={}
)

# Create a string state machine with pattern validation
pattern_string_sm = StringSchemaStateMachine(
    schema={"type": "string", "pattern": "^[A-Z]{2}-\\d{4}$"},  # Format like "AB-1234"
    context={}
)
```

**Example: String with escape sequences**
```python
from pse.types.string import StringStateMachine

# Define a string state machine
string_sm = StringStateMachine()

# This will match: "Hello\nWorld" and correctly handle the newline
# The value returned will be the string without quotes: Hello\nWorld
```

**Example: Unicode handling**
```python
from pse.types.string import StringStateMachine

# Define a string state machine
string_sm = StringStateMachine()

# This will match: "Hello\u0057orld" and correctly interpret it as "HelloWorld"
# This also matches: "Hello 世界" as Unicode is supported via direct inclusion or escapes
```

**Example: Length validation**
```python
from pse.types.string import StringStateMachine

# Create a string state machine with length constraints
username_sm = StringStateMachine(min_length=3, max_length=20)

# This will match: "user123"
# This will not match: "a" (too short)
# This will not match: "this_username_is_way_too_long" (too long)
```

## NumberStateMachine

`NumberStateMachine` parses JSON-compliant numeric values, handling integers, decimals, and scientific notation.

```python
from pse.types.number import NumberStateMachine

# Create a basic number state machine for all numeric formats
number_sm = NumberStateMachine()
```

**Implementation details:**
- State machine structure:
  - State 0: Starting state that optionally accepts a negative sign (-)
  - State 1: Expects an integer part (mandatory)
  - State 2: Accept state for integers, can also transition to decimal part
  - State 3: Decimal part state (after the decimal point), also an accept state
  - State 4: Exponential notation marker 'e' or 'E'
  - State 5: Optional sign for the exponent (+ or -)
  - Final state: Exponent integer value, if present

- Decimal handling:
  - Properly handles decimal points followed by integer part
  - Maintains leading zeros after decimal point (e.g., 0.001)
  - Validates full decimal number structure

- Scientific notation:
  - Supports 'e' or 'E' notation (e.g., 1.5e3, 2E-4)
  - Handles optional sign in exponent
  - Properly combines base number with exponent for final value

**NumberSchemaStateMachine extension**:
For JSON Schema integration, use the NumberSchemaStateMachine to add validation constraints:

```python
from pse.types.json.json_number import NumberSchemaStateMachine

# Create a number state machine with JSON Schema constraints
constrained_number_sm = NumberSchemaStateMachine(
    schema={
        "type": "number",
        "minimum": 0,
        "maximum": 100,
        "exclusiveMaximum": True
    },
    context={}
)

# Create an integer-only state machine
integer_number_sm = NumberSchemaStateMachine(
    schema={
        "type": "integer",
        "multipleOf": 5
    },
    context={}
)
```

**Example: Basic number parsing**
```python
from pse.types.number import NumberStateMachine

# Define a number state machine
number_sm = NumberStateMachine()

# This will match: "42" (integer)
# This will match: "-3.14" (negative decimal)
# This will match: "1.618e2" (scientific notation, equal to 161.8)
```

**Example: JSON Schema validation**
```python
from pse.types.json.json_number import NumberSchemaStateMachine

# Define a number state machine with constraints
temperature_sm = NumberSchemaStateMachine(
    schema={
        "type": "number",
        "minimum": -273.15,  # Absolute zero in Celsius
        "maximum": 1000
    },
    context={}
)

# This will match: "25.5" (valid temperature)
# This will not match: "-300" (below absolute zero)
# This will not match: "1200" (above maximum)
```

**Example: Integer validation**
```python
from pse.types.json.json_number import NumberSchemaStateMachine

# Define an integer state machine with constraints
page_number_sm = NumberSchemaStateMachine(
    schema={
        "type": "integer",
        "minimum": 1
    },
    context={}
)

# This will match: "42" (valid page number)
# This will not match: "2.5" (not an integer)
# This will not match: "0" (below minimum)
```

## IntegerStateMachine

`IntegerStateMachine` is a specialized state machine for parsing positive integer values with configurable handling of leading zeros.

```python
from pse.types.integer import IntegerStateMachine

# Create a basic integer state machine
int_sm = IntegerStateMachine()

# Create an integer state machine that preserves leading zeros
raw_int_sm = IntegerStateMachine(drop_leading_zeros=False)
```

**Implementation details:**
- Extends CharacterStateMachine with digit characters (0-9)
- Only accepts positive integers (no negative sign support)
- By default, removes leading zeros and returns an int value
- When drop_leading_zeros=False, preserves the original string representation

**Example: Basic integer parsing**
```python
from pse.types.integer import IntegerStateMachine

# Define an integer state machine
int_sm = IntegerStateMachine()

# This will match: "42" -> 42 (int)
# This will match: "007" -> 7 (int, leading zeros removed)
# This will not match: "-5" (negative not supported)
# This will not match: "3.14" (decimals not supported)
```

**Example: Preserving leading zeros**
```python
from pse.types.integer import IntegerStateMachine

# Create an integer state machine that preserves leading zeros
raw_int_sm = IntegerStateMachine(drop_leading_zeros=False)

# This will match: "42" -> "42" (string)
# This will match: "007" -> "007" (string, leading zeros preserved)
# This will not match: "-5" (negative not supported)
# This will not match: "3.14" (decimals not supported)
```

**Note:** For more complex integer requirements (negative numbers, range validation), use `NumberSchemaStateMachine` with a JSON Schema:

```python
from pse.types.json.json_number import NumberSchemaStateMachine

# Create a state machine for integers with validation constraints
integer_sm = NumberSchemaStateMachine(
    schema={
        "type": "integer",
        "minimum": 1,
        "maximum": 1000
    },
    context={}
)
```

## BooleanStateMachine

`BooleanStateMachine` parses JSON-compliant boolean literals ("true"/"false").

```python
from pse.types.boolean import BooleanStateMachine

# Create a boolean state machine
bool_sm = BooleanStateMachine()
```

**Implementation details:**
- State machine structure:
  - Initial state (0): Expects exact match of "true" or "false" literals
  - Uses PhraseStateMachine for exact string matching
  - Transitions directly to accept states with corresponding boolean values
  - Returns Python `True` or `False` values

- JSON compliance:
  - Strictly case-sensitive (only "true"/"false", not "True"/"FALSE")
  - No whitespace allowed (unlike some other PSE state machines)
  - No partial matches or extra characters permitted

**Example: Boolean parsing**
```python
from pse.types.boolean import BooleanStateMachine

# Define a boolean state machine
bool_sm = BooleanStateMachine()

# This will match: "true" -> True (Python bool)
# This will match: "false" -> False (Python bool)
# This will not match: "True" (incorrect case)
# This will not match: " true" (has whitespace)
# This will not match: "truthy" (extra characters)
```

**Integration example:**
```python
from pse.types.boolean import BooleanStateMachine
from pse.types.json.json_object import ObjectSchemaStateMachine

# Using boolean state machine inside a JSON object
settings_sm = ObjectSchemaStateMachine(
    schema={
        "type": "object",
        "properties": {
            "enabled": {"type": "boolean"},
            "notifications": {"type": "boolean"}
        }
    },
    context={}
)

# This will match: {"enabled": true, "notifications": false}
```

## ArrayStateMachine

`ArrayStateMachine` handles JSON array structures, processing sequences of elements enclosed in square brackets.

```python
from pse.types.array import ArrayStateMachine

# Create a basic array state machine for JSON arrays
array_sm = ArrayStateMachine()
```

**Implementation details:**
- State machine structure:
  - State 0: Initial state that accepts opening bracket "["
  - State 1: Whitespace handling or immediate closing bracket for empty arrays
  - State 2: Value state that uses JsonStateMachine to parse elements
  - State 3: Whitespace handling after each value
  - State 4: Decision point (comma for next item or "]" to close array)

- Array validation:
  - Enforces proper structure with opening/closing brackets
  - Ensures comma-separated values with no trailing commas
  - Properly validates nested array structures
  - Supports whitespace between array elements and brackets

- Value collection:
  - Uses ArrayStepper to track parsed values
  - Maintains immutability by cloning steppers during processing
  - Returns a list of parsed JSON values

**ArraySchemaStateMachine extension**:
For JSON Schema integration and type-specific arrays, use ArraySchemaStateMachine:

```python
from pse.types.json.json_array import ArraySchemaStateMachine

# Create a typed array state machine for arrays of strings
string_array_sm = ArraySchemaStateMachine(
    schema={
        "type": "array",
        "items": {"type": "string"}
    },
    context={}
)

# Create an array with length constraints and unique items
constrained_array_sm = ArraySchemaStateMachine(
    schema={
        "type": "array",
        "items": {"type": "number"},
        "minItems": 1,
        "maxItems": 5,
        "uniqueItems": True
    },
    context={}
)
```

**Example: Basic array parsing**
```python
from pse.types.array import ArrayStateMachine

# Define an array state machine
array_sm = ArrayStateMachine()

# This will match: "[]" -> [] (empty array)
# This will match: "[1, 2, 3]" -> [1, 2, 3] (array of numbers)
# This will match: '["a", "b", "c"]' -> ["a", "b", "c"] (array of strings)
# This will match: '[true, false]' -> [True, False] (array of booleans)
```

**Example: Nested array parsing**
```python
from pse.types.array import ArrayStateMachine

# Define an array state machine
array_sm = ArrayStateMachine()

# This will match: "[[1, 2], [3, 4]]" -> [[1, 2], [3, 4]] (nested array)
# This will match: '[{"a": 1}, {"b": 2}]' -> [{"a": 1}, {"b": 2}] (array of objects)
```

**Example: Schema validation**
```python
from pse.types.json.json_array import ArraySchemaStateMachine

# Create a schema-enforced array of integers
integers_array_sm = ArraySchemaStateMachine(
    schema={
        "type": "array",
        "items": {"type": "integer"},
        "minItems": 2
    },
    context={}
)

# This will match: "[1, 2, 3]" -> [1, 2, 3]
# This will not match: "[1]" (too few items)
# This will not match: "[1.5, 2]" (non-integer value)
```

## ObjectStateMachine

`ObjectStateMachine` processes JSON object structures, handling key-value pairs enclosed in curly braces.

```python
from pse.types.object import ObjectStateMachine

# Create a basic object state machine
object_sm = ObjectStateMachine()

# Create an object state machine that can be optional (empty objects allowed)
optional_object_sm = ObjectStateMachine(is_optional=True)
```

**Implementation details:**
- State machine structure:
  - State 0: Initial state that accepts opening brace "{"
  - State 1: Whitespace handling after opening brace
  - State 2: Key-value pair processing using KeyValueStateMachine
  - State 3: Whitespace handling after key-value pair
  - State 4: Decision point (comma for next property or "}" to close object)

- Object validation:
  - Enforces proper structure with opening/closing braces
  - Ensures comma-separated properties with no trailing commas
  - Properly handles nested object structures
  - Supports whitespace between properties and braces

- Value collection:
  - Uses ObjectStepper to accumulate key-value pairs in a dictionary
  - Maintains immutability by cloning steppers during processing
  - Returns a dictionary of parsed property values

- Parameters:
  - `is_optional`: When True, allows empty objects (default: False)

**ObjectSchemaStateMachine extension**:
For JSON Schema integration and property validation, use ObjectSchemaStateMachine:

```python
from pse.types.json.json_object import ObjectSchemaStateMachine

# Create a schema-based object state machine
person_object_sm = ObjectSchemaStateMachine(
    schema={
        "type": "object",
        "properties": {
            "name": {"type": "string"},
            "age": {"type": "integer", "minimum": 0},
            "email": {"type": "string", "format": "email"}
        },
        "required": ["name", "email"]
    },
    context={}
)
```

**Example: Basic object parsing**
```python
from pse.types.object import ObjectStateMachine

# Define an object state machine
object_sm = ObjectStateMachine()

# This will match: "{}" -> {} (empty object, only if is_optional=True)
# This will match: '{"a": 1}' -> {"a": 1} (simple object)
# This will match: '{"name": "Alice", "age": 30}' -> {"name": "Alice", "age": 30} (multiple properties)
```

**Example: Nested object parsing**
```python
from pse.types.object import ObjectStateMachine

# Define an object state machine
object_sm = ObjectStateMachine()

# This will match complex nested objects:
# {
#   "user": {
#     "name": "Alice",
#     "address": {
#       "city": "New York",
#       "zip": "10001"
#     }
#   }
# }
```

**Example: Working with object values**
```python
from pse.types.object import ObjectStateMachine

object_sm = ObjectStateMachine()
input_str = '{"a": 1, "b": true, "c": "hello"}'

# Parse the object string
steppers = object_sm.get_steppers()
for char in input_str:
    steppers = object_sm.advance_all_steppers(steppers, char)

# Get the parsed object from the first valid stepper
if steppers:
    parsed_object = steppers[0].value  # {"a": 1, "b": True, "c": "hello"}

    # Access individual properties
    value_a = parsed_object["a"]  # 1
```

## KeyValueStateMachine

`KeyValueStateMachine` handles JSON key-value pairs within objects, processing the structure of `"key": value`.

```python
from pse.types.key_value import KeyValueStateMachine

# Create a basic key-value pair state machine
kv_sm = KeyValueStateMachine()

# Create an optional key-value pair state machine
optional_kv_sm = KeyValueStateMachine(is_optional=True)
```

**Implementation details:**
- State machine structure:
  - By default, uses a sequence of five state machines:
    1. StringStateMachine() for the key
    2. WhitespaceStateMachine() for whitespace after key
    3. PhraseStateMachine(":") for the colon separator
    4. WhitespaceStateMachine() for whitespace after colon
    5. JsonStateMachine() for the value
  - Transitions through each component in sequence
  - Returns a tuple of (key, value) upon successful parsing

- Parameters:
  - `sequence`: Optional customized sequence of state machines (default: as described above)
  - `is_optional`: Whether the key-value pair is optional (default: False)

- Key-value tracking:
  - Uses KeyValueStepper to track property name and value
  - Extracts key using json.loads() to handle quote removal and escaping
  - Value is processed by JsonStateMachine and can be any valid JSON type
  - Maintains immutability through proper stepper cloning

**Example: Basic key-value parsing**
```python
from pse.types.key_value import KeyValueStateMachine

# Define a key-value state machine
kv_sm = KeyValueStateMachine()

# This will match: '"name": "Alice"' -> ("name", "Alice")
# This will match: '"age": 30' -> ("age", 30)
# This will match: '"active": true' -> ("active", True)
# This will match: '"data": {"x": 1, "y": 2}' -> ("data", {"x": 1, "y": 2})
```

**Example: Using key-value pairs in objects**
```python
from pse.types.object import ObjectStateMachine
from pse.types.key_value import KeyValueStateMachine

# ObjectStateMachine uses KeyValueStateMachine internally
object_sm = ObjectStateMachine()

# This uses KeyValueStateMachine to parse each property
input_str = '{"name": "Alice", "age": 30}'

steppers = object_sm.get_steppers()
for char in input_str:
    steppers = object_sm.advance_all_steppers(steppers, char)

# Result is a dictionary built from key-value pairs
result = steppers[0].value  # {"name": "Alice", "age": 30}
```

**KeyValueSchemaStateMachine extension**:
For JSON Schema validation of property pairs, the schema-aware extension provides additional validation:

```python
from pse.types.json.json_key_value import KeyValueSchemaStateMachine

# Create a schema-validated key-value pair
email_property_sm = KeyValueSchemaStateMachine(
    property_name="email",
    property_schema={"type": "string", "format": "email"},
    context={},
    required=True
)

# This will match: '"email": "user@example.com"'
# This will not match: '"email": 123' (invalid type)
# This will not match: '"email": "invalid"' (invalid format)
```

## WhitespaceStateMachine

`WhitespaceStateMachine` handles whitespace characters (spaces, tabs, newlines, carriage returns) in structured formats.

```python
from pse.types.whitespace import WhitespaceStateMachine

# Create a whitespace state machine with default settings
# This makes whitespace optional (min=0) with a maximum of 20 characters
ws_sm = WhitespaceStateMachine()

# Create a whitespace state machine with specific constraints
required_ws_sm = WhitespaceStateMachine(
    min_whitespace=1,  # Require at least one whitespace character
    max_whitespace=10  # Allow at most 10 whitespace characters
)
```

**Implementation details:**
- State machine structure:
  - Extends CharacterStateMachine with whitespace characters (" \t\n\r")
  - Accepts consecutive whitespace characters up to max_whitespace
  - Becomes optional when min_whitespace is set to 0 (default)
  - Returns the matched whitespace characters as a string

- Parameters:
  - `min_whitespace`: Minimum required whitespace characters (default: 0)
  - `max_whitespace`: Maximum allowed whitespace characters (default: 20)
  - When `min_whitespace=0`, acts as an optional whitespace matcher

- Matching behavior:
  - Greedy matching: consumes as many whitespace characters as possible
  - Stops consuming when encountering non-whitespace characters
  - Successfully validates when at least min_whitespace characters have been consumed
  - Rejects input when more than max_whitespace characters are encountered

**Example: Basic whitespace handling**
```python
from pse.types.whitespace import WhitespaceStateMachine

# Define a whitespace state machine
ws_sm = WhitespaceStateMachine()

# This will match: "" (empty string, since min_whitespace=0)
# This will match: " " (single space)
# This will match: "\t\n  " (mixed whitespace)
# This will not match: "a" (non-whitespace character)
```

**Example: Required whitespace**
```python
from pse.types.whitespace import WhitespaceStateMachine

# Define a whitespace state machine requiring at least one character
required_ws_sm = WhitespaceStateMachine(min_whitespace=1)

# This will not match: "" (empty string)
# This will match: " " (single space)
# This will match: "\t\n  " (mixed whitespace)
```

**Example: Integration with other state machines**
```python
from pse.types.base.chain import ChainStateMachine
from pse.types.base.phrase import PhraseStateMachine
from pse.types.whitespace import WhitespaceStateMachine

# Create a state machine that parses "key = value" format
assignment_sm = ChainStateMachine([
    PhraseStateMachine("key"),         # Match "key"
    WhitespaceStateMachine(),          # Optional whitespace
    PhraseStateMachine("="),           # Match "="
    WhitespaceStateMachine(),          # Optional whitespace
    PhraseStateMachine("value")        # Match "value"
])

# This will match: "key=value"
# This will match: "key = value"
# This will match: "key  =  value"
```

**Common usage in PSE:**
- Handles optional whitespace between tokens in structured formats
- Creates flexible parsers that handle various formatting styles
- Enables human-readable output with proper spacing
- Used extensively in JSON, XML, and other format-specific state machines
