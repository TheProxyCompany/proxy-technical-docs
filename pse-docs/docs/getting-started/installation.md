# Installation

This guide will help you install the Proxy Structuring Engine (PSE) and set up your environment for development.

## Standard Installation

You can install PSE using pip:

```bash
pip install proxy-structuring-engine
```

We recommend using a virtual environment:

```bash
# Create a virtual environment
python -m venv pse-env

# Activate the environment (Linux/macOS)
source pse-env/bin/activate

# Activate the environment (Windows)
pse-env\Scripts\activate

# Install PSE
pip install proxy-structuring-engine
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
pip install proxy-structuring-engine[torch]

# Or for a specific version
pip install torch==2.0.0 proxy-structuring-engine
```

### MLX (Apple Silicon)

```bash
pip install proxy-structuring-engine[mlx]

# Or for a specific version
pip install mlx==0.2.0 proxy-structuring-engine
```

### TensorFlow

```bash
pip install proxy-structuring-engine[tensorflow]

# Or for a specific version
pip install tensorflow==2.13.0 proxy-structuring-engine
```

### JAX

```bash
pip install proxy-structuring-engine[jax]

# Or for a specific version
pip install jax==0.4.13 jaxlib==0.4.13 proxy-structuring-engine
```

## System Requirements

- **Python**: 3.8 or higher
- **Operating Systems**:
  - Linux (Ubuntu 20.04+, Debian 11+, etc.)
  - macOS (11.0+)
  - Windows 10/11
- **Hardware**:
  - Any system capable of running your selected LLM
  - At least 4GB of RAM for PSE itself
  - SSD storage recommended for optimal performance

## Verify Installation

You can verify your installation by running:

```python
import proxy_structuring_engine as pse
print(f"PSE version: {pse.__version__}")

# Verify framework integration
from proxy_structuring_engine import StructuringEngine
engine = StructuringEngine.from_json_schema({"type": "string"})
print("Installation successful!")
```

## Docker Installation

We provide a Docker image with PSE pre-installed:

```bash
# Pull the PSE Docker image
docker pull theproxycompany/pse:latest

# Run a container
docker run -it theproxycompany/pse:latest python -c "import proxy_structuring_engine as pse; print(pse.__version__)"
```

## Troubleshooting

If you encounter issues during installation:

### Common Issues

#### C++ Compilation Error

PSE's core is implemented in C++. If you see compilation errors:

```bash
# Install required build tools (Ubuntu/Debian)
sudo apt-get install build-essential

# Install required build tools (macOS)
xcode-select --install

# Install required build tools (Windows)
# Install Visual Studio Build Tools with C++ support
```

#### Framework Compatibility

Ensure your selected framework is properly installed:

```bash
# Test PyTorch installation
python -c "import torch; print(torch.__version__)"

# Test MLX installation
python -c "import mlx; print(mlx.__version__)"
```

### Getting Help

If you continue to experience issues:

- Check our [GitHub Issues](https://github.com/TheProxyCompany/proxy-structuring-engine/issues)
- Join our [Discord community](https://discord.gg/theproxycompany)
- Contact us at support@theproxycompany.com

## Next Steps

Now that you've installed PSE, proceed to the [Quickstart](quickstart.md) guide to run your first example.