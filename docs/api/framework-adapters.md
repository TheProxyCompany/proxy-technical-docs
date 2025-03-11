# Framework Adapters API Reference

The Proxy Structuring Engine (PSE) is designed to be framework-agnostic, but it provides specialized adapters for seamless integration with popular machine learning frameworks. This reference documents the API for each framework-specific adapter, highlighting their unique features and usage patterns.

## Overview

PSE offers adapters for the following frameworks:

- **PyTorch**: Through the `TorchStructuringEngine` class
- **MLX**: Through the `MLXStructuringEngine` class
- **TensorFlow**: Through the `TFStructuringEngine` class
- **JAX**: Through the `JAXStructuringEngine` class

Each adapter inherits from the base `StructuringEngine` class and adds framework-specific optimizations and integration points.

## PyTorch Integration

The `TorchStructuringEngine` class provides optimized integration with PyTorch models, particularly those from the Hugging Face Transformers library.

### Import and Basic Usage

```python
from pse.util.torch_mixin import TorchStructuringEngine
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    }
}

# Create engine
engine = TorchStructuringEngine.from_json_schema(schema)

# Generate with PyTorch-specific methods
prompt = "Extract information about Sarah, who is 29 years old."
input_ids = tokenizer.encode(prompt, return_tensors="pt")

outputs = engine.generate(
    model,
    input_ids,
    max_length=100,
    do_sample=True,
    temperature=0.7
)

result = tokenizer.decode(outputs[0])
print(result)
```

### PyTorch-Specific Methods

#### generate

```python
def generate(self, model, input_ids, attention_mask=None, **kwargs):
    """
    Generate structured output using a PyTorch model.
    
    This method is compatible with Hugging Face's generate API.
    
    Args:
        model: A PyTorch language model (typically a Hugging Face model)
        input_ids (torch.Tensor): The input token IDs
        attention_mask (torch.Tensor, optional): Attention mask
        **kwargs: Additional generation parameters such as:
            - max_length (int): Maximum length of generated sequence
            - max_new_tokens (int): Maximum number of new tokens
            - min_length (int): Minimum length of generated sequence
            - do_sample (bool): Whether to use sampling
            - temperature (float): Sampling temperature
            - top_k (int): Top-k sampling parameter
            - top_p (float): Nucleus sampling parameter
            - num_beams (int): Number of beams for beam search
            - no_repeat_ngram_size (int): Size of n-grams to prevent repetition
            - max_parallel_paths (int): Maximum number of parallel paths to explore
            - healing_threshold (float): Threshold for token healing
    
    Returns:
        torch.Tensor: The generated token IDs
    """
```

#### logits_processor

```python
def logits_processor(self, input_ids, scores, **kwargs):
    """
    Process logits to enforce structure constraints.
    
    This method can be used as a logits processor with Hugging Face's
    generate method.
    
    Args:
        input_ids (torch.Tensor): Current input IDs
        scores (torch.Tensor): Scores/logits from the model
        **kwargs: Additional processing parameters
    
    Returns:
        torch.Tensor: Processed scores with structural constraints applied
    """
```

### Integration with Hugging Face

The `TorchStructuringEngine` can be directly integrated with Hugging Face's generation pipeline:

```python
from transformers import LogitsProcessorList
from transformers.generation import GenerationConfig

# Create a logits processor from the engine
logits_processor = engine.logits_processor

# Add to a LogitsProcessorList
processors = LogitsProcessorList([logits_processor])

# Generate with the model's generate method
outputs = model.generate(
    input_ids,
    generation_config=GenerationConfig(
        max_new_tokens=100,
        temperature=0.7,
        do_sample=True
    ),
    logits_processor=processors
)
```

### CUDA Support

The `TorchStructuringEngine` fully supports CUDA acceleration:

```python
# Load model to GPU
model = model.to("cuda")

# Prepare inputs on GPU
input_ids = input_ids.to("cuda")

# Generate with GPU acceleration
outputs = engine.generate(model, input_ids, max_length=100)

# Move outputs back to CPU if needed
cpu_outputs = outputs.cpu()
```

## MLX Integration (Apple Silicon)

The `MLXStructuringEngine` class provides optimized integration with Apple's MLX framework for efficient inference on Apple Silicon devices.

### Import and Basic Usage

