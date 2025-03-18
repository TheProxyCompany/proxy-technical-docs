#!/bin/bash
set -e

echo "Starting Vercel build..."
CI=true

# Check available Python commands
echo "Checking for Python..."
which python || echo "python not found"
which python3 || echo "python3 not found"
ls -la /usr/bin/python* || echo "No Python found in /usr/bin"
echo "PATH: $PATH"

# Create a Python virtual environment
echo "Creating virtual environment..."
python3 -m venv .venv || python -m venv .venv || mkdir -p .venv/bin && echo '#!/bin/sh' > .venv/bin/activate

# Activate the virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate || true

# Verify we're using the venv Python
echo "Using Python: $(which python)"

# Install dependencies
echo "Installing dependencies..."
python3 -m pip install --upgrade pip || python -m pip install --upgrade pip
python3 -m pip install -U -r requirements.txt || python -m pip install -U -r requirements.txt

# Install pngquant for image optimization
echo "Installing pngquant..."
yum install -y pngquant || brew install pngquant || echo "Warning: Could not install pngquant automatically"

# Verify pngquant installation
which pngquant || echo "Warning: pngquant not found in PATH"

if [ -n "$GH_TOKEN" ]; then
  INSIDERS=true
  echo "Installing mkdocs-material-insiders..."
  python3 -m pip install git+https://${GH_TOKEN}@github.com/squidfunk/mkdocs-material-insiders.git
fi

# Install files-to-prompt for documentation scraping
echo "Installing files-to-prompt for LLM-friendly documentation..."
python3 -m pip install files-to-prompt || {
    echo "Failed to install files-to-prompt, documentation scraping will be skipped"
    SKIP_SCRAPING=true
}

# Copy assets from root assets folder to site/assets
echo "Copying assets from root directory to site/assets..."
mkdir -p site/assets
cp -r assets/* site/assets/ || echo "Warning: Assets copy failed"

# Using mkdocs from virtual environment
if command -v python3 &> /dev/null; then
  MKDOCS="python3 -m mkdocs"
else
  MKDOCS="python -m mkdocs"
fi
echo "Using mkdocs command: $MKDOCS"

# Build main docs
echo "Building main documentation..."
$MKDOCS build

# Create directories for sub-docs
mkdir -p site/pse
mkdir -p site/pba

# Build PSE docs
echo "Building PSE documentation..."
cd pse-docs
$MKDOCS build || echo "Warning: PSE docs build failed, continuing..."
if [ -d "site" ]; then
  cp -r site/* ../site/pse/ || echo "Warning: PSE site copy failed"
else
  echo "Warning: PSE site directory not found"
fi
echo "PSE docs build complete"
cd ..

# Build PBA docs
echo "Building PBA documentation..."
cd pba-docs
$MKDOCS build || echo "Warning: PBA docs build failed, continuing..."
if [ -d "site" ]; then
  cp -r site/* ../site/pba/ || echo "Warning: PBA site copy failed"
else
  echo "Warning: PBA site directory not found"
fi
cd ..

# Generate LLM-friendly documentation
if [ -z "$SKIP_SCRAPING" ]; then
  echo "Generating LLM-friendly documentation..."
  if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
  else
    PYTHON_CMD="python"
  fi
  $PYTHON_CMD -m files_to_prompt docs/index.md pba-docs/docs pse-docs/docs > llm.txt
  if [ -f "llm.txt" ]; then
    echo "Moving LLM-friendly documentation to site/assets..."
    mv llm.txt site/assets
    echo "LLM-friendly documentation generated successfully"
  else
    echo "Warning: LLM-friendly documentation generation failed"
  fi
else
  echo "Skipping LLM-friendly documentation generation due to missing dependencies"
fi

# Ensure robots.txt is copied to the site directory
if [ -f "robots.txt" ]; then
  echo "Copying robots.txt to site directory..."
  cp robots.txt site/
fi

echo "Build complete!"
echo "Site directory contents:"
ls -la site
