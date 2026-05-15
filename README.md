# The Proxy Company Documentation

Public documentation for Proxy, Orchard, and proxy.ing.

This repository uses Material MkDocs.

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/TheProxyCompany/proxy-technical-docs.git
cd proxy-technical-docs

# Install dependencies
uv venv
uv pip install -r requirements.txt
```

### Serve the Documentation

```bash
# Serve the docs site
./serve.sh
```

This builds and serves the public documentation site at http://localhost:8000.
The build script creates a local `.venv` when needed.

## Deployment

The documentation is deployed when changes land on the main branch.
