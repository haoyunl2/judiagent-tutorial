#!/bin/bash
# Setup script for JUDIAgent Tutorial
# This script sets up both Python and Julia environments

set -e  # Exit on error

echo "=========================================="
echo "JUDIAgent Tutorial Setup"
echo "=========================================="

# Check Python version - prefer Python 3.13, fallback to 3.12/3.11/3.10
echo "Checking Python version..."
shopt -s nullglob
preferred_versions=("3.13" "3.12" "3.11" "3.10")
PYTHON_CMD=""
for ver in "${preferred_versions[@]}"; do
    if command -v python${ver} &> /dev/null; then
        PYTHON_CMD=$(command -v python${ver})
        break
    fi
    candidates=("$HOME/.local/share/uv/python/cpython-${ver}"*/bin/python${ver})
    for candidate in "${candidates[@]}"; do
        if [ -x "$candidate" ]; then
            PYTHON_CMD="$candidate"
            break 2
        fi
    done
done
shopt -u nullglob

if [ -z "$PYTHON_CMD" ]; then
    if command -v python3 &> /dev/null; then
        PYTHON_CMD=$(command -v python3)
    else
        echo "ERROR: Python 3.10+ not found. Please install Python 3.13+ (recommended) or 3.10+"
        exit 1
    fi
fi

PYTHON_PREFIX=""
NEEDS_PYTHONHOME=0
if [[ "$PYTHON_CMD" == *".local/share/uv/python/"* ]]; then
    PYTHON_PREFIX=$(dirname "$(dirname "$PYTHON_CMD")")
    NEEDS_PYTHONHOME=1
    export PYTHONHOME="$PYTHON_PREFIX"
    echo "Detected uv-managed Python. Will export PYTHONHOME=$PYTHON_PREFIX when needed."
fi

python_version=$("$PYTHON_CMD" --version 2>&1 | awk '{print $2}')
echo "Python version: $python_version (using $PYTHON_CMD)"

# Warn if Python < 3.12
python_major=$(echo $python_version | cut -d. -f1)
python_minor=$(echo $python_version | cut -d. -f2)
if [ "$python_major" -eq 3 ] && [ "$python_minor" -lt 12 ]; then
    echo "WARNING: Python 3.12+ recommended. Found: $python_version"
    echo "         Some dependencies may have compatibility issues. Proceeding anyway..."
fi

# Check Julia
echo "Checking Julia..."
if command -v julia &> /dev/null; then
    julia_version=$(julia --version | awk '{print $3}')
    echo "Julia version: $julia_version"
else
    echo "ERROR: Julia not found. Please install Julia 1.11+"
    exit 1
fi

# Setup Python environment
echo ""
echo "=========================================="
echo "Setting up Python environment..."
echo "=========================================="

# Use uv only if explicitly requested via USE_UV=true environment variable
# Default: use standard pip (for server compatibility)
USE_UV=${USE_UV:-false}
if [ "$USE_UV" = "true" ]; then
    if ! command -v uv &> /dev/null; then
        echo "WARNING: USE_UV=true but uv not found. Falling back to pip."
        USE_UV=false
    else
        echo "Using uv for faster installation (explicitly requested)..."
    fi
else
    echo "Using standard pip (set USE_UV=true to use uv if available)..."
fi

if [ -d ".venv" ]; then
    echo "Virtual environment already exists. Activating..."
    source .venv/bin/activate
else
    echo "Creating Python virtual environment..."
    if [ "$USE_UV" = true ]; then
        uv venv --python $PYTHON_CMD
        source .venv/bin/activate
    else
        # Always use standard venv (no uv)
        VENV_ARGS=""
        if [ "$NEEDS_PYTHONHOME" -eq 1 ] && $PYTHON_CMD -m venv -h 2>&1 | grep -q -- "--without-pip"; then
            VENV_ARGS="--without-pip"
            echo "Using --without-pip (ensurepip unavailable for this Python build)..."
        fi
        $PYTHON_CMD -m venv $VENV_ARGS .venv
        source .venv/bin/activate
        if [ "$NEEDS_PYTHONHOME" -eq 1 ]; then
            export PYTHONHOME="$PYTHON_PREFIX"
        fi
        if ! python -m pip --version >/dev/null 2>&1; then
            echo "Installing pip inside virtual environment..."
            curl -sS https://bootstrap.pypa.io/get-pip.py | python
        fi
    fi
fi

if [ "$NEEDS_PYTHONHOME" -eq 1 ]; then
    export PYTHONHOME="$PYTHON_PREFIX"
    echo "$PYTHON_PREFIX" > .venv/.pythonhome
else
    rm -f .venv/.pythonhome 2>/dev/null || true
fi

