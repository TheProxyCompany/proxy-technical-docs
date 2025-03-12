# Framework Adapters

PSE is designed to be framework-agnostic, supporting multiple machine learning frameworks through its adapter system. This page explains how to use PSE with different ML frameworks and how to optimize for each.

## Supported Frameworks

PSE officially supports the following frameworks:

- [PyTorch](#pytorch-adapter)
- [MLX](#mlx-adapter)
- [TensorFlow](#tensorflow-adapter)
- [JAX](#jax-adapter)

The adapter system provides a consistent interface while handling framework-specific tensor operations under the hood.

## How Adapters Work

Framework adapters serve as a bridge between PSE's core and various ML frameworks by:

1. Converting framework-specific tensor types to a unified representation
2. Handling logit modifications in the appropriate format
3. Managing device placement (CPU, GPU, TPU, etc.)
4. Optimizing performance for the specific framework

## PyTorch Adapter

The PyTorch adapter is the most feature-complete adapter and provides seamless integration with HuggingFace Transformers.

### Basic Usage

```python
from proxy_structuring_engine import StructuringEngine, Schema
from proxy_structuring_engine.adapters import PyTorchAdapter
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define schema
schema = {"type": "object", "properties": {"name": {"type": "string"}}}

# Create adapter and engine
adapter = PyTorchAdapter()
engine = StructuringEngine.from_json_schema(schema, adapter=adapter)

# Generate structured output
input_ids = tokenizer.encode("Extract a name from this text: John Smith is a developer.", return_tensors="pt")
outputs = engine.generate(model, input_ids)
result = tokenizer.decode(outputs[0])
print(result)
```

### PyTorch-Specific Options

```python
# Configure device placement
adapter = PyTorchAdapter(device="cuda:0")

# Use BFloat16 precision
adapter = PyTorchAdapter(dtype=torch.bfloat16)

# Configure custom options
adapter = PyTorchAdapter(
    device="cuda:0",
    dtype=torch.float16,
    use_cache=True,
    compile_model=False  # Use torch.compile for additional speedup (requires PyTorch 2.0+)
)
```

### Performance Tips

- Use `device="cuda:0"` for GPU acceleration
- Consider `dtype=torch.bfloat16` for a good balance of speed and precision
- Enable `compile_model=True` for PyTorch 2.0+ models to gain extra performance
- Use batch sizes >1 for parallel processing

## MLX Adapter

The MLX adapter provides optimized integration for Apple Silicon devices.

### Basic Usage

```python
from proxy_structuring_engine import StructuringEngine, Schema
from proxy_structuring_engine.adapters import MLXAdapter
import mlx.core as mx
from mlx_lm import load_model

# Load model
model, tokenizer = load_model("mlx-community/Mistral-7B-Instruct-v0.2-4bit-mlx")

# Define schema
schema = {"type": "object", "properties": {"name": {"type": "string"}}}

# Create adapter and engine
adapter = MLXAdapter()
engine = StructuringEngine.from_json_schema(schema, adapter=adapter)

# Generate structured output
input_ids = tokenizer.encode("Extract a name from this text: John Smith is a developer.")
input_ids = mx.array([input_ids])
outputs = engine.generate(model, input_ids)
result = tokenizer.decode(outputs[0].tolist())
print(result)
```

### MLX-Specific Options

```python
# Configure precision
adapter = MLXAdapter(dtype=mx.float16)

# Configure custom options
adapter = MLXAdapter(
    dtype=mx.bfloat16,
    use_metal=True,  # Force Metal GPU usage
    optimize_graph=True  # Enable MLX graph optimization
)
```

### Performance Tips

- `dtype=mx.bfloat16` generally offers the best performance on Apple Silicon
- Enable `optimize_graph=True` for longer generations
- Ensure your model weights are quantized for maximum efficiency
- Consider setting `mx.set_default_device(mx.gpu(0))` before creating the adapter

## TensorFlow Adapter

The TensorFlow adapter provides integration with TensorFlow models and Keras.

### Basic Usage

```python
from proxy_structuring_engine import StructuringEngine, Schema
from proxy_structuring_engine.adapters import TensorFlowAdapter
import tensorflow as tf
from transformers import TFAutoModelForCausalLM, AutoTokenizer

# Load model
model = TFAutoModelForCausalLM.from_pretrained("gpt2")
tokenizer = AutoTokenizer.from_pretrained("gpt2")

# Define schema
schema = {"type": "object", "properties": {"name": {"type": "string"}}}

# Create adapter and engine
adapter = TensorFlowAdapter()
engine = StructuringEngine.from_json_schema(schema, adapter=adapter)

# Generate structured output
input_ids = tokenizer.encode("Extract a name from this text: John Smith is a developer.", return_tensors="tf")
outputs = engine.generate(model, input_ids)
result = tokenizer.decode(outputs[0].numpy())
print(result)
```

### TensorFlow-Specific Options

```python
# Configure device placement
adapter = TensorFlowAdapter(device="/GPU:0")

# Use mixed precision
adapter = TensorFlowAdapter(mixed_precision=True)

# Configure custom options
adapter = TensorFlowAdapter(
    device="/GPU:0",
    mixed_precision=True,
    xla_compilation=True  # Enable XLA compilation for faster execution
)
```

### Performance Tips

- Enable `mixed_precision=True` for faster execution on compatible GPUs
- Use `xla_compilation=True` for substantial speedups on long generations
- Consider using `jit_compile=True` in your model's call method
- Set `tf.config.experimental.set_memory_growth(gpu, True)` for better memory handling

## JAX Adapter

The JAX adapter provides high-performance integration with JAX-based models.

### Basic Usage

```python
from proxy_structuring_engine import StructuringEngine, Schema
from proxy_structuring_engine.adapters import JAXAdapter
import jax
import jax.numpy as jnp
from transformers import FlaxAutoModelForCausalLM, AutoTokenizer

# Load model
model = FlaxAutoModelForCausalLM.from_pretrained("gpt2")
tokenizer = AutoTokenizer.from_pretrained("gpt2")

# Define schema
schema = {"type": "object", "properties": {"name": {"type": "string"}}}

# Create adapter and engine
adapter = JAXAdapter()
engine = StructuringEngine.from_json_schema(schema, adapter=adapter)

# Generate structured output
input_ids = jnp.array([tokenizer.encode("Extract a name from this text: John Smith is a developer.")])
outputs = engine.generate(model, input_ids)
result = tokenizer.decode(outputs[0])
print(result)
```

### JAX-Specific Options

```python
# Configure precision
adapter = JAXAdapter(dtype=jnp.bfloat16)

# Configure custom options
adapter = JAXAdapter(
    dtype=jnp.bfloat16,
    jit_compile=True,  # Enable JAX JIT compilation
    platform="gpu"     # Target specific platform (gpu, cpu, tpu)
)
```

### Performance Tips

- Always enable `jit_compile=True` for maximum performance
- Use `jnp.bfloat16` dtype on TPUs and newer GPUs
- Enable scan-based generation if available in your model
- Consider using `jax.pmap` for multi-device parallelism

## Custom Adapters

You can create custom adapters for specialized frameworks or optimizations by extending the base `FrameworkAdapter` class:

```python
from proxy_structuring_engine.adapters import FrameworkAdapter
import custom_ml_framework as cmf

class CustomAdapter(FrameworkAdapter):
    def __init__(self, **kwargs):
        super().__init__()
        self.device = kwargs.get("device", "cpu")
        # Other initialization...
    
    def mask_logits(self, logits, mask_indices):
        """Implement masking for your framework"""
        # Framework-specific implementation
        return masked_logits
    
    def sample_token(self, logits, temperature=1.0):
        """Implement token sampling for your framework"""
        # Framework-specific implementation
        return sampled_token_ids

# Use your custom adapter
adapter = CustomAdapter(device="specialized_hardware")
engine = StructuringEngine.from_json_schema(schema, adapter=adapter)
```

## Adapter Compatibility

| Feature | PyTorch | MLX | TensorFlow | JAX |
|---------|---------|-----|------------|-----|
| Float32 | ✓ | ✓ | ✓ | ✓ |
| Float16 | ✓ | ✓ | ✓ | ✓ |
| BFloat16 | ✓ | ✓ | ✓ | ✓ |
| Int8 Quantization | ✓ | ✓ | ✓ | ✓ |
| Batched Generation | ✓ | ✓ | ✓ | ✓ |
| Multi-GPU Support | ✓ | - | ✓ | ✓ |
| TPU Support | - | - | ✓ | ✓ |
| Dynamic Shapes | ✓ | ✓ | ✓ | Limited |
| Logits Processor | ✓ | ✓ | ✓ | ✓ |
| Speculative Decoding | ✓ | - | - | ✓ |

## Troubleshooting

### Common Issues

**PyTorch**: "CUDA out of memory"
- Reduce batch size or model size
- Use a lower precision (float16 or bfloat16)
- Enable gradient checkpointing if using in training

**MLX**: "Metal device not found"
- Ensure you're running on Apple Silicon hardware
- Update to the latest MLX version
- Check for competing GPU processes

**TensorFlow**: "Graph execution error"
- Disable XLA compilation or mixed precision
- Check input/output shapes for compatibility
- Add `@tf.function` decorators strategically

**JAX**: "PRNG key error during sampling"
- Make sure to pass a proper JAX PRNG key
- Use `jax.random.PRNGKey(seed)` to create a key
- Split keys for multiple operations