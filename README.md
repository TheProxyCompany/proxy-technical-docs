# The Proxy Company Documentation

Technical documentation for The Proxy Company's products and technology.

## Structure

- `/docs/` - Main landing page and overview
- `/pse-docs/` - Proxy Structuring Engine documentation
- `/pba-docs/` - Proxy Base Agent documentation

## Local Development

**Requirements:** Python 3.8+

```bash
# Install dependencies
pip install -r requirements.txt

# Run the documentation locally
./serve.sh
```

This will build the entire documentation site and serve it at http://localhost:8000 with:
- Main docs at `/`
- PSE docs at `/pse/`
- PBA docs at `/pba/`

## Options

```bash
# Serve all documentation
./serve.sh
```

```bash
# Build all documentation
./build.sh
```
