# The Proxy Company Documentation

This repository contains the technical documentation for The Proxy Company's technology. It's organized as a multi-site MkDocs project with the following structure:

## Repository Structure

- `/docs/` - Main company landing page and overview
- `/pse-docs/` - Proxy Structuring Engine (PSE) documentation
- `/pba-docs/` - Proxy Base Agent (PBA) documentation

## Local Development

### Prerequisites

- Python 3.8+
- pip

### Setup

```bash
# Install dependencies
pip install mkdocs-material mkdocstrings[python] pymdown-extensions
```

### Running Locally

The `serve.sh` script has been enhanced to make local development easier:

```bash
# To run the main documentation site (default)
./serve.sh

# To run PSE documentation
./serve.sh pse

# To run PBA documentation
./serve.sh pba

# To run all documentation sites simultaneously
./serve.sh all
```

When running all sites simultaneously, they will be available at:
- Main documentation: http://localhost:8000
- PSE documentation: http://localhost:8001
- PBA documentation: http://localhost:8002

You can also run the serve script from within each documentation directory:

```bash
cd pse-docs
./serve.sh
```

## Documentation Organization

Each documentation site follows a similar organization pattern:

- **Introduction**: Overview, key features, and use cases
- **Getting Started**: Installation, quickstart, and basic concepts
- **Core Concepts**: Detailed explanations of architecture and design
- **User Guides**: Practical guides for common tasks and integrations
- **API Reference**: Comprehensive API documentation
- **Advanced Topics**: Deep dives into technical capabilities
- **Tutorials**: Step-by-step guides for specific use cases
- **Development**: Contributing guides and project structure

## Building for Production

Run the build script to build all documentation sites:

```bash
./build.sh
```

This will create:
- Main site in `./site/`
- PSE docs in `./site/pse/`
- PBA docs in `./site/pba/`

## Deployment

This documentation is configured for easy deployment with Vercel. When connected to the repository, Vercel will automatically:

1. Execute the build script (`./build.sh`)
2. Deploy the build output (`./site/` directory)

The documentation will be available at:
- Main site: `https://[your-domain]/`
- PSE docs: `https://[your-domain]/pse/`
- PBA docs: `https://[your-domain]/pba/`

## Contributing

To contribute to the documentation:

1. Clone this repository
2. Create a new branch for your changes
3. Make your edits in the appropriate Markdown files
4. Test your changes locally using the serve scripts
5. Submit a pull request