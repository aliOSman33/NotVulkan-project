#!/usr/bin/env bash

# ==========================================
# NotVulkan - Automated Installation Script (install.sh)
# ==========================================

echo "[*] Checking and setting up NotVulkan system requirements..."

# 1. Enable 32-Bit Architecture Support
sudo dpkg --add-architecture i386 &> /dev/null

echo "[*] Updating system package repositories..."
sudo apt update -y &> /dev/null

echo "[*] Installing core dependencies and 32/64-bit OpenGL graphics libraries..."
sudo apt install -y wine winetricks zenity file libnotify-bin \
    libgl1-mesa-dri libgl1-mesa-dri:i386 \
    libgl1-mesa-glx:i386 libglx-mesa0:i386 \
    libgl1:i386 mesa-utils &> /dev/null

echo "[+] Drivers and graphics libraries are ready."

# 2. Setup 64-Bit Wine Prefix (~/.wine64)
if [ ! -d "$HOME/.wine64" ]; then
    echo "[*] Creating isolated 64-bit Wine environment (~/.wine64)..."
    WINEPREFIX="$HOME/.wine64" WINEARCH=win64 winecfg /v win10 &> /dev/null
    
    echo "[*] Installing Wine Mono into the 64-bit environment..."
    WINEPREFIX="$HOME/.wine64" winetricks -q mono &> /dev/null
    
    WINEPREFIX="$HOME/.wine64" wineserver -k &> /dev/null
    echo "[+] 64-bit environment configured successfully."
fi

# 64-Bit Registry Tweaks for Legacy GPUs
WINEPREFIX="$HOME/.wine64" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoMemorySize" /t REG_SZ /d "4096" /f &> /dev/null
WINEPREFIX="$HOME/.wine64" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoPciVendorID" /t REG_DWORD /d 4098 /f &> /dev/null
WINEPREFIX="$HOME/.wine64" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoPciDeviceID" /t REG_DWORD /d 26873 /f &> /dev/null

# 3. Setup 32-Bit Wine Prefix (~/.wine32)
if [ ! -d "$HOME/.wine32" ]; then
    echo "[*] Creating isolated 32-bit Wine environment (~/.wine32)..."
    WINEPREFIX="$HOME/.wine32" WINEARCH=win32 winecfg /v win7 &> /dev/null
    
    echo "[*] Installing Wine Mono into the 32-bit environment..."
    WINEPREFIX="$HOME/.wine32" winetricks -q mono &> /dev/null
    
    WINEPREFIX="$HOME/.wine32" wineserver -k &> /dev/null
    echo "[+] 32-bit environment configured successfully."
fi

# 32-Bit Registry Tweaks for Legacy GPUs
WINEPREFIX="$HOME/.wine32" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoMemorySize" /t REG_SZ /d "4096" /f &> /dev/null
WINEPREFIX="$HOME/.wine32" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoPciVendorID" /t REG_DWORD /d 4098 /f &> /dev/null
WINEPREFIX="$HOME/.wine32" wine reg add "HKCU\\Software\\Wine\\Direct3D" /v "VideoPciDeviceID" /t REG_DWORD /d 26873 /f &> /dev/null

# 4. DEPLOYING NOTVULKAN RUNTIME SCRIPT
echo "[*] Deploying NotVulkan runner script to the system..."

INSTALL_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
mkdir -p "$INSTALL_DIR"
mkdir -p "$APP_DIR"

cat <<'SCRIPT' > "$INSTALL_DIR/notvulkan"
#!/usr/bin/env bash

RAW_INPUT="$1"
EXE_PATH=""

if [ -n "$RAW_INPUT" ]; then
    # Clean file:// prefix and decode URL spaces (%20)
    CLEAN_PATH=$(echo "$RAW_INPUT" | sed -e 's|^file://||' -e 's|%20| |g')
    
    if [ -f "$CLEAN_PATH" ]; then
        EXE_PATH="$CLEAN_PATH"
    elif command -v python3 &> /dev/null; then
        EXE_PATH=$(python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$RAW_INPUT" | sed 's|^file://||')
    fi
fi

# Fallback to Zenity file chooser if no valid path was passed
if [ -z "$EXE_PATH" ] || [ ! -f "$EXE_PATH" ]; then
    if command -v zenity &> /dev/null; then
        EXE_PATH=$(zenity --file-selection --title="NotVulkan - Select Windows Executable" --file-filter="Executable files (*.exe) | *.exe")
    fi
fi

[ -z "$EXE_PATH" ] && exit 0

EXE_PATH=$(readlink -f "$EXE_PATH")
EXE_DIR=$(dirname "$EXE_PATH")
EXE_FILE=$(basename "$EXE_PATH")
EXE_LOWER=$(echo "$EXE_FILE" | tr '[:upper:]' '[:lower:]')

cd "$EXE_DIR" || exit 1

ARCH_INFO=$(file -b "$EXE_PATH")
FORCE_64=0

# Automatically route setup, installation files, and 64-bit binaries to the 64-bit prefix
if [[ "$EXE_LOWER" == *setup* || "$EXE_LOWER" == *install* || "$EXE_LOWER" == *unins* || "$EXE_LOWER" == *wizard* || "$EXE_LOWER" == *gog* || "$EXE_LOWER" == *steam* || "$EXE_LOWER" == *64bit* || "$EXE_LOWER" == *patch* ]] || echo "$ARCH_INFO" | grep -qiE "x86-64|x86_64|PE32\+"; then
    FORCE_64=1
fi

IS_UNITY=0
if [ -f "$EXE_DIR/UnityPlayer.dll" ] || [ -d "$EXE_DIR/MonoBleedingEdge" ] || [ -d "${EXE_PATH%.exe}_Data" ]; then
    IS_UNITY=1
fi

if [ "$IS_UNITY" -eq 1 ]; then
    UNITY_ARGS="-force-d3d11"
    export WINE_D3D_CONFIG="renderer=gl"
    export WINEDLLOVERRIDES="vulkan-1=;dxgi=b;d3d11=b;d3d9=b;d3dx9_42=b;d3dx9_43=b;d3dcompiler_43=b"
    export MESA_GL_VERSION_OVERRIDE=4.5COMPAT
    export MESA_GLSL_VERSION_OVERRIDE=450
    UNITY_MSG="\n🎮 Unity D3D11-GL Fallback Activated"
else
    UNITY_ARGS=""
    export WINEDLLOVERRIDES="d3d9=b;d3dx9_42=b;d3dx9_43=b;d3dcompiler_43=b"
    UNITY_MSG=""
fi

export WINEDEBUG=-all
export LIBGL_ALWAYS_SOFTWARE=0
export __GL_THREADED_OPTIMIZATIONS=1

wineserver -k &> /dev/null

if [ "$FORCE_64" -eq 1 ]; then
    if command -v notify-send &> /dev/null; then
        notify-send "NotVulkan" "Launching (64-bit): $EXE_FILE$UNITY_MSG" -i utilities-terminal
    fi
    WINEPREFIX="$HOME/.wine64" wine "$EXE_PATH" $UNITY_ARGS
else
    if command -v notify-send &> /dev/null; then
        notify-send "NotVulkan" "Launching (32-bit): $EXE_FILE$UNITY_MSG" -i utilities-terminal
    fi
    WINEPREFIX="$HOME/.wine32" wine "$EXE_PATH" $UNITY_ARGS
fi
SCRIPT

chmod +x "$INSTALL_DIR/notvulkan"

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

echo "[+] NotVulkan has been successfully installed!"