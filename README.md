# NotVulkan

A lightweight, right-click Linux game launcher and prefix isolator optimized for older legacy hardware without native Vulkan support.

## Features

* **Right-Click Integration:** Run `.exe` files instantly from your file manager without opening a terminal.
* **Smart Prefix Isolation:** Automatically creates and separates 32-bit (`~/.wine32`) and 64-bit (`~/.wine64`) Wine prefixes with optimized Direct3D registry settings.
* **Unity Engine Fallback:** Automatically detects Unity games and forces OpenGL mode (`renderer=gl`) for older GPUs.
* **Automated Setup:** Installs required OpenGL libraries, Wine Mono, and dependencies out-of-the-box.

## Installation

Open your terminal and run the following commands:

```bash
git clone [https://github.com//NotVulkan-project.git](https://github.com/aliOSman33/NotVulkan-project.git)
cd NotVulkan-project
chmod +x install.sh
./install.sh
