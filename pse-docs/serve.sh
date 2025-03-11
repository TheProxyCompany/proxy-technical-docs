#!/bin/bash

# Set default project to main
PROJECT=${1:-main}

# Check if mkdocs is installed
if ! command -v mkdocs &> /dev/null; then
    echo "mkdocs is not installed. Installing required packages..."
    pip install mkdocs mkdocs-material pymdown-extensions
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
        echo "Starting all documentation servers..."
        # Start main docs
        $0 main &
        MAIN_PID=$!
        # Start PSE docs
        $0 pse &
        PSE_PID=$!
        # Start PBA docs
        $0 pba &
        PBA_PID=$!
        echo "All documentation servers started!"
        echo "Main docs: http://localhost:8000"
        echo "PSE docs: http://localhost:8001"
        echo "PBA docs: http://localhost:8002"
        echo "Press Ctrl+C to stop all servers"
        
        # Wait for any to exit, then kill all
        wait -n $MAIN_PID $PSE_PID $PBA_PID
        pkill -P $$
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