ACTIVATE_FILE=".venv/bin/activate"
if [ -f "$ACTIVATE_FILE" ] && ! grep -q "JUDIAgent PYTHONHOME hook" "$ACTIVATE_FILE"; then
cat <<'EOF' >> "$ACTIVATE_FILE"

# JUDIAgent PYTHONHOME hook
if [ -f "$VIRTUAL_ENV/.pythonhome" ]; then
    export PYTHONHOME="$(cat "$VIRTUAL_ENV/.pythonhome")"
else
    unset PYTHONHOME
fi
EOF
fi

if ! python -m pip --version >/dev/null 2>&1; then
    echo "Installing pip inside virtual environment..."
    curl -sS https://bootstrap.pypa.io/get-pip.py | python
fi

echo "Upgrading pip..."
if [ "$USE_UV" = true ]; then
    uv pip install --upgrade pip
else
    python -m pip install --upgrade pip
fi

echo "Installing Python dependencies..."
if [ "$USE_UV" = true ]; then
    uv pip install -r requirements.txt
else
    python -m pip install -r requirements.txt
fi

echo "Installing JUDIGPT package..."
# Check if JUDIGPT exists in parent directory
if [ -d "../JUDIGPT/src/judigpt" ]; then
    echo "Found JUDIGPT in parent directory, installing..."
    if [ "$USE_UV" = true ]; then
        uv pip install -e ../
    else
        python -m pip install -e ../JUDIGPT
    fi
    echo "✓ JUDIGPT installed from parent directory"
# Check if JUDIGPT exists as a sibling directory
elif [ -d "../../JUDIGPT/src/judigpt" ]; then
    echo "Found JUDIGPT as sibling directory, installing..."
    if [ "$USE_UV" = true ]; then
        uv pip install -e ../../
    else
        python -m pip install -e ../../JUDIGPT
    fi
    echo "✓ JUDIGPT installed from sibling directory"
# Check if it's already installed via pip
elif python -c "import judigpt" 2>/dev/null; then
    echo "✓ JUDIGPT is already installed via pip"
else
    echo ""
    echo "WARNING: JUDIGPT source not found in expected locations."
    echo ""
    echo "Options to install JUDIGPT:"
    echo "  1. Clone JUDIGPT repository:"
    echo "     cd .."
    echo "     git clone https://github.com/haoyunl2/JUDIGPT.git"
    echo "     cd JUDIGPT"
    echo "     # Then re-run this setup script"
    echo ""
    echo "  2. Or install from parent/sibling directory if JUDIGPT exists:"
    echo "     pip install -e /path/to/JUDIGPT"
    echo ""
    echo "  3. Or install directly from GitHub (if available as pip package):"
    echo "     pip install judigpt  # if published"
    echo ""
    read -p "Continue anyway? Some tutorial features may not work. [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup aborted. Please install JUDIGPT first."
        exit 1
    fi
    echo "Continuing without JUDIGPT installation..."
fi

# Register Jupyter kernel
echo ""
echo "Registering Jupyter kernel..."
# Install ipykernel if not already installed
if ! python -c "import ipykernel" 2>/dev/null; then
    echo "Installing ipykernel..."
    if [ "$USE_UV" = true ]; then
        uv pip install ipykernel
    else
        python -m pip install ipykernel
    fi
fi

if python -c "import ipykernel" 2>/dev/null; then
    python -m ipykernel install --user --name judiagent_tutorial --display-name "Python (judiagent_tutorial)" || true
    echo "✓ Jupyter kernel registered (refresh Jupyter to see it)"
else
    echo "Note: Could not register Jupyter kernel. Install manually: pip install ipykernel"
fi

# Setup Julia environment
echo ""
echo "=========================================="
echo "Setting up Julia environment..."
echo "=========================================="

echo "Installing Julia packages..."
julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate(); println("✓ Julia packages installed")'

# Check for .env file
echo ""
echo "=========================================="
echo "Environment Configuration"
echo "=========================================="

if [ ! -f ".env" ]; then
    echo "WARNING: .env file not found."
    echo "Create .env file with:"
    echo "  OPENAI_API_KEY=your_key_here"
    echo "  LANGSMITH_API_KEY=your_key_here  # Optional"
    if [ -f "../.env.example" ]; then
        echo "Copying .env.example from parent directory..."
        cp ../.env.example .env
        echo "✓ .env file created. Please edit it with your API keys."
    fi
else
    echo "✓ .env file found"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "To start the tutorial:"
echo "  1. Activate virtual environment: source .venv/bin/activate"
echo "  2. Start Jupyter: jupyter notebook judiagent_tutorial.ipynb"
echo ""
echo "Or use the provided launch script: ./launch.sh"
echo ""
echo "In Jupyter, select kernel: Kernel → Change Kernel → Python (judiagent_tutorial)"
echo ""

