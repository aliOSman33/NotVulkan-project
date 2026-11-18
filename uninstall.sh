#!/usr/bin/env bash

# ==========================================
# NotVulkan - Uninstallation Script (uninstall.sh)
# ==========================================

echo "[*] Starting NotVulkan uninstallation..."

INSTALL_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

# 1. Remove the NotVulkan runner script & global CLI symlink
if [ -f "$INSTALL_DIR/notvulkan" ]; then
    rm -f "$INSTALL_DIR/notvulkan"
    echo "[+] Removed runner script ($INSTALL_DIR/notvulkan)."
else
    echo "[-] Runner script not found, skipping."
fi

if [ -L "/usr/local/bin/notvulkan" ] || [ -f "/usr/local/bin/notvulkan" ]; then
    sudo rm -f "/usr/local/bin/notvulkan"
    echo "[+] Removed global CLI command (/usr/local/bin/notvulkan)."
fi

# 2. Remove the Desktop / Right-Click entry
if [ -f "$APP_DIR/notvulkan.desktop" ]; then
    rm -f "$APP_DIR/notvulkan.desktop"
    echo "[+] Removed desktop integration ($APP_DIR/notvulkan.desktop)."
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$APP_DIR" &> /dev/null || true
    fi
else
    echo "[-] Desktop integration file not found, skipping."
fi

# 3. Remove XFCE (Thunar) Custom Action if present
THUNAR_UCA="$HOME/.config/Thunar/uca.xml"
if [ -f "$THUNAR_UCA" ] && grep -q "Run with NotVulkan" "$THUNAR_UCA"; then
    python3 -c '
import xml.etree.ElementTree as ET, os
uca_path = os.path.expanduser("~/.config/Thunar/uca.xml")
tree = ET.parse(uca_path)
root = tree.getroot()
for action in list(root.findall("action")):
    name = action.find("name")
    if name is not None and name.text == "Run with NotVulkan":
        root.remove(action)
tree.write(uca_path, encoding="UTF-8", xml_declaration=True)
' &> /dev/null || true
    echo "[+] Removed Thunar right-click menu entry."
fi

# 4. Optional: Ask user before deleting existing Wine prefixes
if [ -d "$HOME/.wine64" ] || [ -d "$HOME/.wine32" ]; then
    echo ""
    echo "[!] Warning: Removing NotVulkan Wine prefixes (~/.wine64 / ~/.wine32) will delete any games or saves stored inside them."
    read -p "Do you want to remove the Wine prefixes as well? (y/N): " REMOVE_PREFIXES

    if [[ "$REMOVE_PREFIXES" =~ ^[Yy]$ ]]; then
        echo "[*] Stopping active Wine processes..."
        [ -d "$HOME/.wine64" ] && WINEPREFIX="$HOME/.wine64" wineserver -k &> /dev/null || true
        [ -d "$HOME/.wine32" ] && WINEPREFIX="$HOME/.wine32" wineserver -k &> /dev/null || true

        if [ -d "$HOME/.wine64" ]; then
            rm -rf "$HOME/.wine64"
            echo "[+] Removed ~/.wine64 prefix."
        fi

        if [ -d "$HOME/.wine32" ]; then
            rm -rf "$HOME/.wine32"
            echo "[+] Removed ~/.wine32 prefix."
        fi
    else
        echo "[*] Kept Wine prefixes intact."
    fi
fi

echo ""
echo "[+] NotVulkan has been successfully uninstalled!"
