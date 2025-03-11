#!/bin/bash
set -e

# Set default project to all
PROJECT=${1:-all}

# Determine Python command
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
else
    PYTHON_CMD="python"
fi
echo "Using Python command: $PYTHON_CMD"

# Check if mkdocs is installed
if ! command -v mkdocs &> /dev/null; then
    echo "mkdocs is not installed. Installing required packages..."
    $PYTHON_CMD -m pip install -r requirements.txt || {
        echo "Failed to install dependencies from requirements.txt"
        echo "Falling back to manual installation..."
        $PYTHON_CMD -m pip install mkdocs mkdocs-material mkdocs-material-extensions pymdown-extensions
    }
fi

# Define port based on project
case $PROJECT in
    main)
        PORT=8000
        PROJECT_DIR="."
        PROJECT_NAME="Main Documentation"
        ;;
    pse)
        PORT=8001
        PROJECT_DIR="pse-docs"
        PROJECT_NAME="PSE Documentation"
        ;;
    pba)
        PORT=8002
        PROJECT_DIR="pba-docs"
        PROJECT_NAME="PBA Documentation"
        ;;
    all)
        echo "=====================================================
Building and serving the complete documentation site...
=====================================================

This will build all documentation sites and serve them as they would appear
on the deployed Vercel site, with:
- Main docs at http://localhost:8000/
- PSE docs at http://localhost:8000/pse/
- PBA docs at http://localhost:8000/pba/
"

        # First build everything to the combined site directory
        echo "Building all documentation sites..."
        ./build.sh

        # Now serve the combined site directory
        echo "
=====================================================
Serving the combined documentation site at http://localhost:8000
Press Ctrl+C to stop the server
=====================================================
"
        cd site
        $PYTHON_CMD -m http.server 8000
        exit 0
        ;;
    *)
        echo "Unknown project: $PROJECT"
        echo "Usage: $0 [main|pse|pba|all]"
        exit 1
        ;;
esac

# Check if port is in use and kill the process if necessary
if lsof -i :$PORT -t &> /dev/null; then
    echo "Port $PORT is in use. Terminating the process..."
    # Find and kill the process using the port
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

# Change to project directory if not main
cd $PROJECT_DIR

# Serve the documentation
echo "Starting $PROJECT_NAME server at http://localhost:$PORT"
echo "Press Ctrl+C to stop"
mkdocs serve -a 0.0.0.0:$PORT
