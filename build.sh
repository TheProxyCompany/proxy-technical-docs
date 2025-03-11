#!/usr/bin/env bash
set -e

echo "Current directory: $(pwd)"
echo "Listing files: $(ls -la)"

# Install dependencies directly from requirements.txt
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

# Build main documentation
echo "Building main documentation..."
python -m mkdocs build

# Create site directory if it doesn't exist
mkdir -p site

# Build PSE documentation
echo "Building PSE documentation..."
cd pse-docs
python -m mkdocs build || { 
  echo "Warning: PSE docs build had errors, but continuing..."
  mkdir -p site
}
if [ -d "site" ]; then
  cd ..
  mkdir -p site/pse
  cp -r pse-docs/site/* site/pse/ || echo "Warning: PSE site copy failed"
else
  cd ..
  echo "Warning: PSE site directory not found, skipping copy"
fi

# Build PBA documentation
echo "Building PBA documentation..."
cd pba-docs
python -m mkdocs build || { 
  echo "Warning: PBA docs build had errors, but continuing..."
  mkdir -p site
}
if [ -d "site" ]; then
  cd ..
  mkdir -p site/pba
  cp -r pba-docs/site/* site/pba/ || echo "Warning: PBA site copy failed"
else
  cd ..
  echo "Warning: PBA site directory not found, skipping copy"
fi

echo "Documentation build complete."
echo "Listing final site directory:"
ls -la site
