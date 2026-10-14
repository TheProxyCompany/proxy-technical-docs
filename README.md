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

## Visual theme

The docs share the website’s deep green, Libre Caslon Display headings, and
Berkeley Mono labels. The reading surface stays dark, with no theme toggle.

Styles live in `docs/assets/stylesheets/extra.css`. Both the development server
and `build.sh` use this file. Fonts are served locally from `docs/assets/fonts/`.
The `overrides/` directory adds font preloads, article breadcrumbs, and the
website return link while retaining Material’s search and navigation controls.
