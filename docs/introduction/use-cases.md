# Use Cases for the Proxy Structuring Engine

The Proxy Structuring Engine (PSE) enables a wide range of applications that were previously challenging or impossible with raw LLMs. This page explores real-world use cases where PSE's ability to ensure structural conformity while preserving model creativity delivers significant value.

## Intelligent Agents

One of the most powerful applications of PSE is in building reliable agent systems that can interact with external systems through APIs and tools.

### API Interaction

Traditional LLMs struggle with consistent API interactions due to format inconsistencies, but PSE excels in this domain:

```python
# Define a schema for GitHub API interaction
github_api_schema = {
    "type": "object",
    "properties": {
        "operation": {"type": "string", "enum": ["search_repos", "get_issues", "create_pr"]},
        "parameters": {
            "type": "object",
            "properties": {
                "query": {"type": "string"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 100},
                "sort_by": {"type": "string", "enum": ["stars", "forks", "updated"]}
            },
            "required": ["query"]
        }
    },
    "required": ["operation", "parameters"]
}

# Create a structuring engine for API calls
api_engine = StructuringEngine.from_json_schema(github_api_schema)
```

**Benefits:**
- Guarantees valid API parameters
- Prevents runtime errors from malformed requests
- Ensures required fields are always present
- Maintains type safety for parameters

### Function Calling

PSE can be used to implement reliable function calling capabilities, similar to OpenAI's function calling but with any LLM:

```python
# Define available functions as JSON schema
functions_schema = {
    "type": "object",
    "properties": {
        "function": {"type": "string", "enum": ["weather_lookup", "calendar_add", "search_web"]},
        "arguments": {
            "type": "object",
            "properties": {
                "location": {"type": "string"},
                "date": {"type": "string", "format": "date"},
                "query": {"type": "string"}
            }
        }
    },
    "required": ["function", "arguments"]
}

# Create a structuring engine for function calls
function_call_engine = StructuringEngine.from_json_schema(functions_schema)
```

**Benefits:**
- Works with any LLM that exposes logits
- Guarantees syntactically valid function calls
- Validates argument types
- Prevents hallucinated function names

### Multi-Step Workflows

PSE enables complex, multi-step agent workflows with guaranteed structural integrity at each step:

```python
# Example workflow for a customer service agent
def customer_service_workflow(user_query):
    # Step 1: Classify the query
    classification = generate_with_schema(classification_engine, user_query)
    
    # Step 2: Retrieve relevant information based on classification
    if classification["type"] == "order_status":
        order_info = retrieve_order_info(classification["order_id"])
        
    # Step 3: Generate structured response
    response = generate_with_schema(response_engine, 
                                   user_query, 
                                   classification=classification,
                                   additional_info=order_info)
    
    return response
```

**Benefits:**
- Maintains state across workflow steps
- Ensures consistent data formats throughout
- Prevents cascading errors
- Enables complex decision trees

## Data Extraction and Transformation

PSE excels at extracting structured information from unstructured text, a common requirement in many data processing pipelines.

### Named Entity Recognition

Extract structured entities from unstructured text with guaranteed schema conformance:

```python
# Define entity schema
entity_schema = {
    "type": "object",
    "properties": {
        "people": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "role": {"type": "string"},
                    "organization": {"type": "string"}
                },
                "required": ["name"]
            }
        },
        "organizations": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "type": {"type": "string"},
                    "location": {"type": "string"}
                },
                "required": ["name"]
            }
        },
        "locations": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "type": {"type": "string", "enum": ["city", "country", "landmark", "other"]}
                },
                "required": ["name", "type"]
            }
        }
    }
}

entity_engine = StructuringEngine.from_json_schema(entity_schema)
```

**Benefits:**
- Consistent entity structure
- Type validation for extracted fields
- Handling of nested entities
- Guaranteed schema compliance

### Document Parsing

Transform semi-structured documents into fully structured data:

```python
# Example: Parse invoice information
invoice_schema = {
    "type": "object",
    "properties": {
        "invoice_number": {"type": "string"},
        "date": {"type": "string"},
        "due_date": {"type": "string"},
        "vendor": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "address": {"type": "string"},
                "tax_id": {"type": "string"}
            },
            "required": ["name"]
        },
        "line_items": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "description": {"type": "string"},
                    "quantity": {"type": "number"},
                    "unit_price": {"type": "number"},
                    "total": {"type": "number"}
                },
                "required": ["description", "total"]
            }
        },
        "total_amount": {"type": "number"}
    },
    "required": ["invoice_number", "date", "vendor", "total_amount"]
}

invoice_engine = StructuringEngine.from_json_schema(invoice_schema)
```

