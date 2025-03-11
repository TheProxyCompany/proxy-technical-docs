#!/bin/bash

# Install dependencies
pip install mkdocs-material mkdocstrings[python] pymdown-extensions

# Build main documentation
echo "Building main documentation..."
mkdocs build

# Create site directory if it doesn't exist
mkdir -p site

# Build PSE documentation
echo "Building PSE documentation..."
cd pse-docs
mkdocs build
cd ..
mkdir -p site/pse
cp -r pse-docs/site/* site/pse/

# Build PBA documentation
echo "Building PBA documentation..."
cd pba-docs
mkdocs build
cd ..
mkdir -p site/pba
cp -r pba-docs/site/* site/pba/

echo "Documentation build complete."