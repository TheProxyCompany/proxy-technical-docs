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
engine = StructuringEngine.configure(person_schema)
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
engine = StructuringEngine.configure(Person)
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

def search_database(
    query: str,
    max_results: int = 10,
    filters: dict[str, str] | None = None,
    sort_by: list[str] = ["relevance"]
) -> list[dict]:
    """
    Search the database with the given parameters.

    Args:
        query: The search query string
        max_results: Maximum number of results to return
        filters: Optional dictionary of field/value filters
        sort_by: Fields to sort results by
    """
    pass

# Create a structuring engine from the function signature
engine = StructuringEngine.configure(search_database)
```

**Key features:**
- Extracts parameter types from function signatures
- Supports default values and optional parameters
- Handles complex nested types with type annotations
- Enables generation of valid function calls with proper arguments
