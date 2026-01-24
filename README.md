# Arch Coding Distro

Arch-based distro for coding with SDDM, Niri, Zsh, Neovim and automatic installer.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Customization](#customization)
- [Included Dotfiles](#included-dotfiles)
- [Development Stack](#development-stack)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Display**: SDDM + Niri Wayland compositor
- **Shell**: Zsh with starship prompt and plugins (fast-syntax-highlighting, autosuggestions, vi-mode)
- **Editor**: Neovim with lazy.nvim, LSP, treesitter, Kanagawa theme
- **Dev Tools**: Python, Node.js, Rust, Go, Java, GCC/Clang, Docker
- **Modern Tools**: ripgrep, fd, fzf, bat, exa, dust, tmux, lazygit
- **Fonts**: Meslo, JetBrains Mono, Fira Mono, Noto
- **Apps**: Alacritty, Firefox, Thunar, VS Code

## Requirements

- Arch Linux or Arch-based distro
- Sudo access
- ~10GB free space (~4GB after installation)
- Internet connection for packages

## Installation

```bash
chmod +x install/install.sh
sudo ./install/install.sh
```

The installer will:
1. Update system packages
2. Install display server, SDDM, Niri
3. Install shell (Zsh) with plugins
4. Install development languages and tools
5. Install Neovim with plugins
6. Set up dotfiles for Niri, Zsh, Neovim, Starship
7. Install fonts and additional tools
8. Configure Docker

Post-installation:
- Reboot to launch SDDM
- Login with your user account
- Neovim and starship will configure on first launch

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

| Language | Version/Package Manager |
|----------|------------------------|
| Python | pip, pipx, poetry, virtualenv |
| Node.js | npm, pnpm, yarn |
| Rust | cargo |
| Go | go |
| Java | jdk-openjdk, Maven, Gradle, SBT |

### Development Tools

- **Version Control**: Git, git-lfs, git-delta, lazygit
- **Containers**: Docker, docker-compose
- **Terminal/Shell**: tmux, zsh, starship
- **Build CMake, ninja, make, gcc, clang, valgrind
- **Utilities**: jq, yq, httpie, curl, wget

### LSP Servers Configured

 pyls, tsserver, rust-analyzer, gopls, jdtls, bashls, jsonls, yamlls, eslint, tailwindcss

### Neovim Plugins

lazy, treesitter, nvim-cmp, lualine, nvim-tree, gitsigns, conform.nvim

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

- Bash scripts: Use 4-space indentation, `set -e` for error handling
- Neovim Lua: Follow Lua best practices, use lazy loading
- Config files: Keep configurations DRY and modular

## License

MIT License - feel free to use, modify, and distribute this distro.

## Resources

- [Niri Documentation](https://github.com/YaLTeR/niri)
- [Starship Prompt](https://starship.rs/)
- [Neovim Config Guide](https://nvim-lua.readthedocs.io/)
- [Arch Wiki](https://wiki.archlinux.org/)
- [Wayland Information](https://wayland.freedesktop.org/)