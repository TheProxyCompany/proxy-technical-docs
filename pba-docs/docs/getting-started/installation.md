# Installation

This guide will help you install and set up the Proxy Base Agent (PBA) framework in your environment.

## System Requirements

- Python 3.10 or higher
- 8GB+ RAM for standard usage (16GB+ recommended for complex agents)
- Compatible with Linux, macOS, and Windows

## Installation Methods

### Using pip (Recommended)

The simplest way to install PBA is using pip:

```bash
pip install proxy-base-agent
```

For development or the latest features, you can install directly from the repository:

```bash
pip install git+https://github.com/TheProxyCompany/proxy-base-agent.git
```

### Using conda

If you use conda for environment management:

```bash
conda create -n pba python=3.10
conda activate pba
pip install proxy-base-agent
```

### From Source

For development or customization, you can install from source:

```bash
git clone https://github.com/TheProxyCompany/proxy-base-agent.git
cd proxy-base-agent
pip install -e .
```

## Optional Dependencies

PBA supports various ML frameworks and additional functionality through optional dependencies:

### ML Framework Support

Install the relevant package for your preferred ML framework:

```bash
# For PyTorch support
pip install proxy-base-agent[torch]

# For TensorFlow support
pip install proxy-base-agent[tensorflow]

# For JAX support
pip install proxy-base-agent[jax]

# For MLX support
pip install proxy-base-agent[mlx]
```

### Additional Tools

For extended functionality:

```bash
# For web search capabilities
pip install proxy-base-agent[web]

# For database interaction
pip install proxy-base-agent[db]

# For all extensions
pip install proxy-base-agent[all]
```

## Verification

To verify your installation, you can run:

```bash
python -c "import pba; print(pba.__version__)"
```

This should print the installed PBA version.

## Configuration

After installation, you may need to set up API keys or other configuration for certain features. Create a configuration file at `~/.pba/config.yaml`:

```yaml
# Example configuration
models:
  default: "meta-llama/Llama-3-8b-instruct"
  
api_keys:
  openai: "YOUR_OPENAI_API_KEY"
  anthropic: "YOUR_ANTHROPIC_API_KEY"
  
memory:
  storage_path: "~/.pba/memory"
  
logging:
  level: "info"
  path: "~/.pba/logs"
```

## Next Steps

Now that you have PBA installed, you can:

1. Follow the [Quickstart Guide](quickstart.md) to create your first agent
2. Explore [Configuration Options](configuration.md) to customize PBA for your needs
3. Learn about [Core Concepts](../core-concepts/architecture.md) to understand the architecture

If you encounter any issues during installation, please check the [Troubleshooting](../resources/troubleshooting.md) page or report an issue on [GitHub](https://github.com/TheProxyCompany/proxy-base-agent/issues).