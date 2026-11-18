#!/usr/bin/env bash
set -e

# ==========================================
# NotVulkan - Automated Installation Script (install.sh)
# Version: 1.1.0
# ==========================================

echo "=========================================="
echo "  NotVulkan Setup - Legacy GPU Runner"
echo "=========================================="
echo "[*] Checking and setting up system requirements..."

# 1. Enable 32-Bit Architecture Support
sudo dpkg --add-architecture i386

echo "[*] Updating system package repositories..."
sudo apt update -y || true

echo "[*] Installing core dependencies and 32/64-bit OpenGL graphics libraries..."
sudo apt install -y wine wine32:i386 wine64 winetricks zenity file libnotify-bin cabextract \
    libgl1-mesa-dri libgl1-mesa-dri:i386 \
    libglx-mesa0:i386 libgl1:i386 mesa-utils

echo "[+] Drivers, Wine and OpenGL libraries are ready."

# Detect Wine major version (Wine 10+ uses unified WoW64 architecture)
WINE_MAJOR=$(wine --version 2>/dev/null | sed -E 's/^wine-([0-9]+).*/\1/')
if ! [[ "$WINE_MAJOR" =~ ^[0-9]+$ ]]; then
    WINE_MAJOR=9
fi

# Helper function to apply safe Legacy GPU & X11 Display Tweaks
apply_wine_tweaks() {
    local PREFIX="$1"
    WINEPREFIX="$PREFIX" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoMemorySize" /t REG_SZ /d "4096" /f &> /dev/null || true
    WINEPREFIX="$PREFIX" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoPciVendorID" /t REG_DWORD /d 4098 /f &> /dev/null || true
    WINEPREFIX="$PREFIX" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoPciDeviceID" /t REG_DWORD /d 26873 /f &> /dev/null || true
    WINEPREFIX="$PREFIX" wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v "UseXVidMode" /t REG_SZ /d "N" /f &> /dev/null || true
}

# 2. Setup Primary 64-Bit Wine Prefix (~/.wine64)
if [ ! -d "$HOME/.wine64" ]; then
    echo "[*] Creating isolated 64-bit Wine environment (~/.wine64)..."
    WINEPREFIX="$HOME/.wine64" WINEARCH=win64 wineboot --init &> /dev/null
    WINEPREFIX="$HOME/.wine64" wineserver -w &> /dev/null || true
    
    echo "[*] Installing Wine Mono & DirectX 9 runtime into 64-bit environment..."
    WINEPREFIX="$HOME/.wine64" winetricks -q mono d3dx9 &> /dev/null || true
    
    WINEPREFIX="$HOME/.wine64" wineserver -k &> /dev/null || true
    echo "[+] 64-bit environment configured successfully."
fi
apply_wine_tweaks "$HOME/.wine64"

# 3. Setup Legacy 32-Bit Wine Prefix (~/.wine32) ONLY for Wine < 10.0 (with automatic fallback)
if [ "$WINE_MAJOR" -lt 10 ]; then
    if [ ! -d "$HOME/.wine32" ]; then
        echo "[*] Legacy Wine ($WINE_MAJOR.x) detected. Creating isolated 32-bit environment (~/.wine32)..."
        if WINEPREFIX="$HOME/.wine32" WINEARCH=win32 wineboot --init &> /dev/null; then
            WINEPREFIX="$HOME/.wine32" wineserver -w &> /dev/null || true
            
            echo "[*] Installing Wine Mono & DirectX 9 runtime into 32-bit environment..."
            WINEPREFIX="$HOME/.wine32" winetricks -q mono d3dx9 &> /dev/null || true
            
            WINEPREFIX="$HOME/.wine32" wineserver -k &> /dev/null || true
            apply_wine_tweaks "$HOME/.wine32"
            echo "[+] 32-bit environment configured successfully."
        else
            echo "[!] 32-bit prefix initialization skipped, falling back to unified 64-bit prefix..."
            rm -rf "$HOME/.wine32"
        fi
    else
        apply_wine_tweaks "$HOME/.wine32"
    fi
else
    echo "[*] Modern Wine ($WINE_MAJOR.x WoW64) detected. Using unified 64-bit prefix for all 32-bit & 64-bit games."
fi

# 4. DEPLOYING NOTVULKAN RUNTIME SCRIPT
echo "[*] Deploying NotVulkan runner script..."

INSTALL_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$INSTALL_DIR"
mkdir -p "$APP_DIR"

cat <<'SCRIPT' > "$INSTALL_DIR/notvulkan"
#!/usr/bin/env bash

RAW_INPUT="$1"
EXE_PATH=""

if [ -n "$RAW_INPUT" ]; then
    CLEAN_PATH=$(echo "$RAW_INPUT" | sed -e 's|^file://||' -e 's|%20| |g')
    
    if [ -f "$CLEAN_PATH" ]; then
        EXE_PATH="$CLEAN_PATH"
    elif command -v python3 &> /dev/null; then
        EXE_PATH=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv.pop()))' "$RAW_INPUT" | sed 's|^file://||')
    fi
fi

# Fallback to Zenity file chooser if no valid path was passed
if [ -z "$EXE_PATH" ] || [ ! -f "$EXE_PATH" ]; then
    if command -v zenity &> /dev/null; then
        EXE_PATH=$(zenity --file-selection --title="NotVulkan - Select Windows Executable" --file-filter="Windows Executables (*.exe, *.msi) | *.exe *.EXE *.msi *.MSI")
    fi
fi

[ -z "$EXE_PATH" ] && exit 0

EXE_PATH=$(readlink -f "$EXE_PATH")
EXE_DIR=$(dirname "$EXE_PATH")
EXE_FILE=$(basename "$EXE_PATH")
EXE_LOWER=$(echo "$EXE_FILE" | tr '[:upper:]' '[:lower:]')

