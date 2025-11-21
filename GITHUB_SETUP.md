# GitHub Repository Setup Guide

This folder is designed to be a standalone public GitHub repository for the JUDIAgent Tutorial.

## Quick Setup Instructions

### For Users (on Server)

```bash
# 1. Clone the tutorial repository
git clone https://github.com/haoyunl2/judiagent-tutorial.git
cd judiagent-tutorial

# 2. Clone JUDIGPT (required dependency)
cd ..
git clone https://github.com/haoyunl2/JUDIGPT.git
cd judiagent-tutorial

# 3. Run setup
chmod +x setup.sh
./setup.sh

# 4. Launch notebook
./launch_server.sh
```

### For Repository Maintainer

```bash
# 1. Move this folder to a new location (outside JUDIGPT repo)
cd /localdata/hli853/JUDIGPT
mv judiagent_tutorial /path/to/standalone/repo/judiagent-tutorial
cd /path/to/standalone/repo/judiagent-tutorial

# 2. Initialize git repository
git init
git add .
git commit -m "Initial commit: JUDIAgent Tutorial"

# 3. Create GitHub repository
# Go to https://github.com/new
# Repository name: judiagent-tutorial
# Visibility: Public
# Do NOT initialize with README (we already have one)

# 4. Push to GitHub
git remote add origin https://github.com/haoyunl2/judiagent-tutorial.git
git branch -M main
git push -u origin main
```

## Directory Structure

After setup on server, users will have:

```
~
├── judiagent-tutorial/          # This repository (cloned)
│   ├── judiagent_tutorial.ipynb
│   ├── requirements.txt
│   ├── Project.toml
│   ├── setup.sh
│   └── ...
│
└── JUDIGPT/                     # JUDIGPT repository (cloned separately)
    ├── src/
    ├── setup.py
    └── ...
```

The `setup.sh` script will automatically detect JUDIGPT in parent or sibling directory.

## Notes

- This repository is **standalone** and can be used independently
- JUDIGPT must be cloned separately as it's a dependency
- The setup script will automatically find and install JUDIGPT
- All environment files (.venv, .env, etc.) are gitignored
- Generated images (*.png) are gitignored (will be created when running notebook)
