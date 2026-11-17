#!/usr/bin/env bash

# ==========================================
# NotVulkan - Uninstallation Script (uninstall.sh)
# ==========================================

echo "[*] Starting NotVulkan uninstallation..."

INSTALL_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

# 1. Remove the NotVulkan runner script
if [ -f "$INSTALL_DIR/notvulkan" ]; then
    rm -f "$INSTALL_DIR/notvulkan"
    echo "[+] Removed runner script ($INSTALL_DIR/notvulkan)."
else
    echo "[-] Runner script not found, skipping."
fi

# 2. Remove the Desktop / Right-Click entry
if [ -f "$APP_DIR/notvulkan.desktop" ]; then
    rm -f "$APP_DIR/notvulkan.desktop"
    echo "[+] Removed desktop integration ($APP_DIR/notvulkan.desktop)."
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$APP_DIR" &> /dev/null
    fi
else
    echo "[-] Desktop integration file not found, skipping."
fi

# 3. Optional: Ask user before deleting Wine prefixes
echo ""
echo "[!] Warning: Removing Wine prefixes (~/.wine32 and ~/.wine64) will delete any games or saves stored inside them."
read -p "Do you want to remove the Wine prefixes as well? (y/N): " REMOVE_PREFIXES

if [[ "$REMOVE_PREFIXES" =~ ^[Yy]$ ]]; then
    echo "[*] Stopping active Wine processes..."
    WINEPREFIX="$HOME/.wine64" wineserver -k &> /dev/null
    WINEPREFIX="$HOME/.wine32" wineserver -k &> /dev/null

    if [ -d "$HOME/.wine64" ]; then
        rm -rf "$HOME/.wine64"
        echo "[+] Removed ~/.wine64 prefix."
    fi

    if [ -d "$HOME/.wine32" ]; then
        rm -rf "$HOME/.wine32"
        echo "[+] Removed ~/.wine32 prefix."
    fi
else
    echo "[*] Kept ~/.wine32 and ~/.wine64 prefixes intact."
fi

echo ""
echo "[+] NotVulkan has been successfully uninstalled!"
