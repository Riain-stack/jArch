Arch Niri Dev Distro
=====================

An Arch-based Linux distribution setup with:
- Niri Wayland compositor
- SDDM display manager
- Development Environment
- Neovim setup
- Automatic installer

Features:
--------
- Full development environment (Node.js, Rust, Golang, Python, Docker)
- Niri window manager configuration
- Custom Neovim config with LSP, Telescope, Treesitter
- Fish shell with modern tooling (fzf, zoxide, ripgrep, bat, exa)
- Waybar panel for status
- SDDM display manager

Installation:
------------
1. Boot from ISO
2. Run as root: `./install/install.sh`
3. Reboot

Package Set:
--------
Wayland: niri, sddm, waybar, rofi, wl-clipboard, foot, slurp, grim
Devs: neovim, git, nodejs, python, rust, cargo, go, docker, docker-compose
CLI Tools: fzf, ripgrep, bat, exa, zoxide, lsd, tldr, lazygit
Fonts: JetBrains Mono, Nerd Fonts, Noto fonts