#!/bin/sh
cd "$(dirname "$0")"

# ── Colors ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Install Python if missing ───────────────────────────────────────────────

if ! python3 --version >/dev/null 2>&1; then
    printf "\n"
    printf "  ${CYAN}========================================${NC}\n"
    printf "  ${CYAN}  PROF404 AI - Installing Python...${NC}\n"
    printf "  ${CYAN}========================================${NC}\n"
    printf "\n"

    dpkg --configure -a 2>/dev/null
    apt update -y 2>/dev/null
    apt upgrade -y 2>/dev/null
    apt install -y python 2>/dev/null

    if ! python3 --version >/dev/null 2>&1; then
        printf "  ${RED}[!] Python install failed${NC}\n"
        printf "  Run: dpkg --configure -a && apt update && apt install python -y\n"
        exit 1
    fi

    printf "  ${GREEN}[✓]${NC} Python installed\n\n"
fi

# ── Install pip packages if missing ─────────────────────────────────────────

if ! python3 -c "import flask" 2>/dev/null; then
    printf "  Installing dependencies (first time only)...\n"
    dpkg --configure -a 2>/dev/null
    apt install -y python-cryptography poppler 2>/dev/null
    pip install flask requests --quiet 2>/dev/null
    pip install cryptography --quiet 2>/dev/null || true
    pip install Pillow --quiet 2>/dev/null || true
    printf "  ${GREEN}[✓]${NC} Dependencies ready\n\n"
fi

# Ensure poppler (pdftotext) is installed
if ! command -v pdftotext >/dev/null 2>&1; then
    printf "  Installing PDF support...\n"
    apt install -y poppler 2>/dev/null
    printf "  ${GREEN}[✓]${NC} PDF support ready\n\n"
fi

# ── Launch app ──────────────────────────────────────────────────────────────

printf "\n"
printf "  ${CYAN}========================================${NC}\n"
printf "  ${CYAN}  PROF404 AI - Advanced Chat Assistant${NC}\n"
printf "  ${CYAN}  Built by @PROFESSOR4O4${NC}\n"
printf "  ${CYAN}========================================${NC}\n"
printf "\n"

LOCAL_IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="localhost"
fi

printf "  Open on this device: http://localhost:8080\n"
printf "  Open on other devices: http://${LOCAL_IP}:8080\n"
printf "\n"
printf "  Press Ctrl+C to stop\n"
printf "\n"

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
