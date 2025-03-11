#!/bin/bash

# Check if mkdocs is installed
if ! command -v mkdocs &> /dev/null; then
    echo "mkdocs is not installed. Installing required packages..."
    pip install mkdocs mkdocs-material pymdown-extensions mkdocstrings
fi

# Serve the documentation
echo "Starting documentation server at http://localhost:8000"
echo "Press Ctrl+C to stop"
mkdocs serve