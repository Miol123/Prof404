#!/bin/bash
cd "$(dirname "$0")"

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Install Python if missing ───────────────────────────────────────────────

if ! command -v python3 &> /dev/null; then
    echo ""
    echo -e "${CYAN}  ========================================${NC}"
    echo -e "${CYAN}    PROF404 AI - Installing Python...${NC}"
    echo -e "${CYAN}  ========================================${NC}"
    echo ""

    # Fix broken dpkg state (common after interrupted installs)
    dpkg --configure -a 2>/dev/null

    # Update and install
    apt update -y 2>/dev/null
    apt upgrade -y 2>/dev/null
    apt install -y python 2>/dev/null

    if ! command -v python3 &> /dev/null; then
        echo -e "  ${RED}[!] Python install failed${NC}"
        echo "  Run this manually then try again:"
        echo "  dpkg --configure -a && apt update && apt install python -y"
        exit 1
    fi

    echo -e "  ${GREEN}[✓]${NC} Python installed"
    echo ""
fi

# ── Install pip packages if missing ─────────────────────────────────────────

check_pkg() {
    python3 -c "import $1" 2>/dev/null
    return $?
}

MISSING=0
check_pkg flask || MISSING=1
check_pkg requests || MISSING=1

if [ "$MISSING" -eq 1 ]; then
    echo "  Installing dependencies (first time only)..."
    dpkg --configure -a 2>/dev/null
    apt install -y python-cryptography 2>/dev/null  # Termux-specific
    pip install flask requests --quiet 2>/dev/null
    pip install cryptography --quiet 2>/dev/null || true
    pip install Pillow --quiet 2>/dev/null || true
    echo -e "  ${GREEN}[✓]${NC} Dependencies ready"
    echo ""
fi

# ── Launch app ──────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}  ========================================${NC}"
echo -e "${CYAN}    PROF404 AI - Advanced Chat Assistant${NC}"
echo -e "${CYAN}    Built by @PROFESSOR4O4${NC}"
echo -e "${CYAN}  ========================================${NC}"
echo ""

LOCAL_IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
[ -z "$LOCAL_IP" ] && LOCAL_IP="localhost"

echo "  Open on this device: http://localhost:8080"
echo "  Open on other devices: http://${LOCAL_IP}:8080"
echo ""
echo "  Press Ctrl+C to stop"
echo ""

if [ -f "app.so" ]; then
    python3 -c "
import importlib.util, sys
sys.argv = ['app']
spec = importlib.util.spec_from_file_location('app', '$(pwd)/app.so')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
if hasattr(mod, 'main'): mod.main()
"
else
    python3 app.py
fi
