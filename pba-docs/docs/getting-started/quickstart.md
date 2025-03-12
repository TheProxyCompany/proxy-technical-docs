# Quickstart

This quickstart guide will walk you through running the Proxy Base Agent and interacting with it.

1.  **Run the Agent:**

    After installing the agent (see [Installation](installation.md)), you can start it using the following command:

    ```bash
    python -m agent
    ```

2.  **Interactive Setup:**

    The agent will guide you through an interactive setup process. This allows you to configure the agent's initial state and parameters.

3.  **Interact with the Agent:**

    Once the setup is complete, you can interact with the agent. The agent will process your input, transition through its states, and potentially use tools to achieve its goal. Observe the agent's output to understand its reasoning and actions.

4. **Example Interaction (Illustrative):**
    The interaction will depend on the specific tools and configuration, but a simplified example might look like this:

    ```
    Agent: (Thinking) I need to determine the user's request.
    Agent: (Scratchpad) User input: "What is the weather in London?"
    Agent: (Inner Monologue) I should use the weather tool to get the current weather in London.
    Agent: (Tool Call) Calling tool: weather_tool with input: {"location": "London"}
    Agent: (Tool Result) {"temperature": 15, "condition": "Cloudy"}
    Agent: The weather in London is currently 15 degrees Celsius and Cloudy.
    ```

## Create a Simple Agent

Here's how to create a basic agent and run it on a task:

```python
from pba import Agent

# Create a basic agent
agent = Agent(model="meta-llama/Llama-3-8b-instruct")

# Run the agent on a simple task
result = agent.run("What is the capital of France?")
print(result)
```

This minimal example creates an agent with default settings and runs it on a simple query.

## Adding Tools

Agents become more powerful when they can use tools. Let's add some basic tools:

```python
from pba import Agent, ToolRegistry
from pba.tools.calculator import Calculator
from pba.tools.web_search import WebSearch

# Create a tool registry
tools = ToolRegistry()
tools.register("calculator", Calculator())
tools.register("web_search", WebSearch(api_key="YOUR_SEARCH_API_KEY"))

# Create an agent with tools
agent = Agent(
    model="meta-llama/Llama-3-8b-instruct",
    tools=tools
)

# Run the agent on a task that requires tools
result = agent.run("What is the square root of 144 plus the population of Paris?")
print(result)
```

The agent will automatically use the calculator to find the square root and the web search to find Paris's population.

## Adding Memory

To create an agent that remembers previous interactions:

```python
from pba import Agent
from pba.memory import HierarchicalMemory

# Create a memory system
memory = HierarchicalMemory()

# Create an agent with memory
agent = Agent(
    model="meta-llama/Llama-3-8b-instruct",
    memory=memory
)

# First interaction
agent.run("My name is Alice.")

# Second interaction - the agent will remember the name
result = agent.run("What's my name?")
print(result)  # Should output something containing "Alice"
```

## Custom Reasoning Process

PBA allows you to customize the agent's reasoning process:

```python
from pba import Agent
from pba.reasoning import ReasoningConfig

# Configure the reasoning process
reasoning_config = ReasoningConfig(
    planning_enabled=True,
    reflection_enabled=True,
    thinking_steps=3
)

# Create an agent with custom reasoning
agent = Agent(
    model="meta-llama/Llama-3-8b-instruct",
    reasoning_config=reasoning_config
)

# Run on a complex task that benefits from careful reasoning
result = agent.run("Design a social media strategy for a small bakery.")
print(result)
```

## Complete Example: Research Assistant

Here's a more complete example of a research assistant agent:

```python
from pba import Agent, ToolRegistry
from pba.memory import HierarchicalMemory
from pba.reasoning import ReasoningConfig
from pba.tools import WebSearch, DocumentReader, Summarizer

# Set up tools
tools = ToolRegistry()
tools.register("web_search", WebSearch(api_key="YOUR_SEARCH_API_KEY"))
tools.register("read_document", DocumentReader())
tools.register("summarize", Summarizer())

# Configure memory
memory = HierarchicalMemory(
    working_memory_limit=10000,
    semantic_compression_enabled=True
)

# Configure reasoning
reasoning = ReasoningConfig(
    planning_enabled=True,
    reflection_enabled=True,
    thinking_steps=5,
    parallel_execution=True
)

# Create research assistant agent
research_agent = Agent(
    model="meta-llama/Llama-3-70b-instruct",
    tools=tools,
    memory=memory,
    reasoning_config=reasoning,
    system_prompt="You are a helpful research assistant. Your goal is to provide thorough, accurate information on topics by searching the web, reading documents, and synthesizing information."
)

# Run a research task
research_topic = """
Research the latest developments in quantum computing, focusing on:
1. Recent breakthroughs in quantum error correction
2. Commercial quantum computing platforms
3. Potential applications in cryptography

Provide a structured report with key findings, areas of consensus, and open questions.
"""

report = research_agent.run(research_topic)
print(report)
```

## Next Steps

Now that you've created your first agents, you can explore the documentation to learn more about PBA's capabilities.