```python
from pse.util.generate_mlx import MLXStructuringEngine
import mlx.core as mx
from mlx_lm import load, generate

# Load MLX model
model, tokenizer = load("mlx-community/Llama-3-8b-mlx")

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    }
}

# Create engine
engine = MLXStructuringEngine.from_json_schema(schema)

# Generate with MLX
prompt = "Extract information about Sarah, who is 29 years old."
input_ids = mx.array(tokenizer.encode(prompt))

outputs = engine.generate(
    model,
    input_ids,
    max_length=100,
    temperature=0.7
)

result = tokenizer.decode(outputs[0].tolist())
print(result)
```

### MLX-Specific Methods

#### generate

```python
def generate(self, model, input_ids, **kwargs):
    """
    Generate structured output using an MLX model.
    
    Args:
        model: An MLX language model
        input_ids (mx.array): The input token IDs
        **kwargs: Additional generation parameters such as:
            - max_length (int): Maximum length of generated sequence
            - temperature (float): Sampling temperature
            - top_k (int): Top-k sampling parameter
            - top_p (float): Nucleus sampling parameter
            - max_parallel_paths (int): Maximum number of parallel paths
            - healing_threshold (float): Threshold for token healing
    
    Returns:
        mx.array: The generated token IDs
    """
```

#### logits_processor

```python
def logits_processor(self, input_ids, logits, **kwargs):
    """
    Process MLX logits to enforce structure constraints.
    
    Args:
        input_ids (mx.array): Current input IDs
        logits (mx.array): Logits from the model
        **kwargs: Additional processing parameters
    
    Returns:
        mx.array: Processed logits with structural constraints applied
    """
```

### Integration with MLX Generate Pipeline

The `MLXStructuringEngine` can be integrated with MLX's generation pipeline:

```python
from mlx_lm.utils import generate

def structured_sampling_fn(logits, input_ids, **kwargs):
    processed_logits = engine.logits_processor(input_ids, logits)
    return processed_logits

# Generate using MLX's generate function with custom sampling
outputs = generate(
    model,
    [tokenizer.encode(prompt)],
    tokenizer,
    max_tokens=100,
    temp=0.7,
    sampling_fn=structured_sampling_fn
)
```

### Apple Silicon Optimization

The `MLXStructuringEngine` is optimized for Apple Silicon:

- Leverages MLX's efficient memory model
- Supports MLX's zero-copy operations
- Optimized for M1/M2/M3 chips
- Minimal memory overhead

## TensorFlow Integration

The `TFStructuringEngine` class provides optimized integration with TensorFlow models.

### Import and Basic Usage

```python
from pse.util.tf_mixin import TFStructuringEngine
import tensorflow as tf
from transformers import TFAutoModelForCausalLM, AutoTokenizer

# Load model
model = TFAutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    }
}

# Create engine
engine = TFStructuringEngine.from_json_schema(schema)

# Generate with TensorFlow
prompt = "Extract information about Sarah, who is 29 years old."
input_ids = tf.convert_to_tensor([tokenizer.encode(prompt)])

outputs = engine.generate(
    model,
    input_ids,
    max_length=100,
    temperature=0.7
)

result = tokenizer.decode(outputs[0].numpy().tolist())
print(result)
```

### TensorFlow-Specific Methods

#### generate

```python
def generate(self, model, input_ids, attention_mask=None, **kwargs):
    """
    Generate structured output using a TensorFlow model.
    
    Args:
        model: A TensorFlow language model
        input_ids (tf.Tensor): The input token IDs
        attention_mask (tf.Tensor, optional): Attention mask
        **kwargs: Additional generation parameters
    
    Returns:
        tf.Tensor: The generated token IDs
    """
```

#### logits_processor

```python
def logits_processor(self, input_ids, logits, **kwargs):
    """
    Process TensorFlow logits to enforce structure constraints.
    
    Args:
        input_ids (tf.Tensor): Current input IDs
        logits (tf.Tensor): Logits from the model
        **kwargs: Additional processing parameters
    
    Returns:
        tf.Tensor: Processed logits with structural constraints applied
    """
```

### Integration with Hugging Face TF

The `TFStructuringEngine` integrates with Hugging Face's TensorFlow pipeline:

```python
# Define a logits processor function
def logits_processor_fn(input_ids, scores):
    return engine.logits_processor(input_ids, scores)

# Generate with the model's generate method
outputs = model.generate(
    input_ids,
    max_new_tokens=100,
    temperature=0.7,
    logits_processor=logits_processor_fn
)
```

