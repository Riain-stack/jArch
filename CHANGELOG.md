# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-28

### Added
- Complete Arch Linux coding distribution
- Automated installer with progress tracking and error handling
- SDDM display manager integration
- Niri Wayland compositor (Rust-based)
- Zsh shell with Starship prompt, autosuggestions, and vi-mode
- Alacritty GPU-accelerated terminal
- Neovim with LSP, treesitter, lazy.nvim, and Kanagawa theme
- Complete development environment:
  - Languages: Python, Node.js, Rust, Go, Java
  - Build tools: gcc, clang, cmake, make, ninja, valgrind, gdb, lldb
  - Version control: git, git-lfs, git-delta, lazygit
  - Containers: Docker, docker-compose
- Modern CLI tools: ripgrep, fd, bat, exa, btop, fzf, rofi
- Desktop applications: Firefox, Discord, Thunar
- Comprehensive dotfiles for all components
- Pre-install system checks
- Wayland and security enhancements
- MIT License
- Comprehensive documentation with FAQ and troubleshooting

### Changed
- Optimized installer with compressed commands and skip logic
- Enhanced Niri configuration
- Improved Zsh configuration
- Better error handling and logging throughout
- Detailed progress indicators
- Fixed ripgrep config file
- Fixed dotfiles structure and paths
- Corrected SCRIPT_DIR path resolution

### Fixed
- Packpath configuration
- Conform.nvim integration
- Zsh tmux condition
- Dotfiles directory structure
- Installation script paths

## [Unreleased]

### Planned
- ISO build automation
- Additional window manager options
- More theme choices
- Backup and restore utilities
- Auto-update mechanism

---

[1.0.0]: https://github.com/Riain-stack/jArch/releases/tag/v1.0.0
