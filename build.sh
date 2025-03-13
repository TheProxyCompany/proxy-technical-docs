#!/usr/bin/env bash
set -e

echo "Current directory: $(pwd)"
echo "Listing files: $(ls -la)"

# Determine Python command
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
else
    PYTHON_CMD="python"
fi
echo "Using Python command: $PYTHON_CMD"

# Clean up any existing site directory
echo "Cleaning up existing site directory..."
rm -rf site

# Install dependencies directly from requirements.txt
echo "Installing dependencies from requirements.txt..."
$PYTHON_CMD -m pip install -r requirements.txt || {
    echo "Failed to install from requirements.txt, falling back to manual installation..."
    $PYTHON_CMD -m pip install mkdocs mkdocs-material mkdocs-material-extensions pymdown-extensions
}

# Copy assets from root assets folder to site/assets
echo "Copying assets from root directory to site/assets..."
mkdir -p site/assets
cp -r assets/* site/assets/ || echo "Warning: Assets copy failed"

# Build main documentation
echo "Building main documentation..."
$PYTHON_CMD -m mkdocs build
cp -r assets/stylesheets/extra.css site/assets/stylesheets/ || echo "Warning: Assets copy failed"

# Build PSE documentation
echo "Building PSE documentation..."
cd pse-docs
$PYTHON_CMD -m mkdocs build || {
  echo "Warning: PSE docs build had errors, but continuing..."
  mkdir -p site
}
if [ -d "site" ]; then
  echo "Copying PSE documentation to main site/pse directory..."
  cd ..
  mkdir -p site/pse
  cp -r pse-docs/site/* site/pse/ || echo "Warning: PSE site copy failed"
  echo "PSE documentation copied successfully"
else
  cd ..
  echo "Warning: PSE site directory not found, skipping copy"
fi

# Build PBA documentation
echo "Building PBA documentation..."
cd pba-docs
$PYTHON_CMD -m mkdocs build || {
  echo "Warning: PBA docs build had errors, but continuing..."
  mkdir -p site
}
if [ -d "site" ]; then
  echo "Copying PBA documentation to main site/pba directory..."
  cd ..
  mkdir -p site/pba
  cp -r pba-docs/site/* site/pba/ || echo "Warning: PBA site copy failed"
  echo "PBA documentation copied successfully"
else
  cd ..
  echo "Warning: PBA site directory not found, skipping copy"
fi

echo "Documentation build complete."
echo "Listing final site directory:"
ls -la site
