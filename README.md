# Proxy Technical Documentation

This repository contains the technical documentation for The Proxy Company's products, with a focus on the Proxy Structuring Engine (PSE).

## Structure

The documentation is built using [MkDocs](https://www.mkdocs.org/) with the [Material theme](https://squidfunk.github.io/mkdocs-material/), providing a clean, responsive layout with excellent search capabilities.

Key directories:

- `docs/`: All documentation content in Markdown format
- `mkdocs.yml`: MkDocs configuration file
- `serve.sh`: Script to serve documentation locally

## Running Locally

To run the documentation locally:

1. Ensure you have Python installed
2. Run the included script:

```bash
./serve.sh
```

This will install necessary dependencies and start a local server at http://localhost:8000.

## Documentation Organization

The documentation is organized into several main sections:

- **Introduction**: Overview, key features, use cases, and comparisons
- **Getting Started**: Installation, quickstart, basic concepts, and first project
- **Core Concepts**: Detailed explanations of PSE's architecture
- **User Guides**: Practical guides for common tasks and integrations
- **API Reference**: Comprehensive API documentation
- **Advanced Topics**: Deep dives into PSE's capabilities
- **Tutorials**: Step-by-step guides for specific use cases
- **Development**: Contributing guide and project structure

## Contributing

To contribute to the documentation:

1. Clone this repository
2. Create a new branch for your changes
3. Make your edits in the appropriate Markdown files
4. Test your changes locally using `./serve.sh`
5. Submit a pull request

## Building for Production

To build the documentation for production deployment:

```bash
mkdocs build
```

This will generate a `site/` directory containing static HTML files that can be deployed to any web server.