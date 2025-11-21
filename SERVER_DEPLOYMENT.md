# Server Deployment Guide

## Quick Deployment Workflow

### Method 1: Transfer using scp/rsync (Recommended)

```bash
# On local machine (directory containing full tutorial)
cd /localdata/hli853/JUDIGPT

# Option A: Using scp (simple)
scp -r judiagent_tutorial/ user@server:/path/to/deploy/

# Option B: Using rsync (faster, supports resume)
rsync -avz --progress judiagent_tutorial/ user@server:/path/to/deploy/judiagent_tutorial/

# Note: After transfer, you need to re-run setup.sh on the server
```

### Method 2: Using Git (if version control is set up)

```bash
# On server
cd /path/to/deploy
git clone <repository_url>
cd judiagent_tutorial
./setup.sh
```

## Setup Steps on Server

### Step 1: Transfer Files to Server

```bash
# Using scp
scp -r judiagent_tutorial/ user@server:/path/to/tutorials/

# Or using rsync (recommended, faster)
rsync -avz --exclude='.venv' --exclude='__pycache__' --exclude='*.pyc' \
    judiagent_tutorial/ user@server:/path/to/tutorials/judiagent_tutorial/
```

**Note**: You can exclude `.venv` (virtual environment) during transfer, as it will be recreated on the server.

### Step 2: Install JUDIGPT on Server (if needed)

```bash
# SSH to server
ssh user@server

# If JUDIGPT is not yet on the server, clone it first
cd /path/to/tutorials/
git clone https://github.com/haoyunl2/JUDIGPT.git
cd JUDIGPT/judiagent_tutorial
```

### Step 3: Run Setup on Server

```bash
# Make sure you're in the tutorial directory
cd /path/to/tutorials/JUDIGPT/judiagent_tutorial

# Run setup (needed for first time)
chmod +x setup.sh launch.sh launch_server.sh
./setup.sh
```

**Note**: If the tutorial directory is not inside the JUDIGPT repository, setup.sh will try to automatically find JUDIGPT. If not found, it will prompt you to install it.

### Step 4: Launch Notebook (for Server Environment)

```bash
# Method 1: Using background launch script (suitable for long-running)
./launch_server.sh

# Method 2: Manual launch (can specify port)
source .venv/bin/activate
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root judiagent_tutorial.ipynb

# Method 3: Using nohup to run in background
nohup ./launch_server.sh > jupyter.log 2>&1 &
```

### Step 4: Access via SSH Tunnel (Secure)

```bash
# On local machine, establish SSH tunnel
ssh -L 8888:localhost:8888 user@server

# Then open in local browser
http://localhost:8888
```

## Complete Deployment Command Examples

### Method 1: Transfer Entire JUDIGPT Repository (Recommended, includes full source)

```bash
# ===== Step 1: Prepare on local machine =====
cd /localdata/hli853/JUDIGPT
tar -czf judiagent_tutorial.tar.gz judiagent_tutorial/ --exclude='.venv' --exclude='__pycache__'

# ===== Step 2: Transfer to server =====
scp judiagent_tutorial.tar.gz user@server:/path/to/tutorials/

# ===== Step 3: Clone JUDIGPT on server (if not present) =====
ssh user@server
cd /path/to/tutorials
git clone https://github.com/haoyunl2/JUDIGPT.git

# ===== Step 4: Extract and setup on server =====
cd JUDIGPT
tar -xzf ../judiagent_tutorial.tar.gz  # If there's a new version
cd judiagent_tutorial
chmod +x setup.sh launch.sh launch_server.sh
./setup.sh

# ===== Step 5: Start notebook =====
./launch_server.sh
# Or run in background:
# nohup ./launch_server.sh > jupyter.log 2>&1 &

# ===== Step 6: Access from local machine (new terminal) =====
ssh -L 8888:localhost:8888 user@server
# Then open browser: http://localhost:8888
```

### Method 2: Clone JUDIGPT Only on Server (Simpler)

```bash
# ===== Clone directly on server =====
ssh user@server
cd /path/to/tutorials
git clone https://github.com/haoyunl2/JUDIGPT.git
cd JUDIGPT/judiagent_tutorial

# ===== Run setup =====
chmod +x setup.sh launch.sh launch_server.sh
./setup.sh

# ===== Start notebook =====
./launch_server.sh
```

## FAQ

### Q: Can I use the original workflow?

**A: Yes!** The original workflow is fully applicable:

1. **Clone JUDIGPT**: `git clone https://github.com/haoyunl2/JUDIGPT.git`
2. **Transfer files**: Use scp/rsync/git (or clone directly on server)
3. **Run setup.sh on server**: Will automatically install all dependencies (including auto-finding JUDIGPT)
4. **Start notebook**: 
   - Local access: Use `./launch.sh`
   - Server access: Use `./launch_server.sh` (supports remote)

### Q: Do I need to transfer virtual environment (.venv)?

**A: No.**
- Virtual environments are machine-specific and should be recreated on the server
- Excluding `.venv` directory during transfer speeds up the transfer

### Q: How to share with multiple users?

**Option A: Each user runs their own setup**
```bash
# Each user in their own directory
cp -r /path/to/tutorials/judiagent_tutorial ~/my_tutorial
cd ~/my_tutorial
./setup.sh
```

**Option B: Shared virtual environment**
```bash
# Administrator creates shared environment
python3 -m venv /shared/judiagent_venv
source /shared/judiagent_venv/bin/activate
pip install -r requirements.txt
pip install -e /path/to/JUDIGPT

# Users only need to activate shared environment
source /shared/judiagent_venv/bin/activate
jupyter notebook judiagent_tutorial.ipynb
```

### Q: What if port is already in use?

```bash
# Use a different port
JUPYTER_PORT=8889 ./launch_server.sh

# Or modify the PORT variable in launch_server.sh
```

### Q: How to run in background and view logs?

```bash
# Run in background
nohup ./launch_server.sh > jupyter.log 2>&1 &

# View logs
tail -f jupyter.log

# Check process
ps aux | grep jupyter

# Stop
pkill -f "jupyter notebook"
```

## Security Considerations

If the server is exposed to the public internet, it's recommended to:

1. **Set Jupyter password**:
```bash
jupyter notebook password
```

2. **Use token access**:
   - Jupyter will automatically generate a token, displayed when starting
   - Or generate manually: `jupyter notebook list`

3. **Restrict IP access** (modify launch_server.sh):
```bash
--ip=127.0.0.1  # Only allow localhost, access via SSH tunnel
```

4. **Use firewall**: Only allow specific IPs to access Jupyter port
