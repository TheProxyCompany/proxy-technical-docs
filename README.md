# The Proxy Company Documentation

Technical documentation for The Proxy Company's products and technology.

This repository contains a comprehensive documentation system built with Material MkDocs.

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/TheProxyCompany/proxy-technical-docs.git
cd proxy-technical-docs

# Install dependencies
pip install -r requirements.txt
```

### Serve the Documentation

```bash
# Serve all documentation with proper subpath routing
./serve.sh
```

This will build the entire documentation site and serve it at http://localhost:8000 with:
- Main docs at `/`
- PSE docs at `/pse/`
- PBA docs at `/pba/`

## Deployment

The documentation is automatically deployed via Vercel when changes are pushed to the main branch.
