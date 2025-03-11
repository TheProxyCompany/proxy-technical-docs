#!/bin/bash
set -e

echo "Starting Vercel build..."

# Install dependencies
echo "Installing dependencies..."
pip install mkdocs==1.5.3 mkdocs-material==9.5.3 pymdown-extensions==10.3 material-extensions==1.3

# Build main docs
echo "Building main documentation..."
mkdocs build

# Create directories for sub-docs
mkdir -p site/pse
mkdir -p site/pba

# Build PSE docs
echo "Building PSE documentation..."
cd pse-docs
mkdocs build || echo "Warning: PSE docs build failed, continuing..."
if [ -d "site" ]; then
  cp -r site/* ../site/pse/ || echo "Warning: PSE site copy failed"
else
  echo "Warning: PSE site directory not found"
fi
cd ..

# Build PBA docs
echo "Building PBA documentation..."
cd pba-docs
mkdocs build || echo "Warning: PBA docs build failed, continuing..."
if [ -d "site" ]; then
  cp -r site/* ../site/pba/ || echo "Warning: PBA site copy failed"
else
  echo "Warning: PBA site directory not found"
fi
cd ..

echo "Build complete!"
echo "Site directory contents:"
ls -la site