set -e

# Install dependencies
pip install mkdocs-material pymdown-extensions

# Build main documentation
echo "Building main documentation..."
mkdocs build

# Create site directory if it doesn't exist
mkdir -p site

# Build PSE documentation
echo "Building PSE documentation..."
cd pse-docs
mkdocs build || echo "Warning: PSE docs build had errors, but continuing..."
if [ -d "site" ]; then
  cd ..
  mkdir -p site/pse
  cp -r pse-docs/site/* site/pse/
else
  cd ..
  echo "Warning: PSE site directory not found, skipping copy"
fi

# Build PBA documentation
echo "Building PBA documentation..."
cd pba-docs
mkdocs build || echo "Warning: PBA docs build had errors, but continuing..."
if [ -d "site" ]; then
  cd ..
  mkdir -p site/pba
  cp -r pba-docs/site/* site/pba/
else
  cd ..
  echo "Warning: PBA site directory not found, skipping copy"
fi

echo "Documentation build complete."
