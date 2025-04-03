# Framework Adapters (Mixins)

To simplify integration with popular Python deep learning frameworks, the Proxy Structuring Engine (PSE) provides optional "mixin" classes. These mixins inherit from the framework's standard generation classes (like `transformers.GenerationMixin`) and override the necessary methods to automatically incorporate PSE's `process_logits` and `sample` hooks.

Using a mixin means you don't need to manually pass `logits_processor=[engine.process_logits]` and `sampler=engine.sample` to your `model.generate()` calls.

## Available Mixins

*   **`pse.util.torch_mixin.PSETorchMixin`**: For PyTorch models using `transformers.GenerationMixin`.
*   **`pse.util.tf_mixin.PSETFMixin`**: For TensorFlow models using `transformers.TFGenerationMixin`.
*   **`pse.util.jax_mixin.PSEFlaxMixin`**: For JAX/Flax models using `transformers.FlaxGenerationMixin`.
*   *(Note: MLX integration is often handled differently, see MLX examples)*

## How to Use (PyTorch Example)

1.  **Import:** Import the mixin alongside your base model class.
    ```python
    import torch
    from transformers import LlamaForCausalLM
    from pse.util.torch_mixin import PSETorchMixin
    ```

2.  **Create Mixed-in Class:** Define a new class that inherits from *both* the PSE mixin *and* your base model class. The order matters; typically, the mixin comes first.
    ```python
    class PSE_Llama(PSETorchMixin, LlamaForCausalLM):
        pass
    ```

3.  **Instantiate Model:** Load your model using this new combined class.
    ```python
    model = PSE_Llama.from_pretrained(...)
    ```

4.  **Attach Engine:** Create your `StructuringEngine` instance and attach it to the model using the `engine` attribute name. The mixin expects to find the engine here.
    ```python
    from pse import StructuringEngine
    # tokenizer = AutoTokenizer.from_pretrained(...)
    model.engine = StructuringEngine(tokenizer)
    ```

5.  **Configure Engine:** Configure the engine with your desired schema.
    ```python
    # from pydantic import BaseModel
    # class MySchema(BaseModel): ...
    model.engine.configure(MySchema)
    ```

6.  **Generate:** Call `model.generate()` as usual. The mixin automatically uses `model.engine.process_logits` and `model.engine.sample`.
    ```python
    # input_ids = tokenizer(...)
    output_ids = model.generate(input_ids, max_new_tokens=100, do_sample=True)
    ```

7.  **Retrieve Output:** Use the attached engine to get the structured output.
    ```python
    structured_output = model.engine.get_structured_output(MySchema)
    ```

## Benefits of Using Mixins

*   **Cleaner Code:** Avoids repetitive passing of `logits_processor` and `sampler` arguments to `generate()`.
*   **Seamless Integration:** Provides a more object-oriented way to associate the `StructuringEngine` with a specific model instance.
*   **Framework Compatibility:** Ensures PSE hooks are applied correctly within the framework's generation loop.

## Without Mixins

If you prefer not to use mixins, you can integrate PSE manually:

1.  Instantiate your base model and `StructuringEngine` separately.
    ```python
    # model = LlamaForCausalLM.from_pretrained(...)
    # engine = StructuringEngine(tokenizer)
    # engine.configure(MySchema)
    ```
2.  Pass the engine's methods directly to `generate()`:
    ```python
    output_ids = model.generate(
        input_ids,
        max_new_tokens=100,
        do_sample=True,
        logits_processor=[engine.process_logits], # Pass processor
        sampler=engine.sample                  # Pass sampler
    )
    ```
3.  Retrieve output using your separate engine instance:
    ```python
    # structured_output = engine.get_structured_output(MySchema)
    ```

While manual integration works perfectly well, the mixins offer a convenient shortcut for cleaner code, especially when working frequently with PSE and a specific model class.