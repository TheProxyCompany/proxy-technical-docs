# Installation

This guide will help you install the Proxy Structuring Engine (PSE) and set up your environment for development.

## Standard Installation

We recommend using uv to install PSE:
```bash
uv pip install pse
```

*(This installs the `pse` Python library and its required dependency `pse-core`, which contains the pre-compiled C++ engine.)*

You can also install PSE using pip:

```bash
pip install pse
```


## Development Installation

For development or to access the latest features, you can install from source:

```bash
# Clone the repository
git clone https://github.com/TheProxyCompany/proxy-structuring-engine.git
cd proxy-structuring-engine

# Install in development mode
pip install -e ".[dev]"
```

## Framework-Specific Installation

PSE works with multiple ML frameworks. Install the one(s) you plan to use:

### PyTorch

```bash
pip install pse[torch]

# Or for a specific version
pip install torch pse
```

### MLX (Apple Silicon)

```bash
pip install pse[mlx]

# Or for a specific version
pip install mlx pse
```

### TensorFlow

```bash
pip install pse[tensorflow]

# Or for a specific version
pip install tensorflow pse
```

### JAX

```bash
pip install pse[jax]

# Or for a specific version
pip install jax jaxlib pse
```

## System Requirements

- **Python**: 3.10 or higher
- **Operating Systems**:
  - Linux (Ubuntu 20.04+, Debian 11+, etc.)
  - macOS (11.0+)
  - Windows 10/11
- **Hardware**:
  - Any system capable of running your selected LLM (the PSE only works with local models)

## Getting Help

If you continue to experience issues:

- Check our [GitHub Issues](https://github.com/TheProxyCompany/proxy-structuring-engine/issues)

## Next Steps

Now that you've installed PSE, proceed to the [Quickstart](quickstart.md) guide to run your first example.
