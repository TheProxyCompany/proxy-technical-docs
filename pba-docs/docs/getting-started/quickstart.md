# Quickstart

This guide provides the fastest way to get the Proxy Base Agent (PBA) running locally and see it in action.

We'll launch the agent using its built-in command-line interface (CLI) and interactive setup wizard.

## Prerequisites

*   Ensure you have met the requirements and installed PBA by following the [Installation Guide](./installation.md).

## 1. Launch the Agent

Open your terminal or command prompt, navigate to the directory where you installed or cloned the `proxy-base-agent`, and run the following command:

```bash
python -m agent
```

This command executes the main entry point of the PBA package.

## 2. Interactive Setup Wizard

Upon launching, PBA will start an interactive setup wizard directly in your terminal. This wizard guides you through configuring the agent for the current session:

*   **Agent Identity:** You'll be prompted to provide a name for the agent instance.
*   **System Prompt:** Choose a base system prompt template that defines the agent's core personality and instructions.
*   **Language Model (LLM):** Select the local LLM you want the agent to use. PBA will scan common locations for compatible models (MLX or PyTorch, depending on your setup). You can also specify a Hugging Face model ID to download.
*   **Inference Backend:** Choose the backend (MLX or PyTorch) if multiple are available for your selected model.
*   **Configuration Mode:**
    *   **Basic:** Uses sensible defaults for most parameters (recommended for first use).
    *   **Advanced:** Allows detailed configuration of capabilities (Python execution, voice), planning behavior, performance options, inference parameters, and more.

Follow the prompts, selecting the options appropriate for your setup. For your first run, using "Basic" configuration mode is recommended.

## 3. Interact

Once the setup wizard completes and the model is loaded, the agent will be ready. You'll see a prompt like:

```
> Enter your message [enter to send, Ctrl+C to exit]:
```

Type your message or instruction to the agent and press Enter.

Observe the agent's output in the terminal. If you enabled advanced options or logging, you might see:

*   **Planning States:** Output delimited by tags like `[thinking]...[/thinking]` or `[scratchpad]...[/scratchpad]` showing the agent's internal reasoning (if the chosen prompt uses them).
*   **Tool Calls:** Structured JSON output within `[tool_call]...[/tool_call]` tags when the agent decides to use a tool.
*   **Tool Results:** Output from the tool execution, often prefixed with `[Tool]`.
*   **Final Response:** The agent's message to you, typically generated via the `send_message` tool.

Experiment with different prompts to see how the agent plans, uses tools (if available), and responds.

## Next Steps

*   Explore the [Core Concepts](../concepts/index.md) to understand the underlying architecture.
*   Learn how to add [Custom Tools](../extending/custom-tools.md) (Content Pending).
*   Configure different [LLM Frontends](../frontends/index.md) (Content Pending).