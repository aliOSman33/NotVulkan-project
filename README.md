# NotVulkan

A lightweight, right-click Linux game launcher and smart Wine prefix manager optimized for older legacy hardware without native Vulkan support.

## Supported Systems

Designed for **Debian-based Linux distributions** (**Ubuntu, Linux Mint, MX Linux, Pop!_OS, Debian 12/13**, etc.) using `apt`.  
Supports **GNOME (Nautilus), Cinnamon (Nemo), MATE (Caja), and XFCE (Thunar)** file managers out-of-the-box.

## Features

* **Right-Click & CLI Integration:** Run `.exe` and `.msi` files instantly from your file manager (including native XFCE/Thunar custom actions) or launch from anywhere via the `notvulkan` terminal command.
* **Smart Hybrid Prefix Architecture:**
  * On **Wine 10.0+**, uses the unified **WoW64** architecture (`~/.wine64`) to run both 32-bit and 64-bit games seamlessly.
  * On **Legacy Wine (8.x / 9.x)**, automatically creates and isolates 32-bit (`~/.wine32`) and 64-bit (`~/.wine64`) prefixes with built-in fallback protection.
* **Global OpenGL Backend Enforcement:** Forces WineD3D OpenGL mode (`renderer=gl`) and disables Vulkan (`vulkan-1=`) across all games, with specialized `-force-d3d11` fallback parameters for **Unity** titles.
* **Automated Zero-Config Setup:** Silently initializes Wine prefixes (`wineboot --init`), installs required 32/64-bit Mesa OpenGL libraries, **Wine Mono**, and **DirectX 9 (`d3dx9`)** runtimes automatically.

## Installation

Open your terminal and run the following commands:

```bash
git clone https://github.com/aliOSman33/NotVulkan-project.git
cd NotVulkan-project
chmod +x install.sh
./install.sh
```

## Usage

* **From File Manager:** Right-click any `.exe` or `.msi` file and select **Run with NotVulkan**.
* **From Terminal:** Run `notvulkan path/to/game.exe` (or simply run `notvulkan` to open a file picker dialog).

## Uninstallation

To cleanly remove NotVulkan (including desktop entries, Thunar right-click actions, and global CLI links), run the uninstallation script inside the project directory:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

> **Note:** The uninstaller will ask for your confirmation before deleting the `~/.wine64` and `~/.wine32` prefixes so your installed games and save files remain safe.

## 🤝 Contributing & Feedback

**NotVulkan is a community-driven project in active development.** Because legacy hardware and game engines vary widely, your real-world testing and feedback are essential to making this tool better for everyone.

* **Found a bug or a game that won't launch?** Please open a report on our [Issues Page](../../issues) using the **Bug Report** template.
* **Have an idea or improvement?** Feel free to fork the repository and submit a Pull Request, or share your suggestions in the Issues tab.
* **Compatibility & Performance:** Tested on bare-metal legacy hardware (including AMD `r600` non-Vulkan GPUs). Sharing which games work on your system helps other users!

## 🤖 Acknowledgments

* Developed with extensive assistance from Artificial Intelligence (AI) for scripting, structure design, and documentation.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).
