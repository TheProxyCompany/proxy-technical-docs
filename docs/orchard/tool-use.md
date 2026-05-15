# Tool Use

Tool use lets a model emit a function call instead of plain text. Your
application executes the function, sends the result back, and asks the model to
continue.

## Define A Tool

```python
WEATHER_TOOL = {
    "type": "function",
    "name": "get_weather",
    "description": "Get the current weather for a location.",
    "parameters": {
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "City name, e.g. San Francisco",
            }
        },
        "required": ["location"],
    },
}
```

## Request A Tool Call

```python
import json

from orchard.engine.inference_engine import InferenceEngine

MODEL = "meta-llama/Llama-3.1-8B-Instruct"

with InferenceEngine(load_models=[MODEL]) as engine:
    client = engine.client()
    response = client.responses(
        MODEL,
        input=[
            {
                "type": "message",
                "role": "system",
                "content": "Use tools when they are required. After a tool result, answer the user.",
            },
            {
                "type": "message",
                "role": "user",
                "content": "What is the weather in San Francisco?",
            },
        ],
        tools=[WEATHER_TOOL],
        tool_choice="required",
        temperature=0.0,
        max_output_tokens=128,
    )

    call = response.tool_calls[0]
    print(call.name, json.loads(call.arguments))
```

## Continue With The Tool Result

Inside the same client session, send the function call and function result back
as input items.

```python
tool_result = {"temperature": 65, "unit": "fahrenheit", "condition": "foggy"}

followup = client.responses(
    MODEL,
    input=[
        {
            "type": "message",
            "role": "system",
            "content": "Use tools when they are required. After a tool result, answer the user.",
        },
        {
            "type": "message",
            "role": "user",
            "content": "What is the weather in San Francisco?",
        },
        {
            "type": "function_call",
            "call_id": call.call_id,
            "name": call.name,
            "arguments": call.arguments,
        },
        {
            "type": "function_call_output",
            "call_id": call.call_id,
            "output": json.dumps(tool_result),
        },
    ],
    tools=[WEATHER_TOOL],
    tool_choice="none",
    temperature=0.0,
    max_output_tokens=128,
)

print(followup.output_text)
```

## Streaming Tool Calls

Streaming Responses requests emit function-call argument events while the
arguments are being generated.

```python
events = client.responses(
    MODEL,
    input="What is the weather in San Francisco?",
    tools=[WEATHER_TOOL],
    tool_choice="required",
    stream=True,
    temperature=0.0,
    max_output_tokens=128,
)

for event in events:
    if event.type == "response.function_call_arguments.delta":
        print(event.delta, end="", flush=True)
```

## Tool Choice

| Value | Meaning |
| --- | --- |
| `auto` | Model may call a tool |
| `required` | Model must call a tool |
| `none` | Model must answer without a tool |

## Related

- [Structured output](structured-output.md)
- [Streaming](streaming.md)
- [Reasoning levels](reasoning.md)
