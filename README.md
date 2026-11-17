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

## 🤝 Contributing & Feedback

**NotVulkan is a community-driven project in active development.** Because legacy hardware and game engines vary widely, your real-world testing and feedback are essential to making this tool better for everyone.

* **Found a bug or a game that won't launch?** Please open a report on our [Issues Page](https://github.com) using the **Bug Report** template.
* **Have an idea or improvement?** Feel free to fork the repository and submit a Pull Request, or share your suggestions in the Issues tab.
* **Compatibility & Performance:** Many games have been tested, but performance may vary depending on your specific legacy hardware and the game engine. Some titles might experience minor performance drops or compatibility issues. Sharing which games work on your system helps other users!

## 🤖 Acknowledgments

* Developed with extensive assistance from Artificial Intelligence (AI) for scripting, structure design, and documentation.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).
