# The Proxy Company Documentation

Technical documentation for The Proxy Company's products and technology. This repository contains a comprehensive documentation system built with MkDocs and the Material theme.

## Repository Structure

- `/docs/` - Main documentation portal and overview
- `/pse-docs/` - Proxy Structuring Engine (PSE) documentation
- `/pba-docs/` - Proxy Base Agent (PBA) documentation
- `/assets/` - Shared images and resources
- `/build.sh` - Script to build all documentation
- `/serve.sh` - Script to serve the documentation locally

## Local Development

### Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

### Setup

```bash
# Clone the repository
git clone https://github.com/TheProxyCompany/proxy-technical-docs.git
cd proxy-technical-docs

# Install dependencies
pip install -r requirements.txt
```

### Running the Documentation

```bash
# Serve all documentation with proper subpath routing
./serve.sh
```

This will build the entire documentation site and serve it at http://localhost:8000 with:
- Main docs at `/`
- PSE docs at `/pse/`
- PBA docs at `/pba/`

### Individual Documentation Sites

You can also work on each documentation site individually:

```bash
# Main documentation portal
cd proxy-technical-docs
mkdocs serve

# PSE documentation
cd proxy-technical-docs/pse-docs
mkdocs serve

# PBA documentation
cd proxy-technical-docs/pba-docs
mkdocs serve
```

## Building for Production

```bash
# Build all documentation for production
./build.sh
```

This will generate static sites in:
- `site/` - Main documentation portal
- `site/pse/` - PSE documentation
- `site/pba/` - PBA documentation

## Deployment

The documentation is automatically deployed via Vercel when changes are pushed to the main branch.

### Manual Deployment

For manual deployment to Vercel:

```bash
# Build for Vercel
./vercel-build.sh

# Deploy to Vercel
vercel --prod
```

## Documentation Guidelines

### File Organization

- Place documentation files in the appropriate `docs/` directory
- Use descriptive filenames with hyphens (e.g., `state-machine.md`)
- Group related files in subdirectories (e.g., `api/`, `guides/`)
- Place common assets in the main `docs/assets/` directory

### Markdown Standards

- Use ATX-style headers with a space after the `#` (e.g., `## Section Title`)
- Include a single H1 (`#`) at the top of each page
- Use fenced code blocks with language specified
- Use relative links for internal documentation
- Use admonitions for important notes and warnings

### Code Examples

- Include comprehensive, working examples
- Add comments explaining key concepts
- Ensure examples follow our Python style guidelines
- Include imports and setup code

## Adding New Content

1. Identify the appropriate section (main, PSE, or PBA)
2. Add your Markdown file to the correct directory
3. Update the navigation in the corresponding `mkdocs.yml` file
4. Test your changes with the serve script
5. Submit a pull request for review

## Editing the Navigation

The navigation structure is defined in each `mkdocs.yml` file:

```yaml
nav:
  - Home: index.md
  - Introduction:
    - Overview: introduction/overview.md
    - Key Features: introduction/key-features.md
  # Add your sections here
```

## Troubleshooting

- **CSS not updating**: Clear your browser cache or use incognito mode
- **Navigation issues**: Check the indentation in your `mkdocs.yml` file
- **Build failures**: Ensure all referenced files exist and links are correct
- **Localhost unavailable**: Check if another process is using port 8000

## Contact

For questions or issues with the documentation:
- Submit an issue on GitHub
- Contact the documentation team at docs@theproxycompany.com