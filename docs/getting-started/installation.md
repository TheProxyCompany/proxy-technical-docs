# Installation Guide

This guide provides comprehensive instructions for installing the Proxy Structuring Engine (PSE) in various environments. PSE consists of a high-performance C++ core with Python bindings, requiring proper setup to ensure optimal performance.

## System Requirements

### Supported Operating Systems

- **Linux**: Ubuntu 20.04+, CentOS 7+, Debian 10+
- **macOS**: 11.0+ (Big Sur and newer)
- **Windows**: 10/11 with Visual Studio 2019+ or MinGW-w64

### Hardware Requirements

- **CPU**: Any x86_64 or ARM64 processor (AVX2 instructions recommended but not required)
- **RAM**: Minimum 4GB (8GB+ recommended for larger models)
- **Disk**: ~100MB for installation

### Software Requirements

- **Python**: 3.8 or higher
- **C++ Compiler**:
  - Linux: GCC 9+ or Clang 10+
  - macOS: Clang (via Xcode Command Line Tools)
  - Windows: MSVC 14.2+ (Visual Studio 2019) or MinGW-w64 with GCC 9+

## Standard Installation

For most users, the recommended installation method is via pip:

```bash
pip install pse
```

This will install the pre-compiled binary wheels for your platform if available, or fall back to building from source.

## Installation with Optional Dependencies

PSE provides optional dependencies for different ML frameworks:

```bash
# For PyTorch integration
pip install "pse[torch]"

# For MLX integration (Apple Silicon only)
pip install "pse[mlx]"

# For TensorFlow integration
pip install "pse[tensorflow]"

# For JAX integration
pip install "pse[jax]"

# For all supported frameworks
pip install "pse[all]"

# For development (testing, documentation, etc.)
pip install "pse[dev]"
```

## Using uv (Recommended)

