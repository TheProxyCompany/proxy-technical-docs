# Custom States

Creating custom states allows you to extend the Proxy Base Agent's behavior with new capabilities and workflows. This guide explains how to design, implement, and integrate custom states into the agent's state machine.

## Understanding States in PBA

States are the fundamental building blocks of the agent's behavior. Each state represents a distinct phase in the agent's reasoning or action process. The base agent includes states like Thinking, Scratchpad, Inner Monologue, Tool Call, Python, and Done.

A state has three key components:
1. **State Logic**: The code that executes when the state is active
2. **State Context**: Data that persists within and across states
3. **Transitions**: Rules that determine when to move to another state

## When to Create Custom States

Consider creating custom states when:

- You need specialized reasoning patterns not covered by existing states
- Your agent requires domain-specific processing steps
- You want to implement novel interaction patterns
- You need to integrate with external systems in a structured way

## State Implementation

### Basic State Structure

A custom state typically follows this structure:

```python
from pse import State
from typing import Dict, Any, Tuple, Optional, List

class CustomState(State):
    def __init__(
        self,
        name: str = "CustomState",
        description: str = "A custom state for specialized processing",
        transitions: Optional[List] = None,
    ):
        super().__init__(
            name=name,
            description=description,
            transitions=transitions or [],
        )
        # Initialize any state-specific attributes here
        self.state_specific_attribute = None

    def run(self, context: Dict[str, Any]) -> Tuple[str, Dict[str, Any]]:
        """
        Execute the state's logic and determine the next state.

        Args:
            context: The current context dictionary containing all state data

        Returns:
            A tuple containing (next_state_name, updated_context)
        """
        # 1. Extract relevant information from context
        user_input = context.get("user_input", "")
        history = context.get("history", [])

        # 2. Perform state-specific processing
        processed_result = self._process_data(user_input)

        # 3. Update the context with new information
        context["processed_result"] = processed_result
        context["history"].append({
            "state": self.name,
            "action": "Processed user input",
            "result": processed_result
        })

        # 4. Determine the next state based on conditions
        # This is an alternative to using transitions
        if self._should_move_to_tool_state(processed_result):
            next_state = "ToolState"
        else:
            next_state = "ThinkingState"

        return next_state, context

    def _process_data(self, data: str) -> Dict[str, Any]:
        """
        Internal helper method for processing data.
        """
        # Implementation details
        return {"processed": data.upper()}

    def _should_move_to_tool_state(self, result: Dict[str, Any]) -> bool:
        """
        Internal helper method to determine state transitions.
        """
        # Logic to determine if we should transition to tool state
        return "TOOL" in result.get("processed", "")
```

### State Transitions

Transitions determine when the agent moves from one state to another. There are two ways to define transitions:

1. **In the state machine definition** (recommended for complex logic):
   ```python
   custom_state.add_transition(
       lambda context: "error" in context.get("processed_result", {}),
       "ErrorHandlingState"
   )

   custom_state.add_transition(
       lambda context: context.get("processed_result", {}).get("confidence", 0) > 0.8,
       "HighConfidenceState"
   )

   # Default transition (when no other transitions match)
   custom_state.add_transition(lambda context: True, "DefaultNextState")
   ```

2. **In the state's run method** (simpler for straightforward logic):
   ```python
   def run(self, context):
       # ... state logic ...

       if "error" in result:
           return "ErrorHandlingState", context
       elif result.get("confidence", 0) > 0.8:
           return "HighConfidenceState", context
       else:
           return "DefaultNextState", context
   ```

## Advanced State Features

### State with LLM Integration

Many states will need to interact with the language model. Here's how to create a state that uses the LLM:

```python
class LLMProcessingState(State):
    def __init__(self, name="LLMProcessingState", description="Processes data using an LLM", transitions=None):
        super().__init__(name=name, description=description, transitions=transitions or [])

    def run(self, context):
        # Get the LLM from context
        llm = context.get("llm")
        if not llm:
            context["error"] = "LLM not found in context"
            return "ErrorState", context

        # Prepare the prompt
        user_input = context.get("user_input", "")
        history = context.get("conversation_history", [])
        system_prompt = "You are a helpful assistant specialized in data analysis."

        # Call the LLM
        response = llm.generate(
            system_prompt=system_prompt,
            messages=history + [{"role": "user", "content": user_input}]
        )

        # Process the response
        context["llm_response"] = response
        context["conversation_history"] = history + [
            {"role": "user", "content": user_input},
            {"role": "assistant", "content": response}
        ]

        # Determine next state
        return "ResponseProcessingState", context
```

### State with Memory Management

For states that need to manage memory:

```python
class MemoryManagementState(State):
    def __init__(self, name="MemoryManagementState", description="Manages agent memory", transitions=None):
        super().__init__(name=name, description=description, transitions=transitions or [])

    def run(self, context):
        memory = context.get("memory")
        if not memory:
            context["error"] = "Memory system not found in context"
            return "ErrorState", context

        # Store important information in memory
        if "important_fact" in context:
            memory.store(
                content=context["important_fact"],
                metadata={"source": context.get("source"), "timestamp": time.time()}
            )

        # Retrieve relevant information from memory
        query = context.get("current_topic", "")
        if query:
            relevant_memories = memory.retrieve(query, limit=5)
            context["relevant_memories"] = relevant_memories

        return "ThinkingState", context
```