cd "$EXE_DIR" || exit 1

ARCH_INFO=$(file -b "$EXE_PATH")
IS_64_APP=0

if [[ "$EXE_LOWER" == *setup* || "$EXE_LOWER" == *install* || "$EXE_LOWER" == *unins* || "$EXE_LOWER" == *wizard* || "$EXE_LOWER" == *gog* || "$EXE_LOWER" == *steam* || "$EXE_LOWER" == *64bit* || "$EXE_LOWER" == *patch* || "$EXE_LOWER" == *.msi ]] || echo "$ARCH_INFO" | grep -qiE "x86-64|x86_64|PE32\+"; then
    IS_64_APP=1
fi

WINE_MAJOR=$(wine --version 2>/dev/null | sed -E 's/^wine-([0-9]+).*/\1/')
if ! [[ "$WINE_MAJOR" =~ ^[0-9]+$ ]]; then
    WINE_MAJOR=9
fi

# Dynamic Prefix Selection: Wine 10+ uses WoW64 (~/.wine64), older Wine isolates 32-bit (~/.wine32)
if [ "$IS_64_APP" -eq 1 ] || [ "$WINE_MAJOR" -ge 10 ] || [ ! -d "$HOME/.wine32" ]; then
    TARGET_PREFIX="$HOME/.wine64"
    ARCH_LABEL=$([ "$IS_64_APP" -eq 1 ] && echo "64-bit" || echo "32-bit WoW64")
else
    TARGET_PREFIX="$HOME/.wine32"
    ARCH_LABEL="32-bit"
fi

IS_UNITY=0
if [ -f "$EXE_DIR/UnityPlayer.dll" ] || [ -d "$EXE_DIR/MonoBleedingEdge" ] || [ -d "${EXE_PATH%.exe}_Data" ]; then
    IS_UNITY=1
fi

# Global OpenGL backend enforcement for non-Vulkan legacy GPUs
export WINE_D3D_CONFIG="renderer=gl"
export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=0
export __GL_THREADED_OPTIMIZATIONS=1

if [ "$IS_UNITY" -eq 1 ]; then
    UNITY_ARGS="-force-d3d11"
    export WINEDLLOVERRIDES="vulkan-1=;dxgi=b;d3d11=b;d3d9=n,b;d3dx9_42=n,b;d3dx9_43=n,b;d3dcompiler_43=n,b"
    export MESA_GL_VERSION_OVERRIDE=4.5COMPAT
    export MESA_GLSL_VERSION_OVERRIDE=450
    UNITY_MSG="\n🎮 Unity D3D11-GL Fallback Activated"
else
    UNITY_ARGS=""
    export WINEDLLOVERRIDES="vulkan-1=;d3d9=n,b;d3dx9_42=n,b;d3dx9_43=n,b;d3dcompiler_43=n,b"
    UNITY_MSG=""
fi

wineserver -k &> /dev/null || true

if command -v notify-send &> /dev/null; then
    notify-send "NotVulkan" "Launching ($ARCH_LABEL): $EXE_FILE$UNITY_MSG" -i utilities-terminal
fi

if [[ "$EXE_LOWER" == *.msi ]]; then
    WINEPREFIX="$TARGET_PREFIX" wine msiexec /i "$EXE_PATH"
else
    WINEPREFIX="$TARGET_PREFIX" wine "$EXE_PATH" $UNITY_ARGS
fi
SCRIPT

chmod +x "$INSTALL_DIR/notvulkan"

# Global CLI symlink so 'notvulkan' works from any terminal
sudo ln -sf "$INSTALL_DIR/notvulkan" /usr/local/bin/notvulkan

# 5. DESKTOP / RIGHT-CLICK MIME INTEGRATION
cat <<EOF > "$APP_DIR/notvulkan.desktop"
[Desktop Entry]
Type=Application
Name=Run with NotVulkan
Comment=Run Unity and DirectX Games via WineD3D OpenGL Fallback Layer
Exec=$INSTALL_DIR/notvulkan %f
Icon=utilities-terminal
Terminal=false
NoDisplay=false
Categories=Game;Utility;
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-executable;application/x-wine-extension-exe;
EOF

if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$APP_DIR" &> /dev/null || true
fi

# 6. XFCE (Thunar) Direct Right-Click Context Menu Integration
THUNAR_UCA="$HOME/.config/Thunar/uca.xml"
if [ -f "$THUNAR_UCA" ] && ! grep -q "Run with NotVulkan" "$THUNAR_UCA"; then
    python3 -c '
import xml.etree.ElementTree as ET, os
uca_path = os.path.expanduser("~/.config/Thunar/uca.xml")
tree = ET.parse(uca_path)
root = tree.getroot()
action = ET.SubElement(root, "action")
ET.SubElement(action, "icon").text = "utilities-terminal"
ET.SubElement(action, "name").text = "Run with NotVulkan"
ET.SubElement(action, "unique-id").text = "notvulkan-runner-01"
ET.SubElement(action, "command").text = os.path.expanduser("~/.local/bin/notvulkan") + " %f"
ET.SubElement(action, "description").text = "Run Windows Executable via NotVulkan"
ET.SubElement(action, "patterns").text = "*.exe;*.EXE;*.msi;*.MSI"
ET.SubElement(action, "other-files")
tree.write(uca_path, encoding="UTF-8", xml_declaration=True)
' &> /dev/null || true
fi

echo ""
echo "=========================================="
echo "[+] NotVulkan v1.1.0 installed successfully!"
echo "    Right-click any .exe/.msi file or run 'notvulkan' in terminal."
echo "=========================================="
