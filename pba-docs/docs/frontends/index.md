# LLM Frontends

The Proxy Base Agent (PBA) is designed to work with different local Large Language Model (LLM) inference backends. This flexibility is achieved through the **Frontend** abstraction layer.

## The Frontend Abstraction

The `agent.llm.frontend.Frontend` class defines an abstract interface that decouples the core agent logic from the specifics of how LLM inference is performed. Any backend wanting to integrate with PBA needs to implement this interface.

Key responsibilities of a Frontend implementation include:

*   Loading the specified LLM and its associated tokenizer.
*   Providing a standardized `inference()` method that takes a tokenized prompt and yields generated token IDs one by one (or in small chunks).
*   Integrating with PBA's `StructuringEngine` by accepting it as an argument to `inference()` and applying its `process_logits` and `sample` methods within the generation loop.
*   Optionally supporting KV caching for performance optimization (`supports_reusing_prompt_cache()`, `save_cache_to_file()`, `load_cache_from_file()`).

## Supported Frontends

PBA currently includes built-in support for the following frontends:

*   **[MLX](./mlx.md):** Optimized for Apple Silicon (M-series chips), leveraging the MLX framework for efficient local inference. (Content Pending)
*   **[PyTorch](./pytorch.md):** Supports running models using PyTorch on CPUs or GPUs (NVIDIA/AMD). (Content Pending)

## Choosing a Frontend

The appropriate frontend is typically selected during the interactive setup wizard (`python -m agent`) based on your hardware and the format of the local model you choose.

*   If you are on an Apple Silicon Mac, **MLX** is generally recommended for best performance.
*   If you are on Linux/Windows or have a compatible GPU, **PyTorch** is a common choice.

The `agent.llm.local.LocalInference` class manages the selected `Frontend` instance for the `Agent`.