**Benefits:**
- Handles variable document formats
- Ensures critical fields are extracted
- Validates numerical data
- Maintains relationships between entities

### Data Normalization

Transform data between different structured formats with guaranteed validation:

```python
# Example: Transform between data formats
input_data = """
Customer: John Smith
Order #: 12345
Items:
- 2x Widget ($25.00 each)
- 1x Gadget ($50.00)
Total: $100.00
"""

# Transform to standard order format
normalized_order = generate_with_schema(order_schema_engine, input_data)
```

**Benefits:**
- Standardizes inconsistent data formats
- Validates during transformation
- Preserves data relationships
- Handles edge cases consistently

## Code Generation

PSE provides unique capabilities for generating syntactically valid code in various programming languages.

### Function Implementation

Generate complete function implementations with guaranteed syntax validity:

```python
# Define grammar for Python function
python_function_grammar = create_python_function_grammar()

# Create engine for Python function generation
python_engine = StructuringEngine.from_grammar(python_function_grammar)

# Generate a function that sorts a list
prompt = "Write a function called 'custom_sort' that sorts a list of dictionaries based on a specified key."
function_code = generate_with_engine(python_engine, prompt)
```

**Benefits:**
- Guaranteed syntactic correctness
- Proper indentation and formatting
- Matched brackets and parentheses
- No syntax errors

### API Client Generation

Automatically generate client code for APIs based on specifications:

```python
# Generate TypeScript client for REST API
openapi_spec = load_openapi_spec("api_spec.yaml")
typescript_grammar = create_typescript_grammar()

# Create engine with TS grammar and OpenAPI knowledge
client_generator = StructuringEngine.create_composite_engine({
    "thinking": NaturalLanguageEngine(),
    "code": typescript_grammar
})

# Generate client code
typescript_client = generate_with_engine(client_generator, 
                                        f"Generate TypeScript client for this OpenAPI spec: {openapi_spec}")
```

**Benefits:**
- Consistent code style
- Type-safe implementations
- Correct API endpoint formatting
- Error handling included

### Code Completion

Provide context-aware code completion with structural guarantees:

```python
# Code completion with syntax validation
def complete_code(existing_code, cursor_position):
    language_grammar = detect_and_load_grammar(existing_code)
    
    # Create engine with appropriate grammar
    completion_engine = StructuringEngine.from_grammar(language_grammar)
    
    # Generate completion
    completion = generate_with_engine(completion_engine, 
                                     existing_code[:cursor_position],
                                     max_tokens=100)
    
    return existing_code[:cursor_position] + completion
```

**Benefits:**
- Maintains syntactic validity
- Context-aware suggestions
- Language-specific formatting
- No bracket mismatches

## Interactive Applications

PSE enables new kinds of interactive applications that require reliable structured outputs.

### Interactive Fiction and Games

Create dynamic narrative experiences with complex rule systems:

```python
# Define game state schema
game_state_schema = {
    "type": "object",
    "properties": {
        "player": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "health": {"type": "integer", "minimum": 0, "maximum": 100},
                "inventory": {
                    "type": "array",
                    "items": {"type": "string"}
                },
                "location": {"type": "string"}
            }
        },
        "world": {
            "type": "object",
            "properties": {
                "time": {"type": "string"},
                "weather": {"type": "string"},
                "active_quests": {
                    "type": "array",
                    "items": {"type": "string"}
                }
            }
        },
        "available_actions": {
            "type": "array",
            "items": {"type": "string"}
        }
    }
}

# Create engine for game state management
game_engine = StructuringEngine.from_json_schema(game_state_schema)
```

**Benefits:**
- Consistent game state management
- Validated player actions
- Rule-enforced world mechanics
- Error-free narrative progression

### Form Filling

Create intelligent form-filling assistants that produce valid structured data:

```python
# Create a form-filling assistant for insurance claims
insurance_claim_schema = {
    "type": "object",
    "properties": {
        "claimant": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "policy_number": {"type": "string", "pattern": "^[A-Z]{2}\\d{6}$"},
                "contact": {"type": "string"}
            },
            "required": ["name", "policy_number"]
        },
        "incident": {
            "type": "object",
            "properties": {
                "date": {"type": "string", "format": "date"},
                "location": {"type": "string"},
                "description": {"type": "string"},
                "type": {"type": "string", "enum": ["collision", "theft", "damage", "injury", "other"]}
            },
            "required": ["date", "description", "type"]
        },
        "claim_amount": {"type": "number", "minimum": 0}
    },
    "required": ["claimant", "incident"]
}

form_engine = StructuringEngine.from_json_schema(insurance_claim_schema)
```

