#!/bin/sh
cd "$(dirname "$0")"

# ── Install Python if missing ───────────────────────────────────────────────

if ! which python3 >/dev/null 2>&1; then
    echo ""
    echo "  ========================================"
    echo "    PROF404 AI - Installing Python..."
    echo "  ========================================"
    echo ""

    dpkg --configure -a 2>/dev/null
    apt update -y 2>/dev/null
    apt upgrade -y 2>/dev/null
    apt install -y python 2>/dev/null

    if ! which python3 >/dev/null 2>&1; then
        echo "  [!] Python install failed"
        echo "  Run: dpkg --configure -a && apt update && apt install python -y"
        exit 1
    fi

    echo "  [OK] Python installed"
    echo ""
fi

# ── Install pip packages if missing ─────────────────────────────────────────

if ! python3 -c "import flask" 2>/dev/null; then
    echo "  Installing dependencies (first time only)..."
    dpkg --configure -a 2>/dev/null
    apt install -y python-cryptography poppler 2>/dev/null
    pip install flask requests --quiet 2>/dev/null
    pip install cryptography --quiet 2>/dev/null || true
    pip install Pillow --quiet 2>/dev/null || true
    echo "  [OK] Dependencies ready"
    echo ""
fi

# ── Launch app ──────────────────────────────────────────────────────────────

echo ""
echo "  ========================================"
echo "    PROF404 AI - Advanced Chat Assistant"
echo "    Built by @PROFESSOR4O4"
echo "  ========================================"
echo ""

LOCAL_IP=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="localhost"
fi

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
