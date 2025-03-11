#!/bin/bash

# Check if mkdocs is installed
if ! command -v mkdocs &> /dev/null; then
    echo "mkdocs is not installed. Installing required packages..."
    pip install mkdocs mkdocs-material pymdown-extensions mkdocstrings "mkdocstrings-python"
fi

# Check if port 8000 is in use and kill the process if necessary
PORT=8000
if lsof -i :$PORT -t &> /dev/null; then
    echo "Port $PORT is in use. Terminating the process..."
    # Find and kill the process using port 8000
    kill $(lsof -i :$PORT -t) 2>/dev/null || sudo kill $(lsof -i :$PORT -t) 2>/dev/null

    # Verify the port is now available
    sleep 1
    if lsof -i :$PORT -t &> /dev/null; then
        echo "Failed to terminate the process. Please close it manually."
        exit 1
    else
        echo "Process terminated successfully."
    fi
fi


# Serve the documentation
echo "Starting documentation server at http://localhost:8000"
echo "Press Ctrl+C to stop"
mkdocs serve