**Benefits:**
- Validated field formats
- Required field enforcement
- Consistent nested structures
- Type validation

### Quiz and Assessment Generation

Generate structured quizzes and assessments with guaranteed format compliance:

```python
# Define quiz schema
quiz_schema = {
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "difficulty": {"type": "string", "enum": ["easy", "medium", "hard"]},
        "questions": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "question": {"type": "string"},
                    "options": {
                        "type": "array",
                        "items": {"type": "string"},
                        "minItems": 4,
                        "maxItems": 4
                    },
                    "correct_answer": {"type": "integer", "minimum": 0, "maximum": 3},
                    "explanation": {"type": "string"}
                },
                "required": ["question", "options", "correct_answer"]
            },
            "minItems": 5
        }
    },
    "required": ["title", "questions"]
}

quiz_engine = StructuringEngine.from_json_schema(quiz_schema)
```

**Benefits:**
- Consistent quiz structure
- Validated answer formats
- Appropriate difficulty scaling
- Complete question sets

## Conversational AI

PSE enhances conversational AI applications by ensuring reliable structured responses.

### Structured Chat Responses

Generate chat responses with both natural language and structured components:

```python
# Define a schema for chat responses with structured data
response_schema = {
    "type": "object",
    "properties": {
        "message": {"type": "string"},
        "sentiment": {"type": "string", "enum": ["positive", "neutral", "negative"]},
        "entities": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "type": {"type": "string", "enum": ["person", "organization", "product", "location"]},
                    "name": {"type": "string"},
                    "confidence": {"type": "number", "minimum": 0, "maximum": 1}
                },
                "required": ["type", "name"]
            }
        },
        "actions": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "type": {"type": "string", "enum": ["link", "download", "call", "navigate"]},
                    "label": {"type": "string"},
                    "url": {"type": "string"}
                },
                "required": ["type", "label"]
            }
        }
    },
    "required": ["message"]
}

chat_engine = StructuringEngine.from_json_schema(response_schema)
```

**Benefits:**
- Consistent response format
- Typed entity extraction
- Validated action suggestions
- Sentiment classification

### Multi-turn Dialogue Management

Maintain structured dialogue state across conversation turns:

```python
# Define schema for dialogue state
dialogue_state_schema = {
    "type": "object",
    "properties": {
        "user": {
            "type": "object",
            "properties": {
                "intent": {"type": "string"},
                "entities": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "type": {"type": "string"},
                            "value": {"type": "string"}
                        }
                    }
                },
                "sentiment": {"type": "string"}
            }
        },
        "system": {
            "type": "object",
            "properties": {
                "current_state": {"type": "string"},
                "requested_slots": {
                    "type": "array",
                    "items": {"type": "string"}
                },
                "confirmed_slots": {
                    "type": "object",
                    "additionalProperties": {"type": "string"}
                }
            }
        },
        "next_action": {"type": "string"}
    }
}

dialogue_engine = StructuringEngine.from_json_schema(dialogue_state_schema)
```

**Benefits:**
- Consistent dialogue state tracking
- Validated slot filling
- Intent maintenance
- Action planning

### Customer Support Automation

Build reliable customer support bots with structured information handling:

```python
# Create a customer support bot with ticketing integration
support_schema = {
    "type": "object",
    "properties": {
        "customer_issue": {
            "type": "object",
            "properties": {
                "category": {"type": "string", "enum": ["billing", "technical", "account", "other"]},
                "priority": {"type": "string", "enum": ["low", "medium", "high", "critical"]},
                "summary": {"type": "string"},
                "details": {"type": "string"}
            },
            "required": ["category", "summary"]
        },
        "response": {"type": "string"},
        "ticket": {
            "type": "object",
            "properties": {
                "id": {"type": "string"},
                "status": {"type": "string", "enum": ["created", "escalated", "resolved"]},
                "assigned_to": {"type": "string"}
            }
        }
    },
    "required": ["customer_issue", "response"]
}

support_engine = StructuringEngine.from_json_schema(support_schema)
```

**Benefits:**
- Consistent issue categorization
- Validated priority assignment
- Structured ticket management
- Appropriate escalation handling

## Next Steps

- Learn about [PSE's key features](key-features.md) in detail
- See how PSE [compares to alternatives](comparison.md)
- Follow our [Installation Guide](../getting-started/installation.md) to get started
- Try the [Quickstart](../getting-started/quickstart.md) examples