# jArch - Arch Coding Distro

[![License](https://img.shields.io/github/license/Riain-stack/jArch?style=flat-square)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Niri](https://img.shields.io/badge/Niri-Wayland-blue?style=flat-square)](https://github.com/YaLTeR/niri)
[![Neovim](https://img.shields.io/badge/Neovim-LSP-green?style=flat-square&logo=neovim)](https://neovim.io/)

> 🚀 A modern, developer-focused Arch Linux distribution with automated setup

Complete Arch-based distro for coding featuring SDDM, Niri Wayland compositor, Zsh, Neovim, and a fully automated installer. Get a production-ready development environment in minutes!

## ✨ Highlights

- ⚡ **One-command installation** - Automated setup from scratch
- 🎨 **Modern Wayland compositor** - Niri with smooth animations
- 💻 **Full dev stack** - Python, Node.js, Rust, Go, Java, Docker
- 🛠️ **Pre-configured tools** - Neovim, Zsh, Alacritty, and more
- 📦 **60+ packages** - Carefully selected for development
- 🔒 **Security hardened** - Best practices built-in
- 💾 **Built-in backup/restore** - Automated configuration management

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/Riain-stack/jArch.git
cd jArch

# Preview installation (dry-run)
sudo ./install/install.sh --dry-run

# Install jArch
sudo ./install/install.sh

# Resume if interrupted
sudo ./install/install.sh --resume

# Backup your configuration
./backup.sh --full

# Restore when needed
./restore.sh --full
```

## Table of Contents

- [Features](#features)
- [Backup & Restore](#backup--restore)
- [Requirements](#requirements)
- [Installation](#installation)
- [Screenshots](#screenshots)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Customization](#customization)
- [Included Dotfiles](#included-dotfiles)
- [Development Stack](#development-stack)
- [FAQ](#faq)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

## Features

### Installer Features
- ⚡ **Progress tracking** - Real-time percentage completion
- 🔄 **Resume capability** - Continue from where installation failed
- 🔍 **Dry-run mode** - Preview installation without changes
- 🎯 **Selective installation** - Skip components you don't need
- 📋 **Detailed logging** - Full installation logs for troubleshooting
- 💡 **Smart error messages** - Actionable suggestions when things fail
- ✅ **Pre-flight checks** - Verify system requirements before starting

### Core Components
| Component | Tool | Details |
|-----------|------|---------|
| **Display Manager** | SDDM | Simple, fast login manager |
| **Compositor** | Niri | Modern Wayland compositor (Rust-based) |
| **Shell** | Zsh | Starship prompt, autosuggestions, vi-mode |
| **Terminal** | Alacritty | GPU-accelerated terminal emulator |
| **Editor** | Neovim | LSP, treesitter, lazy.nvim, Kanagawa theme |

### Development Environment
| Category | Packages Included |
|----------|------------------|
| **Languages** | Python (pip, pipx, poetry), Node.js (npm, pnpm, yarn), Rust (cargo), Go, Java (JDK, Maven, Gradle) |
| **Build Tools** | gcc, clang, cmake, make, ninja, valgrind, gdb, lldb |
| **Version Control** | git, git-lfs, git-delta, lazygit |
| **Containers** | Docker, docker-compose |
| **Testing** | pytest (via Python), jasmine (via Node) |
| **Documentation** | man, batcat, batman, tldr |

### Modern CLI Tools
- **Search**: ripgrep (fast grep), fd (fast find)
- **Viewing**: bat (syntax-highlighted cat), exa (enhanced ls)
- **System**: btop/htop, dust (du alternative), neofetch
- **Fuzzy**: fzf (fuzzy finder), rofi (app launcher)
- **Shell**: tmux, zsh plugins (autosuggestions, syntax highlighting)

### Desktop Apps
- Firefox (web browser), Discord, Thunar (file manager)
- VS Code, Gedit, Obsidian
- MPV (media), mpv/image viewer

### System Features
- **Security**: UFW firewall, fail2ban, openssh
- **Sound**: PipeWire audio stack
- **Wayland**: waybar, wl-clipboard, screenshot tools

### Performance
- Wayland compositor (no X11 overhead)
- Rust-based Niri (fast and efficient)
- Lazy load Neovim plugins
- Optimized shell configuration

## 💾 Backup & Restore

jArch includes built-in backup and restore scripts for configuration management.

### Backup Your Configuration

```bash
# Full backup (create archive + commit + push to git)
./backup.sh --full

# Create archive only
./backup.sh --archive

# Commit and push changes
./backup.sh --commit

# Show repository status
./backup.sh --status
```

### Restore Configuration

```bash
# Full restore (dotfiles + Niri + all configs)
./restore.sh --full

# Restore dotfiles only
./restore.sh --dotfiles

# Restore Niri configuration only
./restore.sh --niri

# Run jArch installer
./restore.sh --install
```

**Safety Features:**
- 🔒 Automatic backup before restore
- 📁 Backups saved to `~/.jarch-backups/restore_backup_TIMESTAMP/`
- ✅ Confirmation prompts before changes
- 📊 Compressed archives for easy distribution

## Requirements

- Arch Linux or Arch-based distro
- Sudo access
- ~10GB free space (~4GB after installation)
- Internet connection for packages (~500MB download)
- 512MB RAM minimum (2GB+ recommended)

## Installation

### Quick Install

```bash
git clone https://github.com/Riain-stack/jArch.git
cd jArch
sudo ./install/install.sh
```

### Installation Options

```bash
# Standard installation
sudo ./install/install.sh

# Preview without making changes
sudo ./install/install.sh --dry-run

# Resume interrupted installation
sudo ./install/install.sh --resume

# Skip specific components
sudo ./install/install.sh --skip-aur --skip-docker

# Verbose output
sudo ./install/install.sh --verbose

# Get help
sudo ./install/install.sh --help
```

**Available flags:**
- `--dry-run` - Preview installation without making changes
- `--resume` - Resume from previous interrupted installation
- `--skip-aur` - Skip AUR helper and AUR packages
- `--skip-docker` - Skip Docker installation
- `--skip-fonts` - Skip fonts installation
- `--skip-gui` - Skip GUI applications (Firefox, Discord, etc.)
- `--verbose` - Show detailed output from package installations
- `-h, --help` - Display help message

Installation logs are saved to `/var/log/arch-coding-install-<timestamp>.log`

### What Gets Installed

| Phase | Action |
|-------|--------|
| 1. Pre-checks | Verify Arch, network connectivity, disk space |
| 2. Base System | Update packages, install base tools |
| 3. Display | Xorg, drivers, Niri, SDDM |
| 4. Shell | Zsh, starship, plugins |
| 5. Development | Languages, build tools, git |
| 6. Editor | Neovim with plugins |
| 7. AUR | paru helper, starship, zsh plugins |
| 8. Extras | Fonts, apps, Wayland tools |
| 9. Security | UFW, fail2ban, openssh |
| 10. Configs | Backup and copy dotfiles |
| 11. Services | Docker, firewall, sound |

### Post-Installation

1. **Reboot** your system
2. **SDDM** will start automatically
3. **Login** with your user account
4. First launch will configure:
   - Neovim plugins (lazy.nvim)
   - Starship prompt
   - Zsh completions
5. Old configs backed up to home directory

### Installation Time

| Phase | Time |
|-------|------|
| Pre-checks | ~10s |
| Package downloads | ~5 min |
| Installation | ~15 min |
| Configuration | ~2 min |
| **Total** | **~20-25 min** |

## Screenshots

> **Note**: Screenshots will be added here showing:
> - Niri Wayland compositor layout
> - Starship prompt with git branch
> - Neovim with Kanagawa theme
> - Waybar status bar
> - Terminal with syntax highlighting

### Manual Installation Steps

If the automated installer fails:

```bash
# 1. Install base packages
sudo pacman -S base base-devel networkmanager

# 2. Install display system
sudo pacman -S xorg-server xorg-xwayland niri sddm wayland

# 3. Install development tools
sudo pacman -S git python nodejs rust go make gcc clang docker neovim

# 4. Install shell and tools
sudo pacman -S zsh fzf ripgrep bat exa fd tmux
sudo pacman -S starship
sudo pacman -S alacritty thunar firefox

# 5. Copy dotfiles
cp -r dotfiles/.config/* ~/.config/
ln -s ~/.config/zsh/.zshrc ~/.zshrc
chsh -s /bin/zsh

# 6. Enable services
sudo systemctl enable sddm.service
sudo systemctl start sddm.service
```

## Keyboard Shortcuts

### Niri (Mod = Super/Win)

| Key Combination | Action |
|----------------|--------|
| `Mod+Shift+Return` | Open terminal (Alacritty) |
| `Mod+Shift+Q` | Close window |
| `Mod+Shift+E` | Quit Niri |
| `Mod+Left/Right` | Focus windows |
| `Mod+Up/Down` | Focus columns |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+Return` | Run niri-unstable |
| `Escape` | Close hotkey overlay |

### Neovim

| Key Combination | Action |
|----------------|--------|
| `<leader>e` | Toggle file tree (NvimTree) |
| `<leader>f` | Format file (async) |
| `<leader>q` | Quit |
| `<leader>w` | Write file |
| `<leader>p` | Paste from system clipboard |
| `<leader>y` | Yank to system clipboard |
| `<leader>o` | Insert new line below |

### Zsh Aliases

| Alias | Command |
|-------|---------|
| `ls` | exa with git info and icons |
| `ll` | exa detailed listing |
| `la` | exa all files |
| `tree` | exa tree view |
| `cat` | bat (syntax highlighted) |
| `grep` | ripgrep (fast search) |
| `find` | fd (fast find) |
| `vim` / `vi` | neovim |
| `lg` | lazygit |
| `dc` | docker-compose |
| `d` | docker |

## Customization

### Dotfile Locations

Edit these files in your home directory:

| File | Purpose |
|------|---------|
| `~/.config/niri/config.kdl` | Window manager configuration |
| `~/.config/starship.toml` | Starship prompt theme |
| `~/.config/zsh/.zshrc` | Zsh aliases and plugins |
| `~/.config/nvim/init.lua` | Neovim plugins and config |
| `~/.config/ripgrep/ripgreprc` | Ripgrep search options |
| `~/.zshenv` | Environment variables (created by installer) |

### Adding Custom Neovim Plugins

Edit `~/.config/nvim/init.lua`:

```lua
require('lazy').setup({
    -- existing plugins...
    'your/plugin-name',
})
```

### Configuring Niri

Edit `~/.config/niri/config.kdl`:

```kdl
output "eDP-1" {
    scale 1.25
    mode 1920x1080@60Hz
}

layout {
    border-width 2
    gap 8
}
```

### Starship Prompt

Edit `~/.config/starship.toml` to customize colors and modules:
https://starship.rs/config/

## Included Dotfiles

| Path | Description |
|------|-------------|
| `dotfiles/.config/niri/config.kdl` | Niri WM configuration (keyboard, layout, binds) |
| `dotfiles/.config/zsh/.zshrc` | Zsh shell config (plugins, aliases, keybinds) |
| `dotfiles/.config/nvim/init.lua` | Neovim config (plugins, lsp, keymaps, formatting) |
| `dotfiles/.config/starship.toml` | Starship prompt (git branch, languages, time) |
| `dotfiles/.config/ripgrep/ripgreprc` | Ripgrep config (options, exclusions) |

## Development Stack

### Languages Installed

| Language | Package Managers | Tools |
|----------|-----------------|-------|
| **Python** | pip, pipx, poetry, virtualenv | pytest, black, mypy |
| **Node.js** | npm, pnpm, yarn | eslint, prettier, vitest |
| **Rust** | cargo | clippy, rustfmt, cargo-watch |
| **Go** | go modules | golangci-lint, gofmt |
| **Java** | Maven, Gradle, SBT | jdk-openjdk |

### Development Tools

- **Version Control**: Git, git-lfs, git-delta, lazygit
- **Containers**: Docker, docker-compose
- **Terminals**: tmux (session management), zsh (shell)
- **Build Tools**: CMake, ninja, make, gcc, clang, valgrind
- **Utilities**: jq (JSON), yq (YAML), httpie (HTTP), curl, wget

### LSP Servers (Neovim)

pyl, tsserver, rust-analyzer, gopls, jdtls, bashls, jsonls, yamlls, eslint, tailwindcss

### Neovim Plugin Stack

- `lazy` - Plugin manager
- `treesitter` - Syntax highlighting
- `nvim-cmp` - Auto-completion
- `lualine` - Status line
- `nvim-tree` - File explorer
- `gitsigns` - Git diff in gutter
- `conform.nvim` - Code formatting

## FAQ

### Can I run this on a different Linux distro?

This is Arch-specific. For other distros, you'll need manual installation.

### Will this delete my current desktop?

No. If you already have a desktop, Niri will be available as an option. You can switch between them.

### Can I keep my existing dotfiles?

The installer backs up existing configs to `$HOME/.config-backup-<date>.tar.gz` before overwriting.

### What if my GPU isn't AMD/Intel?

The installer installs drivers for AMD, Intel, and NVIDIA. Check Arch wiki for NVIDIA specifics.

### Can I uninstall?

Yes. Remove dotfiles, uninstall packages, restore backups, and reinstall your previous DE.

## Troubleshooting

## Troubleshooting

### SDDM won't start

```bash
sudo systemctl start sddm
sudo journalctl -xe | grep sddm
```

### Niri crashes or doesn't start

```bash
# Check logs
journalctl -xe | grep niri

# Verify installation
pacman -Qs niri

# Try running manually
niri-unstable
```

### Zsh plugins not loading

```bash
# Check plugin installation
pacman -Qs zsh-plugins
pacman -Qs starship

# Verify zshrc is sourced
cat ~/.zshrc | grep source
```

### Neovim plugins not working

```bash
# Sync lazy.nvim
nvim --headless "+Lazy! sync" +qa

# Check lazy status
nvim --headless "+Lazy" +qa

# View logs
cat ~/.local/state/nvim/lazy.log
```

### Docker permission denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again for changes to take effect
```

### Fonts not displaying correctly

```bash
# Rebuild font cache
fc-cache -fv

# Ensure fonts are installed
pacman -Qs ttf-meslo ttf-jetbrains-mono
```

### Wayland issues

```bash
# Check Wayland is running
echo $WAYLAND_DISPLAY

# Verify dependencies
pacman -Qs wayland xwayland
```

### Firewall issues

```bash
# Check firewall status
sudo ufw status verbose

# Manage firewall rules
sudo ufw allow <port>
sudo ufw reject <port>

# Disable temporarily
sudo ufw disable
```

### Sound issues

```bash
# Check PipeWire status
pactl info
wpctl status

# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse
```

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Commit with clear messages (`git commit -m "add feature"`)
5. Push to your fork (`git push origin feature/your-feature`)
6. Open a Pull Request

### Development Setup

```bash
# Clone repository
git clone https://github.com/fools-stack/jArch.git
cd jArch

# Test installer locally
chmod +x install/install.sh
sudo ./install/install.sh
```

### Style Guidelines

- **Bash**: 4-space indentation, `set -eo pipefail`, error handling with trap
- **Neovim Lua**: Follow best practices, use lazy loading
- **Configs**: DRY and modular

## Changelog

### Version 1.0.0 (2024-01-24)

#### Added
- Initial Arch Coding Distro
- SDDM display manager
- Niri Wayland compositor
- Zsh with starship prompt plugins
- Neovim with lazy.nvim, LSP, treesitter
- Development languages (Python, Node.js, Rust, Go, Java)
- Security tools (UFW, fail2ban, openssh)
- PipeWire sound
- Wayland tools (waybar, rofi, grim, slurp)
- Automatic installer with error handling
- Configuration backups

#### Features
- Pre-install checks (network, disk space, Arch detection)
- Progress indicators
- Installation logging
- Keyboard shortcuts table
- Comprehensive README

#### Documentation
- README with troubleshooting guide
- FAQ section
- Customization instructions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Feel free to use, modify, and distribute this distro!

## 📚 Resources

- [Niri Documentation](https://github.com/YaLTeR/niri) - Wayland compositor
- [Starship Prompt](https://starship.rs/) - Cross-shell prompt
- [Neovim Config Guide](https://nvim-lua.readthedocs.io/) - Lua configuration
- [Arch Wiki](https://wiki.archlinux.org/) - Comprehensive Arch documentation
- [Wayland Information](https://wayland.freedesktop.org/) - Display protocol

## 🙋 Support

For issues or questions:
- **Bug reports**: [Open an issue](https://github.com/Riain-stack/jArch/issues)
- **Feature requests**: [Open an issue](https://github.com/Riain-stack/jArch/issues)
- **Documentation**: See [CHANGELOG.md](CHANGELOG.md)

---

<div align="center">

**Made with ❤️ for Arch Linux developers**

[![GitHub](https://img.shields.io/badge/GitHub-Riain--stack-181717?style=flat-square&logo=github)](https://github.com/Riain-stack)
[![Arch Linux](https://img.shields.io/badge/Built%20for-Arch%20Linux-1793D1?style=flat-square)](https://archlinux.org/)

</div>