## JAX Integration

The `JAXStructuringEngine` class provides integration with JAX models.

### Import and Basic Usage

```python
from pse.util.jax_mixin import JAXStructuringEngine
import jax
import jax.numpy as jnp
from transformers import FlaxAutoModelForCausalLM, AutoTokenizer

# Load model
model = FlaxAutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8b-instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8b-instruct")

# Define schema
schema = {
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    }
}

# Create engine
engine = JAXStructuringEngine.from_json_schema(schema)

# Generate with JAX
prompt = "Extract information about Sarah, who is 29 years old."
input_ids = jnp.array([tokenizer.encode(prompt)])

outputs = engine.generate(
    model,
    input_ids,
    max_length=100,
    temperature=0.7
)

result = tokenizer.decode(outputs[0].tolist())
print(result)
```

### JAX-Specific Methods

#### generate

```python
def generate(self, model, input_ids, **kwargs):
    """
    Generate structured output using a JAX model.
    
    Args:
        model: A JAX language model
        input_ids (jnp.ndarray): The input token IDs
        **kwargs: Additional generation parameters
    
    Returns:
        jnp.ndarray: The generated token IDs
    """
```

#### logits_processor

```python
def logits_processor(self, input_ids, logits, **kwargs):
    """
    Process JAX logits to enforce structure constraints.
    
    Args:
        input_ids (jnp.ndarray): Current input IDs
        logits (jnp.ndarray): Logits from the model
        **kwargs: Additional processing parameters
    
    Returns:
        jnp.ndarray: Processed logits with structural constraints applied
    """
```

### JAX-Specific Features

The `JAXStructuringEngine` offers some JAX-specific features:

- **JIT Compilation**: Support for JAX's just-in-time compilation
- **Auto-Batching**: Compatible with JAX's auto-batching capabilities
- **Functional Style**: Embraces JAX's functional programming paradigm
- **Device Placement**: Supports JAX's device placement strategies

## Creating Custom Framework Adapters

PSE allows creating custom adapters for other frameworks or specialized use cases:

```python
from pse import StructuringEngine

class CustomFrameworkAdapter(StructuringEngine):
    """A custom adapter for a specific framework."""
    
    def __init__(self, state_machine, config=None):
        super().__init__(state_machine, config=config)
        # Framework-specific initialization
        
    @classmethod
    def from_json_schema(cls, schema, config=None):
        # Inherit the factory method but return our class
        base_engine = super().from_json_schema(schema, config)
        return cls(base_engine.get_state_machine(), config)
        
    def generate(self, model, input_ids, **kwargs):
        # Framework-specific generation implementation
        # ...
        
    def logits_processor(self, input_ids, logits, **kwargs):
        # Framework-specific logits processing
        # ...
```

## Performance Comparison

The performance characteristics of each framework adapter vary:

| Adapter | Framework | Speed | Memory Usage | GPU Support | Notes |
|---------|-----------|-------|--------------|-------------|-------|
| `TorchStructuringEngine` | PyTorch | ★★★★☆ | ★★★☆☆ | CUDA, ROCm | Best general-purpose adapter |
| `MLXStructuringEngine` | MLX | ★★★★★ | ★★★★★ | Apple GPU | Best for Apple Silicon |
| `TFStructuringEngine` | TensorFlow | ★★★☆☆ | ★★★☆☆ | CUDA, TPU | Good for TF ecosystems |
| `JAXStructuringEngine` | JAX | ★★★★☆ | ★★★★☆ | CUDA, TPU | Best for research |

## Integration Strategies

### Swapping Between Frameworks

PSE makes it easy to switch between frameworks:

```python
# Same schema, different frameworks
schema = {"type": "object", "properties": {"name": {"type": "string"}}}

# Create engines for different frameworks
torch_engine = TorchStructuringEngine.from_json_schema(schema)
mlx_engine = MLXStructuringEngine.from_json_schema(schema)
tf_engine = TFStructuringEngine.from_json_schema(schema)
jax_engine = JAXStructuringEngine.from_json_schema(schema)

# Choose based on available hardware
if torch.cuda.is_available():
    engine = torch_engine
elif platform.processor() == "arm":  # Apple Silicon
    engine = mlx_engine
elif tf.config.list_physical_devices('GPU'):
    engine = tf_engine
else:
    engine = jax_engine
```

