# JSON Schema Integration

JSON Schema is a powerful way to define the structure and validation requirements for JSON data. The Proxy Structuring Engine (PSE) provides first-class support for JSON Schema, allowing you to directly use these schemas to control LLM generation. This guide explains how to effectively use JSON Schema with PSE for reliable structured output generation.

## Introduction to JSON Schema in PSE

JSON Schema provides a vocabulary that allows you to annotate and validate JSON documents. PSE leverages JSON Schema to:

1. Define the structure of desired outputs
2. Enforce field types and constraints
3. Guide the LLM in generating compliant JSON
4. Validate the final output against the schema

## Basic Usage

### Creating a Structuring Engine from JSON Schema

The simplest way to use JSON Schema with PSE is to create a structuring engine directly from a schema:

```python
from pse import StructuringEngine

# Define a simple JSON schema
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer", "minimum": 0},
        "email": {"type": "string", "format": "email"}
    },
    "required": ["name", "age"]
}

# Create a structuring engine from the schema
engine = StructuringEngine.from_json_schema(person_schema)

# Use the engine to generate structured output
outputs = engine.generate(model, input_ids, max_new_tokens=200)
result = tokenizer.decode(outputs[0])
```

### Loading Schema from File

For larger schemas, you can load them from files:

```python
import json
from pse import StructuringEngine

# Load schema from file
with open("schemas/person_schema.json", "r") as f:
    person_schema = json.load(f)

# Create engine
engine = StructuringEngine.from_json_schema(person_schema)
```

## Supported JSON Schema Features

PSE supports a comprehensive set of JSON Schema features:

### Core Types

PSE supports all the core JSON Schema types:

- **object**: JSON objects with properties
- **array**: Ordered lists of items
- **string**: Text strings with optional constraints
- **integer**: Whole numbers
- **number**: Numeric values (integers or floating-point)
- **boolean**: True or false values
- **null**: The null value

### Type-Specific Keywords

#### Objects

```python
object_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "address": {"type": "string"}
    },
    "required": ["name"],                    # Required fields
    "additionalProperties": False,           # No extra fields allowed
    "minProperties": 1,                      # Minimum number of properties
    "maxProperties": 10,                     # Maximum number of properties
    "propertyNames": {                       # Pattern for property names
        "pattern": "^[a-zA-Z_][a-zA-Z0-9_]*$"
    }
}
```

#### Arrays

```python
array_schema = {
    "type": "array",
    "items": {"type": "string"},            # Item type
    "minItems": 1,                          # Minimum array length
    "maxItems": 10,                         # Maximum array length
    "uniqueItems": True,                    # All items must be unique
    "contains": {"type": "string", "enum": ["required_value"]}  # Must contain specific value
}
```

#### Strings

```python
string_schema = {
    "type": "string",
    "minLength": 3,                        # Minimum string length
    "maxLength": 50,                       # Maximum string length
    "pattern": "^[A-Z][a-z]+$",           # Regex pattern
    "format": "email",                     # String format validation
    "enum": ["option1", "option2"]         # Enum of allowed values
}
```

#### Numbers and Integers

```python
number_schema = {
    "type": "number",
    "minimum": 0,                          # Minimum value
    "maximum": 100,                        # Maximum value
    "exclusiveMinimum": 0,                 # Exclusive minimum
    "exclusiveMaximum": 100,               # Exclusive maximum
    "multipleOf": 0.5                      # Must be multiple of value
}
```

### Validation Keywords

PSE supports various validation keywords:

- **enum**: Restricts values to a specific set
- **const**: Restricts value to a constant
- **format**: Validates strings against common formats (email, date, etc.)
- **pattern**: Validates strings against regex patterns

### Composition Keywords

PSE supports composition of schemas:

```python
# allOf - Data must validate against all schemas
allOf_schema = {
    "allOf": [
        {"type": "object", "properties": {"name": {"type": "string"}}},
        {"type": "object", "properties": {"age": {"type": "integer"}}}
    ]
}

# anyOf - Data must validate against at least one schema
anyOf_schema = {
    "anyOf": [
        {"type": "object", "properties": {"name": {"type": "string"}}},
        {"type": "object", "properties": {"id": {"type": "integer"}}}
    ]
}

# oneOf - Data must validate against exactly one schema
oneOf_schema = {
    "oneOf": [
        {"type": "object", "properties": {"name": {"type": "string"}}},
        {"type": "array", "items": {"type": "string"}}
    ]
}

# not - Data must not validate against the schema
not_schema = {
    "not": {"type": "array"}
}
```