The PSE team recommends using [uv](https://github.com/astral-sh/uv) for faster, more reliable dependency management:

```bash
# Install uv if you don't have it
pip install uv

# Install PSE with uv
uv pip install pse

# With optional dependencies
uv pip install "pse[torch]"
```

## Installation from Source

If you need the latest features or platform-specific optimizations, you can install from source:

### Prerequisites

First, ensure you have the necessary build tools:

#### Linux

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y build-essential cmake python3-dev

# CentOS/RHEL
sudo yum groupinstall -y "Development Tools"
sudo yum install -y cmake3 python3-devel
```

#### macOS

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CMake (via Homebrew)
brew install cmake
```

#### Windows

- Install [Visual Studio 2019 or newer](https://visualstudio.microsoft.com/downloads/) with C++ development tools
- Install [CMake](https://cmake.org/download/)
- Add both to your PATH

### Building and Installing

Clone the repository and build from source:

```bash
# Clone the repository
git clone https://github.com/TheProxyCompany/proxy-structuring-engine.git
cd proxy-structuring-engine

# Build and install
pip install -e .
```

For development installations with all extras:

```bash
pip install -e ".[dev,all]"
```

## Validating Your Installation

To verify your installation is working correctly, run the following Python code:

```python
from pse import StructuringEngine
import json

# Create a simple JSON schema
schema = {
    "type": "object",
    "properties": {
        "hello": {"type": "string"}
    }
}

# Create engine from schema (this will verify the C++ core is working)
engine = StructuringEngine.from_json_schema(schema)

# Print version information
print(f"PSE Version: {StructuringEngine.__version__}")
print(f"C++ Core Version: {StructuringEngine._core_version}")

print("Installation successful!")
```

## Docker Installation

PSE provides official Docker images for containerized environments:

```bash
# Pull the latest image
docker pull theproxycompany/pse:latest

# Run with your model directory mounted
docker run -it --rm -v /path/to/your/models:/models theproxycompany/pse:latest python
```

## Cloud Environment Setup

### Google Colab

PSE works well in Google Colab. Install it using:

```python
!pip install pse
```

### AWS SageMaker

For AWS SageMaker notebooks, install PSE with:

```bash
pip install pse
```

## Framework-Specific Setup

### PyTorch Integration

For PyTorch integration, install both PyTorch and PSE with PyTorch support:

```bash
# Install PyTorch (adjust for your CUDA version if applicable)
pip install torch

# Install PSE with PyTorch support
pip install "pse[torch]"
```

### MLX Integration (Apple Silicon)

For Apple Silicon users with MLX:

```bash
# Install MLX
pip install mlx

# Install PSE with MLX support
pip install "pse[mlx]"
```

### TensorFlow Integration

For TensorFlow:

```bash
# Install TensorFlow
pip install tensorflow

# Install PSE with TensorFlow support
pip install "pse[tensorflow]"
```

### JAX Integration

For JAX:

```bash
# Install JAX (adjust for your accelerator)
pip install jax jaxlib

# Install PSE with JAX support
pip install "pse[jax]"
```

## Troubleshooting

### Common Installation Issues

#### Missing Compiler

**Error**: `error: command 'gcc' failed: No such file or directory`

**Solution**: Install the required compiler:
```bash
# Ubuntu/Debian
sudo apt-get install -y build-essential

# macOS
xcode-select --install
```

#### CMake Not Found

**Error**: `CMake must be installed to build...`

**Solution**: Install CMake:
```bash
# Ubuntu/Debian
sudo apt-get install -y cmake

# macOS
brew install cmake

# Alternatively, use pip
pip install cmake
```

#### C++ Compilation Errors

**Error**: Compiler errors during the build process

**Solution**: Ensure you have a compatible C++ compiler (GCC 9+, Clang 10+, or MSVC 14.2+)

#### Binary Wheel Not Available

**Error**: `Building wheel for pse... (long compile time)`

**Solution**: This is normal if pre-built wheels aren't available for your platform. The compilation may take several minutes.

### Platform-Specific Issues

#### Windows

**Issue**: Visual Studio build tools missing components

**Solution**: Run the Visual Studio Installer, select "Modify" on your installation, and ensure "C++ CMake tools for Windows" is selected.

#### macOS

**Issue**: Building on Apple Silicon (M1/M2/M3)

**Solution**: Ensure you're using Python 3.9+ for native arm64 support. You can check with:
```bash
python3 --version
python3 -c "import platform; print(platform.machine())"
```

#### Linux

**Issue**: Missing shared libraries at runtime

**Solution**: Install required runtime libraries:
```bash
# Ubuntu/Debian
sudo apt-get install -y libstdc++6

# CentOS/RHEL
sudo yum install -y libstdc++
```

## Getting Help

If you encounter issues not covered by this guide:

1. Check the [GitHub Issues](https://github.com/TheProxyCompany/proxy-structuring-engine/issues) for similar problems
2. Join the [Community Discussion](https://github.com/TheProxyCompany/proxy-structuring-engine/discussions) forum
3. Submit a detailed bug report with:
   - Your operating system and version
   - Python version (`python --version`)
   - C++ compiler version (e.g., `gcc --version`, `clang --version`)
   - Full error message and traceback
   - Steps to reproduce

## Next Steps

Now that you've successfully installed PSE, you can:

- Follow our [Quickstart Guide](quickstart.md) to run your first PSE project
- Learn about [Basic Concepts](basic-concepts.md) of the PSE architecture
- Explore the [Framework Adapters](../api/framework-adapters.md) for integration with different ML frameworks

## Advanced Installation Options

### Compile-Time Optimizations

For performance-critical applications, you can enable additional compile-time optimizations:

```bash
# Set environment variables for optimized build
export PSE_OPTIMIZE=1
export PSE_USE_AVX2=1  # Only if your CPU supports AVX2

# Install with optimizations
pip install -e .
```

### Custom Dependencies

If you need specific versions of dependencies:

```bash
# Example with specific nanobind version
export PSE_NANOBIND_VERSION=1.5.0
pip install -e .
```

### Development Installation

For contributors:

```bash
# Clone with git submodules
git clone --recursive https://github.com/TheProxyCompany/proxy-structuring-engine.git
cd proxy-structuring-engine

# Install in development mode with all extras
pip install -e ".[dev,all]"

# Install pre-commit hooks
pre-commit install
```