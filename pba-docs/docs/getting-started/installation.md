# Installation

The Proxy Base Agent requires Python 3.11 or higher.

## Prerequisites

1.  **Python 3.11+:** Ensure you have a compatible Python version installed.

## Installation Steps

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/TheProxyCompany/proxy-base-agent.git
    cd proxy-base-agent
    ```

2.  **Install Dependencies:**

    We recommend using [uv](https://docs.astral.sh/uv/) for fast and reliable dependency management.
    ```bash
    uv pip install -e .
    ```
    This command installs the agent and its dependencies in editable mode (`-e .`), making it easy to modify the code and see changes immediately.

    If you don't want to use uv, you can install the dependencies using pip:
    ```bash
    pip install -e .
    ```

## System Requirements

- Python 3.10 or higher
- Compatible with Linux, macOS, and Windows
- Hardware requirements vary depending on the language model you are using.

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

## Next Steps

Now that you have PBA installed, you can:

1. Follow the [Quickstart Guide](quickstart.md)
2. Explore the [Concepts](../concepts/overview.md)
3. Extend the agent with [Custom Tools](../extending/custom-tools.md)

If you encounter any issues during installation, please report an issue on [GitHub](https://github.com/TheProxyCompany/proxy-base-agent/issues).
