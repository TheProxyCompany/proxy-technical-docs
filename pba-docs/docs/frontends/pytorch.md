# PyTorch Frontend

The PyTorch frontend enables the Proxy Base Agent (PBA) to utilize Large Language Models loaded via the popular [PyTorch](https://pytorch.org/) framework and Hugging Face `transformers`.

## Overview

This frontend uses the `agent.llm.frontend.torch.TorchInference` class, which integrates with standard PyTorch models (like `LlamaForCausalLM` or other `transformers` models) and the PSE `StructuringEngine`.

**Key Features:**

*   **Broad Compatibility:** Works with a wide range of Hugging Face `transformers` models compatible with PyTorch.
*   **Hardware Flexibility:** Runs on CPUs or GPUs (NVIDIA, AMD) supported by PyTorch.
*   **PSE Integration:** Uses the `PSETorchMixin` from the `pse` library to easily integrate the `StructuringEngine`'s `process_logits` and `sample` methods into the standard `transformers` `generate()` workflow.

## Usage

1.  **Installation:** Ensure you have PyTorch and the necessary `transformers` dependencies installed. This is typically handled by installing PBA with the `[torch]` extra:
    ```bash
    pip install proxy-base-agent[torch]
    # or
    uv pip install proxy-base-agent[torch]
    ```
    You may need to install a specific version of PyTorch separately depending on your hardware (CPU/CUDA/ROCm). See the [PyTorch installation guide](https://pytorch.org/get-started/locally/).

2.  **Model Selection:** During the PBA setup wizard (`python -m agent`), choose a model compatible with PyTorch (most standard Hugging Face models). Select "PyTorch" as the inference backend when prompted.

3.  **Configuration:** The `LocalInference` class will automatically instantiate `TorchInference` when a PyTorch-compatible model path and the PyTorch frontend are selected. Relevant `inference_kwargs` (like `temp`, `seed`, `max_tokens`, `top_k`, `top_p`) passed to the `Agent` constructor will be used by the `model.generate()` method.

## How it Works

*   **Loading:** `TorchInference` loads the model using `transformers.AutoModelForCausalLM.from_pretrained` (specifically via the `PSE_Torch` class which incorporates the `PSETorchMixin`) and the tokenizer using `agent.llm.tokenizer.Tokenizer.load`.
*   **Mixin Integration:** The `PSETorchMixin` modifies the model's `_sample` method (used by `generate` when `do_sample=True`) to:
    *   Include `engine.process_logits` in the `logits_processor` list.
    *   Use `engine.sample` (wrapping a basic multinomial sampler or argmax) for token selection.
*   **Inference Loop:** The `inference()` method sets up a `TextIteratorStreamer` and runs `model.generate()` in a separate thread, yielding tokens as they become available from the streamer.
*   **Caching:** Currently, the PyTorch frontend in PBA **does not** implement persistent KV cache saving/loading to disk like the MLX frontend (`supports_reusing_prompt_cache()` returns `False`). Standard `transformers` in-memory KV caching during generation *is* used if enabled (`use_cache=True`).

The PyTorch frontend offers broad model compatibility for running PBA on various hardware configurations.