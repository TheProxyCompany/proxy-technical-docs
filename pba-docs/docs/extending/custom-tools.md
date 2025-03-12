# Custom Tools

Adding custom tools is a powerful way to extend the Proxy Base Agent's capabilities. This guide explains how to create and integrate your own tools.

## Tool Structure

A custom tool must implement a specific interface to be compatible with the agent. This interface typically involves:

1.  **A Tool Class:**  Create a Python class for your tool.
2.  **An `__init__` method:** This method initializes the tool, potentially loading any necessary resources or configurations.
3.  **A `run` method:** This method takes the tool's input, performs the desired action, and returns the output. The input and output should be dictionaries.

## Example:  A Simple Calculator Tool

```python
class CalculatorTool:
    def __init__(self):
        pass  # No initialization needed for this simple example

    def run(self, input_data: dict) -> dict:
        """
        Performs a simple calculation based on the input.

        Args:
            input_data: A dictionary with 'operation' (str) and 'operands' (list of numbers).

        Returns:
            A dictionary with the 'result' of the calculation.
        """
        operation = input_data.get("operation")
        operands = input_data.get("operands")

        if not operation or not operands:
            return {"error": "Invalid input.  Must provide 'operation' and 'operands'."}

        if operation == "add":
            result = sum(operands)
        elif operation == "multiply":
            result = 1
            for x in operands:
                result *= x
        else:
            return {"error": f"Unsupported operation: {operation}"}

        return {"result": result}

# Example usage:
tool = CalculatorTool()
input_data = {"operation": "add", "operands": [1, 2, 3]}
output = tool.run(input_data)
print(output)  # Output: {'result': 6}

input_data = {"operation": "multiply", "operands": [2, 4, 5]}
output = tool.run(input_data)
print(output)  # Output: {'result': 40}
```

## Integrating the Tool

1.  **Place the Tool Code:** Put your tool's Python code in a location where the agent can import it (e.g., within the `agent/tools` directory).

2.  **Register the Tool:**  You need to register your custom tool with the agent so it knows about the tool and can use it. This typically involves modifying the agent's configuration or initialization code to include your tool. This will likely be in `agent.py`.

    ```python:agent/agent.py
    # ... existing code ...
    from agent.tools.calculator_tool import CalculatorTool  # Import your tool

    # ... existing code ...
    class Agent(AgentBase):
        def __init__(
            self,
    # ... existing code ...
            tools: List[Tool] = None,
    # ... existing code ...
        ):
            if tools is None:
                tools = [] #This will be replaced.
    # ... existing code ...
            {{ tools = [CalculatorTool()] }} # add any other default tools here
            super().__init__(
    # ... existing code ...
    ```
    This adds the `CalculatorTool` to the default tools.

3. **Using the tool in your state machine:** You can now use your tool in your state machine definition. This will involve specifying when the tool should be called and how its input and output should be handled. This will be within the state machine definition, likely in `state_machine.py`. You'll need to add a transition to the `ToolState` (or whatever state you use for tool calls) that checks for your tool's name and calls it.
