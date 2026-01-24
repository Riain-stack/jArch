# Arch Coding Distro

Arch-based distro for coding with SDDM, Niri, Zsh, Neovim and automatic installer.

## Features

- **Display**: SDDM + Niri Wayland compositor
- **Shell**: Zsh with starship prompt and plugins
- **Editor**: Neovim with lazy.nvim, LSP, treesitter, Kanagawa theme
- **Dev Tools**: Python, Node.js, Rust, Go, Java, GCC/Clang, Docker
- **Modern Tools**: ripgrep, fd, fzf, bat, exa, dust, tmux, lazygit
- **Fonts**: Meslo, JetBrains Mono, Fira Mono, Noto

## Requirements

- Arch Linux or Arch-based distro
- Sudo access
- ~10GB free space (~4GB after installation)

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

## Keyboard Shortcuts

Niri (Mod = Super/Win):
- `Mod+Shift+Return` Open terminal
- `Mod+Shift+Q` Close window
- `Mod+Shift+E` Quit Niri
- `Mod+Left/Right/Up/Down` Focus windows
- `Mod+F` Maximize column
- `Mod+Shift+F` Fullscreen window

Vim:
- `<leader>e` Toggle file tree
- `<leader>f` Format file
- `<leader>q` Quit
- `<leader>w` Write
- `<leader>y` Yank to clipboard

## Customization

Edit these files:
- `~/.config/niri/config.kdl` - Window manager config
- `~/.config/starship.toml` - Prompt theme
- `~/.zshrc` - Shell aliases and config
- `~/.config/nvim/init.lua` - Neovim config

## Included Dotfiles

- `dotfiles/.config/niri/config.kdl` - Niri WM config
- `dotfiles/.config/zsh/zshrc` - Zsh shell config
- `dotfiles/.config/nvim/init.lua` - Neovim config
- `dotfiles/.config/starship.toml` - Starship prompt config
- `dotfiles/.zsh/zshrc` - Zsh plugins and aliases

## Development Stack

**Languages**: Python, Node.js, Rust, Go, Java
**Tools**: Git, Docker, tmux, lazygit
**LSP**: pyls, tsserver, rust-analyzer, gopls, jdtls, eslint
**Neovim Plugins**: lazy, treesitter, nvim-cmp, lualine, nvim-tree, gitsigns