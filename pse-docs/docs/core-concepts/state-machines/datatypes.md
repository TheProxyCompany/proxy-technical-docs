# Data Type State Machines

PSE provides specialized state machines for handling common data types, allowing precise control over the format and content of generated values.

## StringStateMachine

`StringStateMachine` handles string parsing with quotation marks and proper escaping of special characters.

```python
from pse.types.string import StringStateMachine

# Create a basic string state machine that matches quoted strings like "hello"
string_sm = StringStateMachine()

# Create a string state machine with custom options
custom_string_sm = StringStateMachine(
    allow_single_quotes=True,  # Allow 'text' in addition to "text"
    allow_escape_chars=True,   # Support escaped characters like \n, \t, \"
    allow_unicode=True         # Support unicode characters
)
```

**Key features:**
- Handles quoted strings with proper escaping
- Supports both single and double quote styles
- Manages escape sequences correctly
- Captures the string content for further processing

## NumberStateMachine

`NumberStateMachine` parses numeric values including integers, floats, and scientific notation.

```python
from pse.types.number import NumberStateMachine

# Create a basic number state machine for integers and floats
number_sm = NumberStateMachine()

# Create a number state machine with constraints
constrained_number_sm = NumberStateMachine(
    min_value=0,       # Minimum allowed value
    max_value=100,     # Maximum allowed value
    allow_float=True,  # Allow decimal points
    allow_negative=False  # Disallow negative numbers
)
```

**Key features:**
- Parses integers and floating-point numbers
- Supports scientific notation (e.g., 1.2e-5)
- Can enforce minimum and maximum value constraints
- Handles negative numbers and advanced formats

## IntegerStateMachine

`IntegerStateMachine` specializes in parsing integer values with optional constraints.

```python
from pse.types.integer import IntegerStateMachine

# Create an integer state machine
int_sm = IntegerStateMachine()

# Create an integer state machine with range limits
range_int_sm = IntegerStateMachine(
    min_value=1,
    max_value=1000,
    allow_negative=False
)
```

**Key features:**
- Optimized for integer parsing
- Enforces whole number constraints
- Configurable range limits
- More efficient than general number parsing for integers

## BooleanStateMachine

`BooleanStateMachine` parses boolean values (true/false).

```python
from pse.types.boolean import BooleanStateMachine

# Create a boolean state machine
bool_sm = BooleanStateMachine()
```

**Key features:**
- Accepts "true" and "false" literal values
- Case-sensitive by default
- Simple implementation for boolean flags
- Used in JSON and other data formats

## ArrayStateMachine

`ArrayStateMachine` handles array structures with arbitrary elements.

```python
from pse.types.array import ArrayStateMachine
from pse.types.string import StringStateMachine

# Create a basic array state machine for any JSON-compatible values
array_sm = ArrayStateMachine()

# Create a typed array state machine for arrays of strings
string_array_sm = ArrayStateMachine()
string_array_sm.set_item_state_machine(StringStateMachine())
```

**Key features:**
- Parses array-like structures with bracket notation
- Handles empty arrays and arrays with multiple items
- Supports comma separation and optional whitespace
- Can be specialized to arrays of specific types

## ObjectStateMachine

`ObjectStateMachine` processes object structures with properties and values.

```python
from pse.types.object import ObjectStateMachine
from pse.types.string import StringStateMachine
from pse.types.number import NumberStateMachine

# Create a basic object state machine
object_sm = ObjectStateMachine()

# Add property specifications (in derived implementations)
# object_sm.add_property("name", StringStateMachine())
# object_sm.add_property("age", NumberStateMachine())
```

**Key features:**
- Parses object structures with curly brace notation
- Manages property names and their corresponding values
- Supports nested objects and complex structures
- Can enforce required properties and value constraints

## KeyValueStateMachine

`KeyValueStateMachine` handles key-value pairs found in objects and dictionaries.

```python
from pse.types.key_value import KeyValueStateMachine
from pse.types.string import StringStateMachine
from pse.types.number import NumberStateMachine

# Create a key-value pair state machine
kv_sm = KeyValueStateMachine()

# Create a key-value pair with specific key and value types
typed_kv_sm = KeyValueStateMachine(
    key_state_machine=StringStateMachine(),
    value_state_machine=NumberStateMachine()
)
```

**Key features:**
- Parses key-value pairs with proper separators
- Configurable key and value types
- Handles quoted keys and complex values
- Building block for object and dictionary structures

## WhitespaceStateMachine

`WhitespaceStateMachine` handles whitespace characters, enabling flexible formatting.

```python
from pse.types.whitespace import WhitespaceStateMachine

# Create a whitespace state machine
ws_sm = WhitespaceStateMachine()

# Create a whitespace state machine with specific constraints
required_ws_sm = WhitespaceStateMachine(
    min_whitespace=1,  # Require at least one whitespace character
    max_whitespace=10  # Allow at most 10 whitespace characters
)
```

**Key features:**
- Matches spaces, tabs, newlines, and other whitespace
- Configurable minimum and maximum whitespace
- Used extensively for formatting flexibility
- Helps create human-readable structured outputs