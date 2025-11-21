#!/bin/bash
# Launch script for JUDIAgent Tutorial on Server
# This script launches Jupyter in a way suitable for SSH/remote access

# Activate virtual environment
if [ -d ".venv" ]; then
    source .venv/bin/activate
else
    echo "ERROR: Virtual environment not found. Run ./setup.sh first."
    exit 1
fi

# Check if Jupyter is installed
if ! command -v jupyter &> /dev/null; then
    echo "ERROR: Jupyter not found. Install with: pip install jupyter"
    exit 1
fi

# Configuration
PORT=${JUPYTER_PORT:-8888}
IP=${JUPYTER_IP:-0.0.0.0}  # 0.0.0.0 allows remote access

echo "=========================================="
echo "JUDIAgent Tutorial - Server Launch"
echo "=========================================="
echo "Port: $PORT"
echo "IP: $IP"
echo "Access URL will be shown below"
echo ""
echo "To access from remote machine:"
echo "  1. SSH tunnel: ssh -L ${PORT}:localhost:${PORT} user@server"
echo "  2. Then open: http://localhost:${PORT}"
echo ""
echo "Press Ctrl+C to stop the server"
echo "=========================================="
echo ""

# Launch Jupyter with server-friendly options
jupyter notebook \
    --ip=$IP \
    --port=$PORT \
    --no-browser \
    --allow-root \
    judiagent_tutorial.ipynb

