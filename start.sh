#!/bin/bash
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo ""
echo -e "${CYAN}  ========================================${NC}"
echo -e "${CYAN}       PROF404 AI${NC}"
echo -e "${CYAN}  ========================================${NC}"
echo ""

# Move to app folder if files are in current dir
if [ -f "app.py" ] && [ -d "static" ]; then
    mkdir -p ~/prof404ai
    cp -r ./* ~/prof404ai/ 2>/dev/null
    cd ~/prof404ai
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Auto install if first time
if ! python3 -c "import flask" 2>/dev/null; then
    echo "  Installing packages (first time only)..."
    echo ""

    # Update packages
    pkg update -y 2>/dev/null

    # Install Python
    pkg install -y python 2>/dev/null

    # Install cryptography from Termux repo (pip version fails on Termux)
    pkg install -y python-cryptography 2>/dev/null

    # Install other packages via pip
    pip install flask requests Pillow --quiet 2>/dev/null

    echo ""
    echo -e "  ${GREEN}[✓]${NC} Setup complete"
    echo ""
fi

# Get IP
LOCAL_IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
[ -z "$LOCAL_IP" ] && LOCAL_IP="localhost"

echo -e "  ${GREEN}[✓]${NC} Starting PROF404 AI..."
echo ""
echo "  ───────────────────────────────────"
echo "  📱 This phone:   http://localhost:8080"
echo "  📱 Other device: http://${LOCAL_IP}:8080"
echo "  ───────────────────────────────────"
echo ""
echo "  Press Ctrl+C to stop"
echo ""

# Try compiled first, fallback to source
if [ -f "app.so" ]; then
    python3 -c "
import importlib.util, sys, os
sys.argv = ['app']
spec = importlib.util.spec_from_file_location('app', os.path.join('$SCRIPT_DIR', 'app.so'))
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
if hasattr(mod, 'main'): mod.main()
"
elif [ -f "app.py" ]; then
    python3 app.py
else
    echo "  [!] app.so or app.py not found!"
fi
