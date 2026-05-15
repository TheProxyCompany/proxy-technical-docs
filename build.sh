#!/usr/bin/env bash
set -e

echo "Current directory: $(pwd)"
echo "Listing files: $(ls -la)"

# Determine Python command
if command -v python3 &> /dev/null; then
    SYSTEM_PYTHON="python3"
else
    SYSTEM_PYTHON="python"
fi
echo "Using Python command: $SYSTEM_PYTHON"

# Clean up any existing site directory
echo "Cleaning up existing site directory..."
rm -rf site

# Install dependencies in a local virtual environment. Homebrew Python rejects
# system installs, and the docs build should not mutate the machine Python.
VENV_DIR="${VENV_DIR:-.venv}"
if command -v uv &> /dev/null; then
    echo "Preparing docs virtual environment with uv..."
    if [ ! -x "$VENV_DIR/bin/python" ]; then
        uv venv "$VENV_DIR"
    fi
    uv pip install --python "$VENV_DIR/bin/python" -r requirements.txt
else
    echo "Preparing docs virtual environment with venv..."
    if [ ! -x "$VENV_DIR/bin/python" ]; then
        "$SYSTEM_PYTHON" -m venv "$VENV_DIR"
    fi
    "$VENV_DIR/bin/python" -m pip install -r requirements.txt
fi
PYTHON_CMD="$VENV_DIR/bin/python"
FILES_TO_PROMPT="$VENV_DIR/bin/files-to-prompt"
echo "Using docs environment: $PYTHON_CMD"

# Copy assets from root assets folder to site/assets
echo "Copying assets from root directory to site/assets..."
mkdir -p site/assets
cp -r assets/* site/assets/ || echo "Warning: Assets copy failed"

# Build public documentation
echo "Building public documentation..."
$PYTHON_CMD -m mkdocs build
cp -r assets/stylesheets/extra.css site/assets/stylesheets/ || echo "Warning: Assets copy failed"

echo "Generating LLM-friendly documentation..."
"$FILES_TO_PROMPT" docs -e md > llm.txt
cp llm.txt site/
echo "LLM-friendly documentation generated successfully"

echo "Documentation build complete."
echo "Listing final site directory:"
ls -la site
