# Quick Start Guide

## Local Virtual Machine (Quick Test)

```bash
# Build and test with Docker
docker build -t arch-niri .
docker run --rm -it arch-niri /bin/bash

# Or with Nix
nix develop
./install/install.sh
```

## Physical Machine Installation

1. Create bootable USB:
```bash
# Build ISO
chmod +x build-iso.sh
sudo ./build-iso.sh

# Flash to USB
sudo dd if=build/arch-niri.iso of=/dev/sdX bs=4M status=progress && sync
```

2. Boot from USB and run:
```bash
sudo ./install/install.sh
```

3. Reboot

## What Gets Installed

**Shell:**
- fish shell (default shell)
- zsh
- tmux with project management

**Dev Tools:**
- Node.js, npm
- Python, pip
- Rust, Cargo
- Go
- Docker, Docker Compose

**Neovim Plugins:**
- telescope.nvim (fuzzy finder)
- nvim-lspconfig (LSP for all languages)
- nvim-cmp (autocomplete)
- nvim-treesitter (syntax highlighting)
- nvim-tree (file explorer)
- gitsigns (git integration)
- lualine (status line)
- tokyonight (theme)

**Wayland:**
- niri (window manager)
- SDDM (display manager)
- waybar (status bar)
- rofi (launcher)
- foot (terminal)

**Utils:**
- fzf, ripgrep, bat, exa
- lazygit, zoxide
- tldr (cheatsheets)

## Keybindings (Niri)

| Key | Action |
|-----|--------|
| Mod+Return | Terminal |
| Mod+d | Launcher |
| Mod+q | Close window |
| Mod+1-6 | Switch workspace |
| Mod+Shift+1-6 | Move to workspace |
| Mod+h/j/k/l | Focus window |
| Mod+Arrow | Focus column/window |
| Mod+w/e | Split window |
| Mod+f | Maximize |
| Mod+Shift+Space | Float window |

## Vim Keymaps

| Key | Action |
|-----|--------|
| \ff | Find files |
| \fg | Grep search |
| \fb | Buffers |
| \h | Open left |
| \j | Open down |
| \k | Open up |
| \l | Open right |
| C-f | Sessionizer |