# Custom Tools

Adding custom tools is one of the primary ways to extend the capabilities of the Proxy Base Agent (PBA), allowing it to interact with specific APIs, databases, or perform specialized logic relevant to your application.

## Defining a Tool

A tool in PBA is essentially a Python function with type hints and a docstring, which PBA uses to automatically generate the necessary schema for the Proxy Structuring Engine (PSE).

**Steps to Create a Custom Tool:**

1.  **Create a Python File:** Create a new `.py` file in the `agent/tools/` directory (or a subdirectory). The filename (excluding `.py`) will typically be used as the tool's name.
2.  **Define the Function:** Write a standard Python function (it can be `async` or synchronous).
    *   **First Argument:** The function *must* accept `self: Agent` as its first argument. This provides access to the agent's state and methods if needed.
    *   **Type Hinting:** Use standard Python type hints for all other arguments and the return type. PBA uses these hints (along with Pydantic if models are used) to generate the JSON Schema for PSE.
    *   **Docstring:** Write a clear docstring explaining what the tool does, its arguments, and what it returns. The first line is often used as a short description, and the rest provides details.
3.  **Return Value:** The function should ideally return an `agent.system.interaction.Interaction` object, typically with `role=Interaction.Role.TOOL`. This allows you to structure the tool's output clearly, including content, titles, or even images. Returning a simple string is also possible, which will be wrapped in a basic `Interaction` object.

## Example: Simple Calculator Tool

Let's create a tool named `calculator` that adds two numbers.

1.  **Create File:** `agent/tools/calculator.py`

2.  **Define Function:**

    ```python
    # agent/tools/calculator.py
    from agent.agent import Agent
    from agent.system.interaction import Interaction

    async def calculator(
        self: Agent,
        num1: float,
        num2: float,
        operation: str = "add"
    ) -> Interaction:
        """
        Performs basic arithmetic operations (add, subtract, multiply, divide).

        Args:
            num1: The first number.
            num2: The second number.
            operation: The operation to perform ('add', 'subtract', 'multiply', 'divide'). Defaults to 'add'.

        Returns:
            An Interaction object containing the calculation result or an error message.
        """
        result: float | str
        try:
            if operation == "add":
                result = num1 + num2
            elif operation == "subtract":
                result = num1 - num2
            elif operation == "multiply":
                result = num1 * num2
            elif operation == "divide":
                if num2 == 0:
                    raise ValueError("Cannot divide by zero.")
                result = num1 / num2
            else:
                raise ValueError(f"Unsupported operation: {operation}")

            content = f"Calculation result: {num1} {operation} {num2} = {result}"
            color = "green"
            emoji = "abacus"

        except ValueError as e:
            content = f"Calculation error: {e}"
            color = "red"
            emoji = "warning"

        return Interaction(
            role=Interaction.Role.TOOL,
            content=content,
            title="Calculator Result",
            color=color,
            emoji=emoji,
        )

    ```

## Integration with PBA

PBA automatically discovers tools placed in the `agent/tools/` directory when it starts (specifically, via `Tool.load()` called within `Agent.__init__`).

1.  **Automatic Loading:** When the `Agent` is initialized, it scans the tools directory.
2.  **Schema Generation:** For each discovered function (like `calculator`), PBA uses PSE's capabilities (`callable_to_schema`) to generate a JSON Schema based on the function's signature (arguments, type hints) and docstring.
3.  **State Machine Update:** The generated schema is added to the list of available tools within the `ToolCallState`. The `AgentStateMachine` (and thus the underlying PSE engine) is configured with this updated list.
4.  **Prompt Update:** The tool's name, description (from the docstring), and schema are automatically included in the system prompt section describing available tools.

Now, when the agent decides it needs to perform a calculation during its Planning Phase, it can generate a `ToolCall` targeting the `calculator` tool within the `ToolCallState`. PSE will ensure the generated call includes `num1`, `num2`, and optionally `operation` with the correct types, guaranteeing a valid call to your Python function.

## Next Steps

*   Explore the existing tools in `agent/tools/` for more examples.
*   Consider using Pydantic models for complex tool arguments; PBA integrates seamlessly with them for schema generation.
*   Learn about adding tools dynamically via [MCP](../extending/model-context-protocol.md) (Content Pending).