## Example: Creating a Specialized Research State

Let's create a more complex example - a state for research tasks:

```python
class ResearchState(State):
    def __init__(
        self,
        name="ResearchState",
        description="Conducts research on a topic using available tools",
        transitions=None,
        required_tools=["web_search", "document_reader"]
    ):
        super().__init__(name=name, description=description, transitions=transitions or [])
        self.required_tools = required_tools

    def run(self, context):
        # Validate required tools
        tools = context.get("tools", {})
        for tool_name in self.required_tools:
            if tool_name not in tools:
                context["error"] = f"Required tool '{tool_name}' not available"
                return "ErrorState", context

        # Extract research topic
        research_topic = context.get("research_topic")
        if not research_topic:
            context["error"] = "No research topic provided"
            return "ErrorState", context

        # Plan research approach
        llm = context.get("llm")
        research_plan = llm.generate(
            system_prompt="You are a research planning assistant. Create a step-by-step plan to research the given topic.",
            messages=[{"role": "user", "content": f"Create a research plan for: {research_topic}"}]
        )

        # Parse the research plan into steps
        plan_steps = self._parse_research_plan(research_plan)
        context["research_plan"] = plan_steps

        # Execute first research step
        if plan_steps:
            first_step = plan_steps[0]
            if "web_search" in first_step.lower():
                search_results = tools["web_search"].run({"query": research_topic})
                context["search_results"] = search_results

        # Update research state
        context["research_state"] = {
            "topic": research_topic,
            "plan": plan_steps,
            "current_step": 0,
            "findings": []
        }

        return "ResearchAnalysisState", context

    def _parse_research_plan(self, plan_text):
        """Parse the research plan into discrete steps"""
        # Simple implementation - split by numbered items
        import re
        steps = re.findall(r'\d+\.\s+(.*?)(?=\d+\.|$)', plan_text, re.DOTALL)
        return [step.strip() for step in steps if step.strip()]
```

## Integrating Custom States

To integrate your custom states into the agent:

1. **Create the State Class**: Define your custom state class as shown above.

2. **Add to State Machine**: Integrate your state into the state machine definition:

```python
from agent.state_machine import build_state_machine
from agent.system.custom_states import CustomState, ResearchState

def build_custom_state_machine(tools):
    # Get the base state machine
    state_machine = build_state_machine(tools)

    # Create instances of custom states
    custom_state = CustomState()
    research_state = ResearchState()

    # Add states to the state machine
    state_machine.add_state(custom_state)
    state_machine.add_state(research_state)

    # Define transitions from existing states to new states
    thinking_state = state_machine.get_state("Thinking")
    thinking_state.add_transition(
        lambda context: "research" in context.get("user_intent", "").lower(),
        "ResearchState"
    )

    # Define transitions from new states
    custom_state.add_transition(lambda context: True, "Thinking")
    research_state.add_transition(lambda context: True, "ResearchAnalysisState")

    return state_machine
```

3. **Update Agent Initialization**: Modify your agent initialization to use the custom state machine:

```python
from agent.agent import Agent
from custom_states import build_custom_state_machine

# Create agent with custom state machine
agent = Agent(
    state_machine_builder=build_custom_state_machine,
    # other parameters...
)
```

## Best Practices

When creating custom states:

1. **Single Responsibility**: Each state should have a clear, focused purpose
2. **Context Management**: Be careful with context modifications to avoid side effects
3. **Error Handling**: Include robust error handling in your state logic
4. **Testing**: Create unit tests for your states to verify their behavior
5. **Documentation**: Document your state's purpose, inputs, outputs, and transitions
6. **Reusability**: Design states to be reusable across different agent configurations

## Debugging Custom States

To debug custom states:

1. **Add Logging**: Include logging in your state's run method:
   ```python
   import logging

   def run(self, context):
       logging.debug(f"Entering {self.name} with context keys: {list(context.keys())}")
       # State logic...
       logging.debug(f"Exiting {self.name}, transitioning to {next_state}")
       return next_state, context
   ```

2. **State Visualization**: Use the PSE's visualization tools to see your state machine:
   ```python
   from pse.visualization import visualize_state_machine

   # Generate a visualization of your state machine
   visualize_state_machine(state_machine, output_file="my_state_machine.png")
   ```

3. **Context Inspection**: Add a debugging state that prints the entire context:
   ```python
   class DebugState(State):
       def run(self, context):
           print(f"=== DEBUG STATE ===")
           for key, value in context.items():
               print(f"{key}: {value}")
           print(f"===================")
           return "PreviousState", context
   ```

## Conclusion

Custom states are a powerful way to extend the Proxy Base Agent's capabilities. By creating specialized states, you can implement complex workflows, domain-specific reasoning, and novel interaction patterns. The state machine architecture provides a flexible framework for building sophisticated agents tailored to your specific needs.
