#!/bin/bash
set -e

# Set default project
PROJECT=${1:-main}

# Determine Python command
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
else
    PYTHON_CMD="python"
fi
echo "Using Python command: $PYTHON_CMD"

# Define port based on project
case $PROJECT in
    main)
        PORT=8000
        PROJECT_DIR="."
        PROJECT_NAME="Public Documentation"
        ;;
    all)
        echo "=====================================================
Building and serving the public documentation site...
=====================================================

This serves the same public docs bundle that is deployed to docs.theproxycompany.com.
"

        # First build everything to the combined site directory
        echo "Building all documentation sites..."

        # Ensure assets are available for build
        if [ -d "assets" ]; then
          echo "Assets directory found, will be included in the build"
        else
          echo "Warning: assets directory not found. Some images may be missing in the documentation."
        fi

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
        echo "Usage: $0 [main|all]"
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
if [ -x ".venv/bin/mkdocs" ]; then
    .venv/bin/mkdocs serve -a 0.0.0.0:$PORT
else
    mkdocs serve -a 0.0.0.0:$PORT
fi
