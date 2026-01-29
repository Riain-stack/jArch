# jArch Installation Guide

Complete guide for installing jArch with all available options and profiles.

## Table of Contents

- [Quick Start](#quick-start)
- [Installation Options](#installation-options)
- [Installation Profiles](#installation-profiles)
- [Command-Line Flags](#command-line-flags)
- [Examples](#examples)
- [What Gets Installed](#what-gets-installed)
- [Troubleshooting](#troubleshooting)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/Riain-stack/jArch.git
cd jArch

# Full installation (default)
sudo ./install/install.sh

# Or choose a profile
sudo ./install/install.sh --profile minimal
sudo ./install/install.sh --profile standard
```

## Installation Options

jArch installer supports multiple installation modes and profiles to suit your needs.

### Preview Before Installing (Dry-Run)

See what will be installed without making any changes:

```bash
sudo ./install/install.sh --dry-run
sudo ./install/install.sh --dry-run --profile minimal
```

### Skip Already Installed Packages

Save time by skipping packages that are already installed:

```bash
sudo ./install/install.sh --skip-installed
```

### Parallel Installation (Faster)

Enable parallel package installation for significantly faster setup:

```bash
# Auto-detect optimal parallel jobs based on CPU cores
sudo ./install/install.sh --parallel

# Specify number of parallel jobs manually
sudo ./install/install.sh --parallel -j 8
```

**Benefits:**
- 30-50% faster installation time
- Automatic CPU core detection
- Optimal for systems with 4+ cores
- Works with all profiles

**Note:** Requires good internet connection for best results.

## Installation Profiles

Choose the profile that best fits your needs:

### Minimal Profile (~2GB)

Core system with essential tools for a lightweight setup.

```bash
sudo ./install/install.sh --profile minimal
```

**Includes:**
- Niri Wayland compositor
- SDDM display manager
- Zsh with starship prompt
- Neovim with plugins
- Basic CLI tools (ripgrep, fd, fzf, bat, exa)
- Wayland utilities
- Basic fonts

**Perfect for:**
- Lightweight systems
- Minimal resource usage
- Users who want to add tools manually

### Standard Profile (~4GB)

Balanced setup with common development tools.

```bash
sudo ./install/install.sh --profile standard
```

**Includes everything from Minimal, plus:**
- Python (pip, pipx, poetry)
- Node.js (npm)
- Git with git-lfs, git-delta, lazygit
- Docker and docker-compose
- Build tools (gcc, make, cmake)
- Security tools (UFW, fail2ban, openssh)
- Sound support (PipeWire)

**Perfect for:**
- Web development
- Python/Node.js projects
- General purpose coding

### Full Profile (~6GB, Default)

Complete development environment with all tools and languages.

```bash
sudo ./install/install.sh --profile full
# or simply
sudo ./install/install.sh
```

**Includes everything from Standard, plus:**
- Rust with cargo
- Go programming language
- Java (JDK, Maven, Gradle, SBT)
- Extended build tools (clang, llvm, gdb, lldb, valgrind)
- Additional package managers (pnpm, yarn)
- Desktop applications (Firefox, Discord, Obsidian, VS Code)
- File manager and utilities (Thunar, file-roller)
- Media tools (mpv, ffmpeg, imagemagick)
- PDF viewer (zathura)

**Perfect for:**
- Multi-language development
- Systems programming
- Full-featured workstation

## Command-Line Flags

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help message and exit |
| `-d`, `--dry-run` | Preview installation without making changes |
| `-s`, `--skip-installed` | Skip packages that are already installed |
| `-p`, `--profile PROFILE` | Choose installation profile (minimal/standard/full) |
| `--parallel` | Enable parallel package installation (30-50% faster) |
| `-j`, `--jobs NUM` | Number of parallel jobs (default: auto-detect, cap at 8) |

## Examples

```bash
# Preview full installation
sudo ./install/install.sh --dry-run

# Minimal installation
sudo ./install/install.sh --profile minimal

# Fast parallel installation (recommended)
sudo ./install/install.sh --parallel

# Parallel with specific job count
sudo ./install/install.sh --parallel -j 6

# Standard installation, skip already installed packages
sudo ./install/install.sh --profile standard --skip-installed

# Preview minimal installation
sudo ./install/install.sh --dry-run --profile minimal

# Full installation with parallel mode
sudo ./install/install.sh --parallel --profile full

# Show help
./install/install.sh --help
```

## What Gets Installed

### All Profiles Include

| Category | Components |
|----------|-----------|
| **Display** | Niri, SDDM, Xorg, Wayland |
| **Shell** | Zsh, starship, autosuggestions, syntax highlighting |
| **Editor** | Neovim with lazy.nvim, LSP, treesitter |
| **CLI Tools** | ripgrep, fd, fzf, bat, exa, dust, btop, tmux |
| **Wayland** | waybar, rofi, grim, slurp, wl-clipboard |
| **Fonts** | JetBrains Mono, Meslo, Noto Fonts |

### Standard & Full Profiles Add

| Category | Components |
|----------|-----------|
| **Languages** | Python, Node.js |
| **VCS** | Git, git-lfs, git-delta, lazygit |
| **Containers** | Docker, docker-compose |
| **Build Tools** | gcc, make, cmake, ninja |
| **Security** | UFW firewall, fail2ban, openssh |
| **Sound** | PipeWire, pipewire-pulse, wireplumber |

### Full Profile Adds

| Category | Components |
|----------|-----------|
| **Languages** | Rust, Go, Java |
| **Build Tools** | clang, llvm, gdb, lldb, valgrind |
| **Package Managers** | cargo, go modules, maven, gradle, pnpm, yarn |
| **Apps** | Firefox, Discord, Obsidian, VS Code |
| **Utilities** | Thunar, file-roller, gedit, evince |
| **Media** | mpv, ffmpeg, imagemagick, zathura |

## Installation Process

The installer performs the following steps:

1. **Pre-checks** - Verify Arch Linux, network, disk space
2. **System Update** - Update package database
3. **Base System** - Install core packages
4. **Display Server** - Install Xorg, Wayland, drivers
5. **Desktop Environment** - Install Niri and SDDM
6. **Shell Setup** - Install Zsh and plugins
7. **Development Tools** - Install languages and tools (profile-dependent)
8. **Editor** - Install and configure Neovim
9. **AUR Helper** - Install paru for AUR packages
10. **Fonts** - Install programming fonts
11. **Additional Tools** - Install apps (full profile only)
12. **Security** - Configure firewall and security tools
13. **Configuration** - Backup existing configs and install dotfiles
14. **Verification** - Verify all components installed correctly

## Installation Time

| Profile | Download Size | Install Time | Disk Space |
|---------|--------------|--------------|------------|
| Minimal | ~500 MB | ~10-15 min | ~2 GB |
| Standard | ~800 MB | ~15-20 min | ~4 GB |
| Full | ~1.2 GB | ~20-30 min | ~6 GB |

*Times vary based on internet speed and system performance*

## Post-Installation

After installation completes:

1. **Reboot** your system
   ```bash
   sudo reboot
   ```

2. **SDDM** will start automatically

3. **Login** with your user account

4. **Select Niri** as your session (if not default)

5. **First Launch** will configure:
   - Neovim plugins (lazy.nvim auto-sync)
   - Starship prompt
   - Zsh completions

6. **Old Configs** are backed up to:
   - `~/.config-backup-YYYYMMDD.tar.gz`
   - Individual files: `~/.zshrc-backup-YYYYMMDD`

## Troubleshooting

### Installation Fails

Check the installation log:
```bash
sudo tail -f /var/log/arch-coding-install-*.log
```

### Network Issues

The installer includes automatic retry logic for network failures. If issues persist:
```bash
# Test network
ping -c 3 archlinux.org

# Check DNS
cat /etc/resolv.conf
```

### Insufficient Disk Space

Check available space:
```bash
df -h /
```

Minimum requirements:
- Minimal: 5 GB free (2 GB after install)
- Standard: 7 GB free (4 GB after install)
- Full: 10 GB free (6 GB after install)

### Permission Issues

Ensure you run with sudo:
```bash
sudo ./install/install.sh
```

### Package Conflicts

If you have conflicting packages, use `--skip-installed`:
```bash
sudo ./install/install.sh --skip-installed
```

### Verification Failures

The installer verifies critical components after installation. If verification fails:

1. Check the log file for specific errors
2. Manually verify installation:
   ```bash
   command -v niri
   command -v nvim
   command -v zsh
   ```
3. Re-run specific failed components if needed

## Advanced Usage

### Combining Flags

You can combine multiple flags:

```bash
# Dry-run with minimal profile and skip installed
sudo ./install/install.sh --dry-run --profile minimal --skip-installed
```

### Selective Installation

To install only specific components, modify the profile functions in the installer script or use the minimal profile and manually install additional packages.

### Custom Configuration

Before running the installer, you can customize:
- `dotfiles/.config/niri/config.kdl` - Niri configuration
- `dotfiles/.config/nvim/init.lua` - Neovim setup
- `dotfiles/.config/zsh/.zshrc` - Zsh configuration

## Getting Help

If you encounter issues:

1. Check this guide
2. Review the main [README.md](README.md)
3. Check installation logs in `/var/log/`
4. Open an issue on [GitHub](https://github.com/Riain-stack/jArch/issues)

## Next Steps

After installation:
- Read the [Keyboard Shortcuts](README.md#keyboard-shortcuts) section
- Explore [Customization](README.md#customization) options
- Set up your development environment
- Configure additional tools as needed
