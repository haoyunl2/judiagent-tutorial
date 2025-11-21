# JUDIAgent Tutorial

This tutorial demonstrates how to use JUDI.jl and JUDIGPT for intelligent workflow automation in seismic modeling and inversion.

## Prerequisites

- **Python 3.13+** (script will install/manage via `uv python`)  
- **uv** package manager: <https://docs.astral.sh/uv/getting-started/installation/>
- **Julia 1.11+**: Required for JUDI.jl
- **JUDIGPT**: Must be cloned from GitHub repository

## Setup Instructions

### Automated Setup (Recommended)

The easiest way to set up the tutorial environment:

**Step 0: Clone This Repository and JUDIGPT**

```bash
# Clone this tutorial repository
git clone https://github.com/haoyunl2/judiagent-tutorial.git
cd judiagent-tutorial

# Clone JUDIGPT repository (required dependency)
cd ..
git clone https://github.com/haoyunl2/JUDIGPT.git
cd judiagent-tutorial

# Make setup script executable (first time only)
chmod +x setup.sh

# Run automated setup (requires uv)
./setup.sh
```

The setup script will automatically detect JUDIGPT in the parent directory or sibling directory. If JUDIGPT is in a different location, it will prompt you to specify the path.

This script will:
- Ensure Python 3.13.9 is available via `uv python` and create a `.venv`
- Install all Python dependencies from `requirements.txt`
- **Automatically detect and install JUDIGPT** from:
  - Parent directory (`../JUDIGPT/`)
  - Sibling directory (`../../JUDIGPT/`)
  - Or prompt you to install it
- Check Julia version (requires 1.11+)
- Set up Julia environment from `Project.toml`
- Register Jupyter kernel automatically
- Help configure `.env` file if needed
  
**Note**: `uv` is now the default package manager. Make sure it is on your `PATH` before running `./setup.sh`.

### Manual Setup

If you prefer to set up manually, follow these steps:

#### Step 1: Install Python Dependencies

Choose one of the following methods:

##### Option A: Using pip (Standard)

```bash
# Create a virtual environment
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Upgrade pip
pip install --upgrade pip

# Install Python dependencies
pip install -r requirements.txt

# Install JUDIGPT package
# Option 1: If JUDIGPT is in parent directory
pip install -e ../  # from JUDIGPT/judiagent_tutorial/

# Option 2: If JUDIGPT is in a different location
pip install -e /path/to/JUDIGPT

# Option 3: Clone JUDIGPT first if you haven't
cd ..
git clone https://github.com/haoyunl2/JUDIGPT.git
cd judiagent_tutorial
pip install -e ../

# Register Jupyter kernel
pip install ipykernel
python -m ipykernel install --user --name judiagent_tutorial --display-name "Python (judiagent_tutorial)"
```

##### Option B: Using uv (Faster, if available)

```bash
# Create virtual environment
uv venv
source .venv/bin/activate

# Install dependencies
uv pip install -r requirements.txt
uv pip install -e ../  # Install JUDIGPT (assuming parent directory)
# Or: uv pip install -e /path/to/JUDIGPT

# Register Jupyter kernel
uv pip install ipykernel
python -m ipykernel install --user --name judiagent_tutorial --display-name "Python (judiagent_tutorial)"
```

#### Step 2: Install Julia Dependencies

```bash
# Start Julia REPL
julia

# In Julia REPL:
julia> import Pkg
julia> Pkg.activate(".")
julia> Pkg.instantiate()
```

Or in one command:

```bash
julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate()'
```

This will install all Julia packages listed in `Project.toml`:
- JUDI.jl (seismic modeling and inversion)
- LinearAlgebra (standard library)
- Random (standard library)
- Statistics (standard library)

### Step 3: Configure Environment Variables

Create a `.env` file in this directory (or use the one from parent JUDIGPT directory):

```bash
# Copy from parent directory if exists
cp ../.env.example .env  # if exists

# Or create manually:
echo "OPENAI_API_KEY=your_key_here" > .env
echo "LANGSMITH_API_KEY=your_key_here" >> .env  # Optional, for UI
```

### Step 3: Launch Jupyter Notebook

#### Option A: Using Launch Script (Recommended)

```bash
# Make launch script executable (first time only)
chmod +x launch.sh

# Launch tutorial
./launch.sh
```

#### Option B: Manual Launch

```bash
# Make sure virtual environment is activated
source .venv/bin/activate

# Start Jupyter
jupyter notebook judiagent_tutorial.ipynb
```

Or use JupyterLab:

```bash
jupyter lab judiagent_tutorial.ipynb
```

**Important**: In your Jupyter notebook, select the correct kernel:
- **Kernel → Change Kernel → Python (judiagent_tutorial)**

## Tutorial Structure

1. **Part 1: Core Design of JUDI** - Learn JUDI.jl basics with working examples
2. **Part 2: JUDIAgent Framework** - Use JUDIGPT agent to generate code automatically
3. **Part 3: Adaptive Experiment Configuration** - Adaptive configuration based on simulation feedback

## Troubleshooting

### Python Issues

- **Import Error**: Make sure JUDIGPT is installed: `pip install -e ../`
- **Kernel Not Found**: Run setup script again or manually register: `python -m ipykernel install --user --name judiagent_tutorial`
- **Python version error**: Ensure Python 3.12+ is installed: `python3 --version`
- **Permission denied**: Make sure virtual environment is activated: `source .venv/bin/activate`

### Julia Issues

- **Package Not Found**: Run `Pkg.instantiate()` in Julia REPL
- **JUDI.jl Error**: Make sure Julia version is 1.11+: `julia --version`

### Environment Issues

- **API Key Error**: Check `.env` file has correct `OPENAI_API_KEY`
- **Permission Denied**: Make sure virtual environment is activated

## Directory Structure

```
judiagent_tutorial/
├── Project.toml          # Julia dependencies
├── requirements.txt      # Python dependencies
├── setup.sh             # Automated setup script
├── launch.sh            # Launch script
├── README.md            # This file
├── SERVER_DEPLOYMENT.md # Server deployment guide
├── .venv/               # Python virtual environment (created by setup)
└── judiagent_tutorial.ipynb  # Tutorial notebook
```

## For Reproducibility

This tutorial uses pinned dependencies to ensure reproducibility:

- **Julia**: Uses `Project.toml` with specific package versions (via Manifest.toml after `Pkg.instantiate()`)
- **Python**: Uses `requirements.txt` with version constraints

To ensure exact reproducibility, after setup:

1. **Julia**: The `Manifest.toml` will be generated automatically with exact versions
2. **Python**: Consider using `pip freeze > requirements-lock.txt` to lock exact versions

## Notes

- **JUDIGPT Installation**: This tutorial requires JUDIGPT to be installed. The setup script will automatically try to find it in common locations:
  - Parent directory: `../JUDIGPT/` (if tutorial is inside JUDIGPT repo)
  - Sibling directory: `../../JUDIGPT/` (if both are siblings)
  - If not found, you'll be prompted to install it manually
  - **To clone JUDIGPT**: `git clone https://github.com/haoyunl2/JUDIGPT.git`
- Some cells may take time to execute (especially first-time Julia package compilation)
- Agent code generation examples can be re-run if they fail

