# Agent API Reference

The Agent class is the core of the Proxy Base Agent framework. It coordinates all the components and provides the main interface for interacting with the agent.

## Agent Class

::: pba.Agent

## Basic Usage

```python
from pba import Agent

agent = Agent(
    model="meta-llama/Llama-3-8b-instruct",
    system_prompt="You are a helpful assistant."
)

result = agent.run("What is the capital of France?")
print(result)
```

## Constructor Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `model` | str | Required | The LLM model to use (e.g., "meta-llama/Llama-3-8b-instruct") |
| `tools` | ToolRegistry | None | Registry of tools the agent can use |
| `memory` | Memory | SimpleMemory() | Memory system for the agent |
| `reasoning_config` | ReasoningConfig | ReasoningConfig() | Configuration for the reasoning process |
| `system_prompt` | str | "You are a helpful assistant." | System prompt for the agent |
| `max_iterations` | int | 10 | Maximum number of reasoning iterations |
| `max_tokens` | int | 4096 | Maximum tokens in a single response |
| `temperature` | float | 0.7 | Temperature for LLM sampling |
| `seed` | int | None | Random seed for reproducibility |

## Methods

### run

```python
agent.run(
    input_text: str,
    conversation_id: Optional[str] = None,
    context: Optional[Dict[str, Any]] = None
) -> str
```

Run the agent on a given input and return the response.

**Parameters**:

- `input_text` (str): The user input to process
- `conversation_id` (Optional[str]): ID for the conversation (for memory tracking)
- `context` (Optional[Dict[str, Any]]): Additional context for the execution

**Returns**:

- `str`: The agent's response

### update_config

```python
agent.update_config(
    model: Optional[str] = None,
    system_prompt: Optional[str] = None,
    temperature: Optional[float] = None,
    max_tokens: Optional[int] = None,
    max_iterations: Optional[int] = None
) -> None
```

Update the agent's configuration.

**Parameters**:

- `model` (Optional[str]): New model to use
- `system_prompt` (Optional[str]): New system prompt
- `temperature` (Optional[float]): New temperature
- `max_tokens` (Optional[int]): New max tokens
- `max_iterations` (Optional[int]): New max iterations

### add_tool

```python
agent.add_tool(
    name: str,
    tool: Tool
) -> None
```

Add a new tool to the agent's tool registry.

**Parameters**:

- `name` (str): Name of the tool
- `tool` (Tool): Tool instance

### save

```python
agent.save(
    path: str
) -> None
```

Save the agent's state to disk.

**Parameters**:

- `path` (str): Path to save the agent

### load

```python
@classmethod
def load(
    cls,
    path: str
) -> 'Agent'
```

Load an agent from disk.

**Parameters**:

- `path` (str): Path to load the agent from

**Returns**:

- `Agent`: Loaded agent instance

## Examples

### Creating an Agent with Custom Settings

```python
from pba import Agent, ToolRegistry
from pba.memory import HierarchicalMemory
from pba.reasoning import ReasoningConfig

# Create custom components
tools = ToolRegistry()
memory = HierarchicalMemory()
reasoning = ReasoningConfig(planning_enabled=True)

# Create agent with custom settings
agent = Agent(
    model="meta-llama/Llama-3-70b-instruct",
    tools=tools,
    memory=memory,
    reasoning_config=reasoning,
    system_prompt="You are a specialized data analyst.",
    max_iterations=15,
    temperature=0.5
)
```

### Saving and Loading an Agent

```python
# Create and train an agent
agent = Agent(model="meta-llama/Llama-3-8b-instruct")
agent.run("Remember that my favorite color is blue.")

# Save the agent
agent.save("/path/to/saved/agent")

# Later, load the agent
loaded_agent = Agent.load("/path/to/saved/agent")

# The loaded agent remembers the conversation
result = loaded_agent.run("What's my favorite color?")
print(result)  # Should include "blue"
```

## Advanced Usage

For advanced usage and integration with custom components, refer to the API documentation.