### References

PSE supports JSON Schema references for reusing definitions:

```python
schema_with_refs = {
    "type": "object",
    "properties": {
        "person": {"$ref": "#/definitions/person"},
        "address": {"$ref": "#/definitions/address"}
    },
    "definitions": {
        "person": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "age": {"type": "integer"}
            }
        },
        "address": {
            "type": "object",
            "properties": {
                "street": {"type": "string"},
                "city": {"type": "string"}
            }
        }
    }
}
```

## Advanced JSON Schema Usage

### Controlling Generation with Additional Properties

The `additionalProperties` keyword controls whether properties not specified in the schema are allowed:

```python
# Strict schema - no additional properties allowed
strict_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "additionalProperties": False
}

# Open schema - any additional properties allowed
open_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "additionalProperties": True
}

# Typed additional properties - extra properties must be strings
typed_additional_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "additionalProperties": {"type": "string"}
}
```

### Nested Schemas

Complex data structures can be created through nesting:

```python
nested_schema = {
    "type": "object",
    "properties": {
        "user": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "contacts": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "type": {"type": "string", "enum": ["email", "phone", "address"]},
                            "value": {"type": "string"}
                        },
                        "required": ["type", "value"]
                    }
                }
            },
            "required": ["name"]
        },
        "metadata": {
            "type": "object",
            "additionalProperties": {"type": "string"}
        }
    },
    "required": ["user"]
}
```

### Pattern Properties

The `patternProperties` keyword allows you to specify schemas for properties matching certain patterns:

```python
pattern_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"}
    },
    "patternProperties": {
        "^x-": {"type": "string"},              # Properties starting with "x-" must be strings
        "^data_[0-9]+$": {"type": "number"}     # Properties like "data_1", "data_2" must be numbers
    },
    "additionalProperties": False
}
```

### Conditional Schemas

JSON Schema supports conditional validation based on the presence or value of other properties:

```python
conditional_schema = {
    "type": "object",
    "properties": {
        "userType": {"type": "string", "enum": ["individual", "company"]},
        "name": {"type": "string"},
        "companyId": {"type": "string"},
        "taxId": {"type": "string"}
    },
    "required": ["userType", "name"],
    "allOf": [
        {
            "if": {
                "properties": {"userType": {"const": "company"}}
            },
            "then": {
                "required": ["companyId"]
            }
        },
        {
            "if": {
                "properties": {"userType": {"const": "individual"}}
            },
            "then": {
                "required": ["taxId"]
            }
        }
    ]
}
```

## Practical Examples

### Example 1: Customer Information Schema

```python
from pse import StructuringEngine

customer_schema = {
    "type": "object",
    "properties": {
        "customer": {
            "type": "object",
            "properties": {
                "firstName": {"type": "string"},
                "lastName": {"type": "string"},
                "email": {"type": "string", "format": "email"},
                "phone": {"type": "string", "pattern": "^\\+?[0-9]{10,15}$"},
                "address": {
                    "type": "object",
                    "properties": {
                        "street": {"type": "string"},
                        "city": {"type": "string"},
                        "state": {"type": "string"},
                        "zipCode": {"type": "string", "pattern": "^[0-9]{5}(-[0-9]{4})?$"}
                    },
                    "required": ["street", "city", "state", "zipCode"]
                }
            },
            "required": ["firstName", "lastName", "email"]
        },
        "orderHistory": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "orderId": {"type": "string"},
                    "date": {"type": "string", "format": "date"},
                    "total": {"type": "number", "minimum": 0},
                    "status": {"type": "string", "enum": ["pending", "shipped", "delivered", "cancelled"]}
                },
                "required": ["orderId", "date", "total", "status"]
            }
        }
    },
    "required": ["customer"]
}

engine = StructuringEngine.from_json_schema(customer_schema)

# Example prompt
prompt = "Extract customer information for Jane Doe who lives at 123 Main St, Boston, MA 02108. Her email is jane.doe@example.com and phone is +1-555-123-4567. She has ordered twice: order #A12345 on 2023-05-10 for $75.99 (delivered) and order #B67890 on 2023-06-15 for $124.50 (shipped)."
```

### Example 2: API Request Schema

