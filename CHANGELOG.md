# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Installation Time Estimation**: Real-time progress tracking with ETA
  - Shows estimated time remaining during installation
  - Dynamic ETA calculation based on actual progress
  - Profile-aware time estimates (minimal/standard/full)
  - Parallel mode adjustments (40% faster estimates)
  - Installation summary showing actual vs estimated time
  - Time saved display when completing faster than expected
  - Per-step elapsed time tracking in logs
- **Parallel Installation Mode**: Significantly faster package installation
  - `--parallel` flag enables parallel installation (30-50% faster)
  - `-j, --jobs NUM` flag to control parallel job count
  - Automatic CPU core detection (uses 75% of cores, capped at 8)
  - Intelligent chunk-based parallel installation
  - MAKEFLAGS optimization for AUR package compilation
  - Works with all installation profiles
- Performance improvements:
  - Reduced installation time from ~20-25min to ~13-17min on multi-core systems
  - Parallel compilation for AUR packages (paru)
  - Optimized package grouping for parallel downloads

### Changed
- Enhanced progress indicators with real-time ETA display
- Updated README.md with parallel installation examples and time estimates
- Enhanced INSTALL.md with performance options documentation
- Improved help text with performance recommendations
- Added installation time comparison table
- Installation completion shows total time and time saved

## [1.1.0] - 2026-01-28

### Added
- **Backup & Restore System**: Complete configuration management
  - `backup.sh` - Automated backup with git integration
  - `restore.sh` - Safe restoration with automatic backups
  - Archive creation for easy distribution
  - Git commit and push automation
  - Status reporting and backup tracking
- Safety features for restore operations:
  - Automatic backup before restore
  - Confirmation prompts
  - Timestamped safety backups in `~/.jarch-backups/`

### Changed
- Enhanced README with Backup & Restore section
- Added Quick Start guide
- Updated repository URL from fools-stack to Riain-stack
- Improved documentation structure

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

## [1.2.0] - 2026-01-28

### Added
- **Enhanced Installer System**:
  - `--dry-run` mode to preview installation without making changes
  - `--resume` functionality to continue interrupted installations
  - State tracking system for reliable recovery
  - Progress percentage tracking (shows X% completion)
  - Command-line flags: `--skip-aur`, `--skip-docker`, `--skip-fonts`, `--skip-gui`
  - `--verbose` flag for detailed package installation output
  - `--help` flag with comprehensive usage information
- **Improved Error Handling**:
  - Actionable error messages with troubleshooting suggestions
  - Better network connectivity error messages
  - Disk space error messages with cleanup suggestions
  - Package installation failure recovery suggestions
- **Better User Experience**:
  - Colored ASCII art banner on startup
  - Real-time progress indicators with percentages
  - Dry-run summary showing what would be installed
  - Installation summary with conditional feature listing
  - State file cleanup on successful completion

### Changed
- Enhanced all installation functions with dry-run support
- Improved logging with color-coded messages
- Better resume logic with step ordering
- Conditional Docker installation based on flags
- Selective GUI application installation
- More informative completion messages

### Fixed
- Installation recovery after network failures
- Better handling of already-installed packages
- Improved error context for debugging

## [1.2.2] - 2026-01-28

### Fixed
- Improved error handling in `fail_msg()` to prevent log write failures
- Added proper variable quoting for `$SUDO_USER` throughout installer (security improvement)
- Enhanced `install_aur_helper()` with better directory tracking and error handling
- Fixed step counting accuracy for progress tracking (7/12/13 steps for profiles)
- Updated test suite to match corrected installer behavior

### Changed
- Added documentation comments to `calculate_steps()` function
- Improved test output clarity in step counting tests
- Removed obsolete functions from test sequence for accuracy

### Tests
- All 61 tests passing (100% success rate)
- Step counting verification: 3/3 profiles PASSED
- Profile logic tests: 43/43 PASSED
- Component mapping: PASSED

## [Unreleased]

### Added
- **Update Script**: New `update.sh` for system maintenance
  - Updates system and AUR packages
  - Syncs dotfiles from repository
  - Checks for jArch version updates
  - Optional backup before updating
  - Dry-run mode for preview
  - Package cache cleaning

- **Enhanced Neovim Configuration**: Significantly improved development experience
  - Added Telescope fuzzy finder for files and grep
  - Added Harpoon for quick file navigation
  - Added which-key for keybinding discovery
  - Added bufferline for buffer management
  - Added indent guides and todo-comments
  - Enhanced LSP keybindings with descriptions
  - Better window and buffer navigation
  - Git integration improvements
  - Comprehensive keybinding system
  - Auto-format on save for multiple languages
  - Added NEOVIM_GUIDE.md with complete documentation

### Planned
- ISO build automation
- Additional window manager options
- More theme choices
- Configuration wizard
- Package groups
- Scheduled backups
- Installation time estimation

---

[1.1.0]: https://github.com/Riain-stack/jArch/releases/tag/v1.1.0
[1.0.0]: https://github.com/Riain-stack/jArch/releases/tag/v1.0.0
