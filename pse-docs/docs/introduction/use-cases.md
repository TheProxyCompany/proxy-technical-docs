# Use Cases

The Proxy Structuring Engine (PSE) enables a wide range of applications where reliable structured output is critical. Here are some key use cases where PSE is making a significant impact.

## API Integration

### Challenge
When LLMs interact with APIs, they must generate valid API calls with the correct structure, parameters, and authentication details. Traditional approaches often produce invalid API calls that fail due to syntax errors or parameter mismatches.

### PSE Solution
PSE guarantees that API calls are syntactically valid and conform to the API's schema requirements:

```python
# Define OpenAI API call schema
openai_schema = {
    "type": "object",
    "properties": {
        "model": {"type": "string", "enum": ["gpt-4", "gpt-3.5-turbo"]},
        "messages": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "role": {"type": "string", "enum": ["system", "user", "assistant"]},
                    "content": {"type": "string"}
                },
                "required": ["role", "content"]
            }
        },
        "temperature": {"type": "number", "minimum": 0, "maximum": 2}
    },
    "required": ["model", "messages"]
}

# Create engine for API calls
api_engine = StructuringEngine.from_json_schema(openai_schema)

# Generate valid API call
result = api_engine.generate(model, "Create an API call to ask OpenAI about climate change")
```

## Data Extraction

### Challenge
Extracting structured data from unstructured text traditionally relies on brittle patterns or post-processing that can fail in unexpected ways.

### PSE Solution
PSE guarantees that extraction results match your desired schema, making data pipelines more reliable:

```python
# Define extraction schema
person_schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"},
        "contact": {
            "type": "object",
            "properties": {
                "email": {"type": "string", "format": "email"},
                "phone": {"type": "string"}
            }
        },
        "skills": {"type": "array", "items": {"type": "string"}}
    },
    "required": ["name", "skills"]
}

# Create extraction engine
extraction_engine = StructuringEngine.from_json_schema(person_schema)

# Extract structured data
result = extraction_engine.generate(
    model, 
    "Extract information about John Smith, 42, who can be reached at john@example.com or 555-1234. His expertise includes Python, machine learning, and data analysis."
)
```

## Code Generation

### Challenge
LLM-generated code often contains syntax errors, uses undefined variables, or includes incomplete implementations, requiring manual fixes before it can be used.

### PSE Solution
PSE enforces syntactic validity for any programming language, ensuring generated code compiles:

```python
# Define Python function grammar
python_function_grammar = Grammar(
    "function",
    Sequence(
        "def ",
        Grammar("function_name", r"[a-zA-Z_][a-zA-Z0-9_]*"),
        "(",
        Optional(Grammar("parameters", r"[^)]*")),
        "):",
        Newline(),
        Indent(
            OneOrMore(
                Grammar("code_line", r"[^\n]*"),
                Newline()
            )
        )
    )
)

# Create code generation engine
code_engine = StructuringEngine.from_grammar(python_function_grammar)

# Generate syntactically valid Python function
result = code_engine.generate(
    model, 
    "Generate a Python function that calculates the Fibonacci sequence recursively."
)
```

## Report Generation

### Challenge
Generating reports with consistent formatting, sections, and data representation is difficult with vanilla LLMs, which may omit sections or produce inconsistent structure.

### PSE Solution
PSE ensures that generated reports follow your exact template requirements:

```python
# Define report schema
report_schema = {
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "date": {"type": "string", "format": "date"},
        "summary": {"type": "string"},
        "sections": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "heading": {"type": "string"},
                    "content": {"type": "string"},
                    "data_points": {
                        "type": "array",
                        "items": {"type": "number"}
                    }
                },
                "required": ["heading", "content"]
            }
        },
        "conclusion": {"type": "string"},
        "recommendations": {
            "type": "array",
            "items": {"type": "string"}
        }
    },
    "required": ["title", "summary", "sections", "conclusion"]
}

# Create report engine
report_engine = StructuringEngine.from_json_schema(report_schema)

# Generate structured report
result = report_engine.generate(
    model, 
    "Create a market analysis report for the renewable energy sector in 2025."
)
```

## Database Queries

### Challenge
LLMs often generate invalid SQL queries with syntax errors, incorrect table/column references, or type mismatches.

### PSE Solution
PSE guarantees that generated database queries are syntactically valid and follow your database schema:

```python
# Define SQL SELECT query grammar
sql_select_grammar = Grammar(
    "select_query",
    Sequence(
        "SELECT ",
        Grammar("columns", r"[^FROM]*"),
        " FROM ",
        Grammar("table_name", r"[a-zA-Z_][a-zA-Z0-9_]*"),
        Optional(
            Sequence(
                " WHERE ",
                Grammar("conditions", r"[^;]*")
            )
        ),
        ";"
    )
)

# Create SQL generation engine
sql_engine = StructuringEngine.from_grammar(sql_select_grammar)

# Generate valid SQL query
result = sql_engine.generate(
    model, 
    "Generate a SQL query to find all customers who made purchases over $1000 in the last month from the 'orders' table."
)
```

## Complex Question Answering

### Challenge
Complex questions often benefit from a combination of unstructured thinking and structured final answers.

### PSE Solution
PSE's composite engines allow LLMs to think through problems in natural language before providing structured answers:

```python
# Define answer schema
answer_schema = {
    "type": "object",
    "properties": {
        "answer": {"type": "string"},
        "confidence": {"type": "number", "minimum": 0, "maximum": 1},
        "sources": {
            "type": "array",
            "items": {"type": "string"}
        }
    },
    "required": ["answer", "confidence"]
}

# Create composite engine with thinking and structured answer
composite_engine = StructuringEngine.create_composite_engine(
    {
        "thinking": NaturalLanguageEngine(),
        "output": StructuringEngine.from_json_schema(answer_schema)
    },
    delimiter_tokens={
        "thinking_to_output": ["\nStructured Answer:\n"]
    }
)

# Generate answer with reasoning trace
result = composite_engine.generate(
    model, 
    "What would happen to Earth's climate if the Gulf Stream stopped flowing?"
)
```

## Game Systems

### Challenge
Game AI requires adhering to complex rule systems and producing valid game actions or narratives.

### PSE Solution
PSE enforces game rules and ensures that generated content follows the game's specific format requirements:

```python
# Define chess move grammar
chess_move_grammar = Grammar(
    "chess_move",
    Sequence(
        Grammar("piece", r"[KQRBN]?"),
        Grammar("file", r"[a-h]"),
        Grammar("rank", r"[1-8]"),
        Optional(
            Sequence(
                Grammar("capture", r"x"),
                Grammar("target_file", r"[a-h]"),
                Grammar("target_rank", r"[1-8]")
            )
        ),
        Optional(
            Grammar("check", r"[+#]")
        )
    )
)

# Create chess move engine
chess_engine = StructuringEngine.from_grammar(chess_move_grammar)

# Generate valid chess notation
result = chess_engine.generate(
    model, 
    "Board position: White king on e1, white queen on d1, black king on e8. Generate White's next move to threaten the black king."
)
```

These examples represent just a few of the possibilities enabled by PSE. As more developers integrate PSE into their applications, we're seeing new and innovative use cases emerge across industries.