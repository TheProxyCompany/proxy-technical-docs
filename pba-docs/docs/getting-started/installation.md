# Installation

This guide covers installing the Proxy Base Agent (PBA) and its dependencies.

## Prerequisites

*   **Python:** Version 3.10 or higher.
*   **Operating System:** Linux, macOS, or Windows.
*   **LLM Backend:** You need a compatible local LLM setup. PBA currently supports:
    *   [MLX](https://github.com/ml-explore/mlx) (for Apple Silicon Macs)
    *   [PyTorch](https://pytorch.org/) (CPU or GPU)
    *(Support for other backends may be added in the future).*
*   **Hardware:** Requirements depend heavily on the LLM you choose to run locally. Ensure your system meets the minimum requirements for your selected model.

## Installation Methods

Choose the method that best suits your needs:

### Method 1: Using `pip` (Recommended)

This is the simplest way to install the latest stable release of PBA from PyPI.

```bash
# Install the core PBA package
pip install proxy-base-agent

# --- Framework Extras ---
# Install extras for the LLM backend you intend to use:

# For MLX (Apple Silicon):
pip install proxy-base-agent[mlx]

# For PyTorch:
pip install proxy-base-agent[torch]
# (Ensure you have a compatible PyTorch version installed separately if needed)
```

### Method 2: Using `uv` (Fast Alternative)

If you use `uv`, Astral's fast package manager:

```bash
# Install the core PBA package
uv pip install proxy-base-agent

# --- Framework Extras ---
# For MLX (Apple Silicon):
uv pip install proxy-base-agent[mlx]

# For PyTorch:
uv pip install proxy-base-agent[torch]
```

### Method 3: From Source (Development / Latest Features)

Install directly from the GitHub repository for development or to get the absolute latest code (potentially unstable).

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/TheProxyCompany/proxy-base-agent.git
    cd proxy-base-agent
    ```

2.  **Install in Editable Mode:**
    We recommend using a virtual environment.

    *   **Using `pip`:**
        ```bash
        # Install core package and common dev dependencies
        pip install -e ".[dev]"

        # Install specific framework extras if needed
        pip install -e ".[mlx]"
        # or
        pip install -e ".[torch]"
        ```
    *   **Using `uv`:**
        ```bash
        # Install core package and common dev dependencies
        uv pip install -e ".[dev]"

        # Install specific framework extras if needed
        uv pip install -e ".[mlx]"
        # or
        uv pip install -e ".[torch]"
        ```
    The `-e` flag installs the package in "editable" mode, meaning changes you make to the source code will be reflected immediately when you run the agent.

## Verifying Installation

After installation, you should be able to run the agent's setup wizard:

```bash
python -m agent
```

If the wizard starts without import errors, the installation was successful.

## Next Steps

*   Follow the [Quickstart Guide](./quickstart.md) to run the agent and interact with it.
*   Explore the [Core Concepts](../concepts/index.md) to understand how PBA works.

If you encounter issues, please open an issue on [GitHub](https://github.com/TheProxyCompany/proxy-base-agent/issues).