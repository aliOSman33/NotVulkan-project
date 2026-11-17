# NotVulkan

A lightweight, right-click Linux game launcher and prefix isolator optimized for older legacy hardware without native Vulkan support.

## Supported Systems

Designed for **Debian-based Linux distributions** (Ubuntu, Linux Mint, Pop!_OS, Debian, etc.) using `apt`.

## Features

* **Right-Click Integration:** Run `.exe` files instantly from your file manager without opening a terminal.
* **Smart Prefix Isolation:** Automatically creates and separates 32-bit (`~/.wine32`) and 64-bit (`~/.wine64`) Wine prefixes with optimized Direct3D registry settings.
* **Unity Engine Fallback:** Automatically detects Unity games and forces OpenGL mode (`renderer=gl`) for older GPUs.
* **Automated Setup:** Installs required OpenGL libraries, Wine Mono, and dependencies out-of-the-box.

## Installation

Open your terminal and run the following commands:

```bash
git clone https://github.com/aliOSman33/NotVulkan-project.git
cd NotVulkan-project
chmod +x install.sh
./install.sh
```

## Uninstallation

To remove NotVulkan from your system, run the uninstallation script inside the project directory:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

> **Note:** The uninstaller will ask for your confirmation before deleting the `~/.wine32` and `~/.wine64` prefixes so your saved games remain safe.

## ⚠️ Status & Performance Note

* **Active Development:** This project is continuously being improved and updated. 
* **Compatibility & Performance:** Many games have been tested, but performance may vary depending on your specific legacy hardware and the game engine. Some titles might experience minor performance drops or compatibility issues. Feedback and bug reports are always welcome!

## 🤖 Acknowledgments

* Developed with extensive assistance from Artificial Intelligence (AI) for scripting, structure design, and documentation.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).