### Framework-Specific Configuration

Each adapter supports framework-specific configuration:

```python
# PyTorch-specific configuration
torch_engine = TorchStructuringEngine.from_json_schema(
    schema,
    config={
        "healing_threshold": 0.7,
        "torch_dtype": torch.float16,      # PyTorch-specific
        "use_cuda_graph": True             # PyTorch-specific
    }
)

# MLX-specific configuration
mlx_engine = MLXStructuringEngine.from_json_schema(
    schema,
    config={
        "healing_threshold": 0.7,
        "mlx_optimize": True,              # MLX-specific
        "zero_copy": True                  # MLX-specific
    }
)
```

## Best Practices

### Choosing the Right Adapter

- **PyTorch**: Best for general use, especially with Hugging Face models
- **MLX**: Best for local inference on Apple Silicon devices
- **TensorFlow**: Best for existing TensorFlow pipelines
- **JAX**: Best for research and experimentation

### Optimizing for Each Framework

#### PyTorch Optimization

```python
# Optimize for PyTorch
engine = TorchStructuringEngine.from_json_schema(
    schema,
    config={
        "healing_threshold": 0.7,
        "max_parallel_paths": 4
    }
)

# Use half-precision
model = model.half()
input_ids = input_ids.to(model.device)

# Generate with optimized settings
with torch.inference_mode():
    outputs = engine.generate(model, input_ids, max_length=100)
```

#### MLX Optimization

```python
# Optimize for MLX
engine = MLXStructuringEngine.from_json_schema(
    schema,
    config={
        "healing_threshold": 0.7,
        "max_parallel_paths": 4
    }
)

# MLX-specific optimizations
input_ids = mx.array(tokenizer.encode(prompt))

# Generate with MLX-optimized settings
outputs = engine.generate(model, input_ids, max_length=100)
```

## Framework-Specific Examples

### PyTorch with Streaming

```python
from pse.util.torch_mixin import TorchStructuringEngine

# Create engine
engine = TorchStructuringEngine.from_json_schema(schema)

# Streaming callback
def on_token(token_id, text):
    print(text, end="", flush=True)

# Generate with streaming
outputs = engine.generate_with_streaming(
    model,
    input_ids,
    callback=on_token,
    max_length=100,
    temperature=0.7
)
```

### MLX with Custom Sampling

```python
from pse.util.generate_mlx import MLXStructuringEngine

# Create engine
engine = MLXStructuringEngine.from_json_schema(schema)

# Custom sampling function
def custom_sampling(logits, temperature=0.7, top_k=10):
    processed_logits = engine.logits_processor(current_ids, logits)
    # Apply temperature
    processed_logits = processed_logits / temperature
    # Apply top-k
    mask = mx.zeros_like(processed_logits, dtype=mx.bool_)
    top_values, top_indices = mx.topk(processed_logits, k=top_k)
    mask = mask.at[top_indices].set(True)
    processed_logits = mx.where(mask, processed_logits, -float('inf'))
    # Sample
    probs = mx.softmax(processed_logits, axis=-1)
    next_token = mx.random.categorical(probs)
    return next_token

# Use in generation
outputs = engine.generate(
    model,
    input_ids,
    sampling_fn=custom_sampling,
    temperature=0.7,
    top_k=10
)
```

## Troubleshooting

### Common Issues

#### PyTorch Issues

1. **CUDA Out of Memory**
   - Reduce `max_parallel_paths`
   - Use half-precision (`model.half()`)
   - Process smaller batches

2. **Slow Generation**
   - Enable CUDA graphs for repeated operations
   - Use `torch.compile()` for PyTorch 2.0+
   - Reduce structural complexity

#### MLX Issues

1. **Metal Device Errors**
   - Ensure macOS is up to date
   - Update MLX to the latest version
   - Reduce model size if necessary

2. **Tokenization Mismatches**
   - Use the tokenizer that comes with the MLX model
   - Adjust `healing_threshold` for better compatibility

## Next Steps

- Explore the [StructuringEngine API](structuring-engine.md) for core functionality
- Learn about the [Type System](types.md) that powers schema definitions
- Try the [Framework-Specific Guides](../frameworks/pytorch.md) for detailed examples
- See [Performance Optimization](../guides/performance.md) for tuning tips