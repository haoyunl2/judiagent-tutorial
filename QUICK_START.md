# Quick Start Guide

## On Server - One Command Setup

```bash
# Clone both repositories and setup (one-liner)
git clone https://github.com/haoyunl2/judiagent-tutorial.git && \
git clone https://github.com/haoyunl2/JUDIGPT.git && \
cd judiagent-tutorial && \
chmod +x setup.sh && \
./setup.sh && \
./launch_server.sh
```

## Step-by-Step (Recommended)

### Step 1: Clone Repositories

```bash
# Clone tutorial repository
git clone https://github.com/haoyunl2/judiagent-tutorial.git
cd judiagent-tutorial

# Clone JUDIGPT (required dependency) - in parent directory
cd ..
git clone https://github.com/haoyunl2/JUDIGPT.git
cd judiagent-tutorial
```

### Step 2: Run Setup

```bash
# Make scripts executable
chmod +x setup.sh launch.sh launch_server.sh

# Run automated setup (will detect JUDIGPT automatically)
./setup.sh
```

### Step 3: Launch Notebook

```bash
# For server/remote access
./launch_server.sh

# Or for local access
./launch.sh
```

### Step 4: Access Notebook

- **Local access**: Open browser to `http://localhost:8888`
- **Remote access**: 
  - Use SSH tunnel: `ssh -L 8888:localhost:8888 user@server`
  - Then open: `http://localhost:8888`

## What Setup Script Does

1. ✅ Checks Python version (requires 3.9+, recommends 3.12+)
2. ✅ Checks Julia version (requires 1.11+)
3. ✅ Creates Python virtual environment (`.venv`)
4. ✅ Installs Python dependencies from `requirements.txt`
5. ✅ Automatically finds and installs JUDIGPT from:
   - `../JUDIGPT/` (parent directory)
   - `../../JUDIGPT/` (sibling directory)
6. ✅ Sets up Julia environment from `Project.toml`
7. ✅ Registers Jupyter kernel
8. ✅ Creates `.env` file template (if needed)

## Troubleshooting

### JUDIGPT Not Found

If setup can't find JUDIGPT automatically:

```bash
# Specify JUDIGPT path manually
export JUDIGPT_PATH=/path/to/JUDIGPT
./setup.sh
```

### Permission Issues

```bash
# Make sure scripts are executable
chmod +x setup.sh launch.sh launch_server.sh
```

### Python/Julia Version Issues

- **Python**: Requires 3.9+, 3.12+ recommended
- **Julia**: Requires 1.11+
- Check versions: `python3 --version` and `julia --version`
