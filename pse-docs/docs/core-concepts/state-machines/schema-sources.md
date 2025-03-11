# Schema Sources

PSE provides several ways to create state machines from schema definitions, enabling flexible integration with existing code and data models.

## JSON Schema

The most common way to define structures in PSE is using JSON Schema, a powerful standard for describing JSON data structures.

```python
from pse import StructuringEngine

# Define a JSON Schema
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer", "minimum": 0},
        "address": {
            "type": "object",
            "properties": {
                "street": {"type": "string"},
                "city": {"type": "string"},
                "zipcode": {"type": "string"}
            },
            "required": ["street", "city"]
        },
        "hobbies": {
            "type": "array",
            "items": {"type": "string"}
        }
    },
    "required": ["name", "age"]
}

# Create a structuring engine from the schema
engine = StructuringEngine.from_json_schema(person_schema)
```

**Key features:**
- Support for the full JSON Schema specification
- Nested object and array structures
- Validation constraints (min/max, required fields, patterns)
- Type validation and coercion

## Pydantic Models

PSE can create state machines directly from Pydantic models, integrating seamlessly with Python type definitions.

```python
from pydantic import BaseModel, Field
from typing import List, Optional
from pse import StructuringEngine

# Define a Pydantic model
class Address(BaseModel):
    street: str
    city: str
    zipcode: Optional[str] = None

class Person(BaseModel):
    name: str
    age: int = Field(ge=0)
    address: Optional[Address] = None
    hobbies: List[str] = []

# Create a structuring engine from the Pydantic model
engine = StructuringEngine.from_pydantic(Person)
```

**Key features:**
- Direct integration with Python type annotations
- Automatic schema generation from class definitions
- Support for nested models and complex types
- Validation using Pydantic's powerful validators

## Function Signatures

PSE can extract schema information from function signatures, enabling generation of valid function calls.

```python
from pse import StructuringEngine
from typing import List, Dict, Optional

def search_database(
    query: str,
    max_results: int = 10,
    filters: Optional[Dict[str, str]] = None,
    sort_by: List[str] = ["relevance"]
) -> List[Dict]:
    """
    Search the database with the given parameters.
    
    Args:
        query: The search query string
        max_results: Maximum number of results to return
        filters: Optional dictionary of field/value filters
        sort_by: Fields to sort results by
    
    Returns:
        List of matching records
    """
    pass

# Create a structuring engine from the function signature
engine = StructuringEngine.from_function(search_database)
```

**Key features:**
- Extracts parameter types from function signatures
- Supports default values and optional parameters
- Handles complex nested types with type annotations
- Enables generation of valid function calls with proper arguments

## Custom Grammar Definitions

For highly specialized formats, PSE supports custom grammar definitions using the Lark grammar format.

```python
from pse import StructuringEngine

# Define a custom grammar in Lark EBNF format
sql_grammar = """
    query: select_stmt

    select_stmt: "SELECT" columns "FROM" table_name ["WHERE" condition]
    
    columns: column ("," column)*
    column: IDENT | "*"
    
    table_name: IDENT
    
    condition: expr
    expr: IDENT comparison_op value
    comparison_op: "=" | "<" | ">" | "<=" | ">=" | "!="
    value: STRING | NUMBER
    
    IDENT: /[a-zA-Z_][a-zA-Z0-9_]*/
    STRING: /"[^"]*"/
    NUMBER: /[0-9]+/
    
    %import common.WS
    %ignore WS
"""

# Create a structuring engine from the grammar
engine = StructuringEngine.from_grammar(sql_grammar, start="query")
```

**Key features:**
- Support for complex language definitions
- EBNF grammar format for precise structural control
- Flexible parsing for domain-specific languages
- Perfect for specialized output formats