```python
api_request_schema = {
    "type": "object",
    "properties": {
        "endpoint": {"type": "string", "enum": ["/users", "/products", "/orders"]},
        "method": {"type": "string", "enum": ["GET", "POST", "PUT", "DELETE"]},
        "parameters": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "object",
                    "additionalProperties": {"type": "string"}
                },
                "headers": {
                    "type": "object",
                    "additionalProperties": {"type": "string"}
                }
            }
        },
        "body": {
            "type": "object",
            "additionalProperties": True
        },
        "auth": {
            "type": "object",
            "properties": {
                "type": {"type": "string", "enum": ["basic", "bearer", "api_key"]},
                "credentials": {"type": "string"}
            },
            "required": ["type", "credentials"]
        }
    },
    "required": ["endpoint", "method"],
    "allOf": [
        {
            "if": {
                "properties": {"method": {"enum": ["POST", "PUT"]}}
            },
            "then": {
                "required": ["body"]
            }
        }
    ]
}

engine = StructuringEngine.from_json_schema(api_request_schema)
```

## Integration with Pydantic

For Python developers, PSE offers seamless integration with Pydantic models:

```python
from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional
from pse import StructuringEngine

class Address(BaseModel):
    street: str
    city: str
    state: str
    zip_code: str = Field(pattern=r"^[0-9]{5}(-[0-9]{4})?$")

class Customer(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone: Optional[str] = Field(None, pattern=r"^\+?[0-9]{10,15}$")
    address: Optional[Address] = None

class Order(BaseModel):
    order_id: str
    date: str
    total: float = Field(ge=0)
    status: str = Field(enum=["pending", "shipped", "delivered", "cancelled"])

class CustomerRecord(BaseModel):
    customer: Customer
    order_history: Optional[List[Order]] = None

# Create engine from Pydantic model
engine = StructuringEngine.from_pydantic(CustomerRecord)
```

## Best Practices

### Schema Design Guidelines

1. **Start Simple**: Begin with minimal schemas and expand as needed
2. **Be Specific**: Use the most specific types possible (e.g., integer instead of number when appropriate)
3. **Document Intent**: Include descriptions in your schemas to clarify intent
4. **Use Required Judiciously**: Only mark fields as required when they're truly necessary
5. **Consider Defaults**: Specify default values for optional fields when appropriate

### Performance Optimization

1. **Minimize Complexity**: Simpler schemas have better performance
2. **Limit Nesting**: Deeply nested structures increase state machine complexity
3. **Use Pattern Constraints Carefully**: Complex regex patterns can be computationally expensive
4. **Cache Engines**: Reuse structuring engines for repeated operations

### Schema Evolution

When evolving schemas over time:

1. **Backward Compatibility**: Make additions rather than deletions
2. **Optional Fields**: Add new fields as optional
3. **Versioning**: Consider including version fields in your schemas
4. **Feature Detection**: Use conditional schemas to handle version differences

## Troubleshooting

### Common Issues

1. **Generation Never Completes**: Schema may be too restrictive
   - Solution: Make non-critical fields optional
   - Increase the max token count

2. **Invalid Reference Errors**: Schema references can't be resolved
   - Solution: Check reference paths
   - Ensure definitions are in the correct location

3. **Type Mismatch**: The model consistently generates the wrong type
   - Solution: Adjust the schema to better match the model's understanding
   - Use string with pattern instead of specialized types

4. **Performance Issues**: Schema processing is slow
   - Solution: Simplify schema
   - Increase `healing_threshold` for performance

### Schema Validation

To validate your schema before using it with PSE:

```python
import jsonschema
from pse.schema import validate_json_schema

# Validate schema against JSON Schema meta-schema
try:
    validate_json_schema(my_schema)
    print("Schema is valid!")
except jsonschema.exceptions.ValidationError as e:
    print(f"Schema validation error: {e}")
```

## Conclusion

JSON Schema integration in PSE provides a powerful, standardized way to define structural constraints for LLM generation. By leveraging the extensive features of JSON Schema, you can create sophisticated validation rules while maintaining the flexibility and creativity of the underlying language model.

This approach combines the best of both worlds: the creative capabilities of LLMs with the reliable structure of JSON Schema validation.

## Next Steps

- Learn about the [State Machine Architecture](../core-concepts/state-machine.md) behind PSE
- Understand how [Token Healing](../core-concepts/token-healing.md) makes generation robust
- Explore the [Structuring Engine API](../api/structuring-engine.md) for configuration options
- Check out the [Framework Adapters](../api/framework-adapters.md) for different ML frameworks