# Defining Structure: Schema Sources

The Proxy State Engine (PSE) is designed to be flexible, allowing you to define the desired output structure using several common and convenient methods in Python. The `StructuringEngine.configure()` method accepts various types as its `structure` argument.

## Supported Schema Sources

1.  **Pydantic Models:**
    *   **How:** Pass a Pydantic `BaseModel` class directly.
    *   **Mechanism:** PSE introspects the model's fields, types, validators, default values, and descriptions to automatically generate the corresponding JSON Schema, which is then converted into a `StateMachine`. It respects nested models, standard Python types (`str`, `int`, `list`, `dict`, etc.), `Union`, `Optional`, `Literal`, and more. Field descriptions from the model or its docstring are used.
    *   **Use Case:** Ideal when you already use Pydantic for data validation or prefer a Python-native way to define complex, typed structures. This is often the most convenient method for defining nested JSON objects.
    *   **Example:**
        ```python
        from pydantic import BaseModel

        class User(BaseModel):
            name: str
            id: int

        engine.configure(User)
        ```

2.  **JSON Schema (Dictionary):**
    *   **How:** Pass a Python dictionary representing a valid JSON Schema object.
    *   **Mechanism:** PSE directly interprets the standard JSON Schema keywords (`type`, `properties`, `items`, `required`, `enum`, `pattern`, `minLength`, `format`, `anyOf`, `$ref`, etc.) and converts them into the equivalent `StateMachine` structure. It supports local `$defs` and `$ref` for defining and reusing schema components.
    *   **Use Case:** Useful when working with existing JSON Schemas, integrating with systems that produce/consume JSON Schema, or when needing schema features not directly representable in Pydantic (though PSE's Pydantic conversion is quite comprehensive).
    *   **Example:**
        ```python
        user_schema = {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "id": {"type": "integer"}
            },
            "required": ["name", "id"]
        }
        engine.configure(user_schema)
        ```

3.  **Function Signatures (Callable):**
    *   **How:** Pass a Python function or callable.
    *   **Mechanism:** PSE introspects the function's signature (parameter names, type hints, default values) and parses its docstring (using `docstring-parser`) to generate a JSON Schema representing the function's arguments. This schema is then converted to a `StateMachine`. It aims to produce a structure suitable for generating function call arguments.
    *   **Use Case:** Convenient for generating structured arguments intended for calling a specific Python function, leveraging existing type hints and docstrings.
    *   **Example:**
        ```python
        def get_weather(city: str, unit: str = "celsius"):
            """Fetches weather for a city."""
            # ... function body ...

        engine.configure(get_weather)
        # PSE will expect JSON like: {"city": "...", "unit": "..."}
        ```

4.  **Sequence of Schemas (`list` or `tuple`):**
    *   **How:** Pass a list or tuple where each element is one of the above supported types (Pydantic model, JSON Schema dict, Callable).
    *   **Mechanism:** PSE interprets this as an "anyOf" or "oneOf" condition. It generates the schema for each item in the sequence and combines them using an `AnyStateMachine`. The LLM output must conform to *at least one* of the provided schemas.
    *   **Use Case:** When the LLM's output could validly take one of several different structures depending on the context or input.
    *   **Example:**
        ```python
        from pydantic import BaseModel

        class User(BaseModel): # ...
        class Product(BaseModel): # ...

        engine.configure([User, Product])
        # PSE expects output matching either User OR Product schema
        ```

5.  **Direct `StateMachine` Instance:**
    *   **How:** Pass an instance of a `StateMachine` class (either a base type like `ChainStateMachine` or a custom subclass).
    *   **Mechanism:** PSE uses the provided `StateMachine` directly without any conversion.
    *   **Use Case:** For advanced users who need fine-grained control over the grammar or want to implement complex, non-standard structures or control flows by composing base `StateMachine` types.
    *   **Example:**
        ```python
        from pse.types.base import ChainStateMachine, PhraseStateMachine
        custom_sm = ChainStateMachine([PhraseStateMachine("START"), PhraseStateMachine("END")])
        engine.configure(custom_sm)
        ```

By supporting these diverse sources, PSE allows developers to choose the most natural and efficient way to define their desired output structure based on their existing code, data models, or specific grammatical requirements.
