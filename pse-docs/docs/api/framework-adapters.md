# Framework Adapters

PSE uses framework adapters to work with different ML frameworks.

## Supported Frameworks

- PyTorch
- MLX
- TensorFlow
- JAX

## Using Framework Adapters

```python
from proxy_structuring_engine import StructuringEngine, Schema
from proxy_structuring_engine.adapters import PyTorchAdapter

# Create an adapter
adapter = PyTorchAdapter()

# Create the engine with the adapter
engine = StructuringEngine(schema, adapter=adapter)

# Generate structured output
result = engine.generate(model, prompt)
```