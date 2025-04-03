# MLX Frontend

The MLX frontend allows the Proxy Base Agent (PBA) to run inference using Large Language Models optimized for Apple Silicon (M-series chips) via the [MLX framework](https://github.com/ml-explore/mlx).

## Overview

MLX is a NumPy-like array framework designed by Apple for efficient machine learning on Apple Silicon. The `agent.llm.frontend.mlx.MLXInference` class implements the `Frontend` interface for MLX models.

**Key Features:**

*   **Optimized Performance:** Leverages the unified memory architecture and Neural Engine (ANE) of Apple Silicon for fast local inference.
*   **Model Compatibility:** Works with models converted to the MLX format (often available on Hugging Face hubs like `mlx-community`).
*   **KV Caching:** Supports efficient Key-Value caching, including saving/loading system prompt caches to disk for faster startup (`supports_reusing_prompt_cache()` returns `True`).
*   **PSE Integration:** Seamlessly integrates with the `StructuringEngine` for constrained generation during the `generate_step` process.

## Usage

1.  **Installation:** Ensure you have the necessary MLX dependencies installed. This is typically handled by installing PBA with the `[mlx]` extra:
    ```bash
    pip install proxy-base-agent[mlx]
    # or
    uv pip install proxy-base-agent[mlx]
    ```
    You also need the `mlx-lm` package:
    ```bash
    pip install mlx-lm
    # or
    uv pip install mlx-lm
    ```

2.  **Model Selection:** During the PBA setup wizard (`python -m agent`), choose a model compatible with MLX (e.g., from the `mlx-community` hub on Hugging Face or one you have converted locally). Select "MLX" as the inference backend when prompted.

3.  **Configuration:** The `LocalInference` class will automatically instantiate `MLXInference` when an MLX model path and the MLX frontend are selected. Relevant `inference_kwargs` (like `temp`, `seed`, `max_tokens`, caching options) passed to the `Agent` constructor will be used during generation.

## How it Works

*   **Loading:** `MLXInference` uses `mlx_proxy.utils.load_model` to load the model and `agent.llm.tokenizer.Tokenizer.load` for the tokenizer.
*   **Inference Loop:** The `inference()` method uses `mlx_proxy.generate_step.generate_step`, passing the `engine.process_logits` function to the `logits_processors` argument and a sampler created via `engine.sample` wrapping `mlx_proxy.samplers.make_sampler`.
*   **Caching:** It utilizes `mlx_proxy.cache.BaseCache` for KV caching and implements the `save_cache_to_file` and `load_cache_from_file` methods using `safetensors` for persistent prompt caching.

The MLX frontend provides an efficient way to run PBA locally on Apple Silicon hardware.