# jArch Installer Guide

## Overview

The jArch installer has been enhanced with powerful features for a more reliable and flexible installation experience.

## Quick Start

```bash
# Standard installation
sudo ./install/install.sh

# Preview installation first
sudo ./install/install.sh --dry-run

# Minimal server installation (no GUI)
sudo ./install/install.sh --skip-gui --skip-fonts
```

## Command-Line Options

### Core Flags

| Flag | Description | Use Case |
|------|-------------|----------|
| `--dry-run` | Preview without changes | Test before installing |
| `--resume` | Continue interrupted install | Recovery from failures |
| `--verbose` | Show detailed output | Debugging issues |
| `-h, --help` | Display help | Quick reference |

### Skip Flags

| Flag | What Gets Skipped | Recommended For |
|------|-------------------|-----------------|
| `--skip-aur` | AUR helper (paru) and AUR packages | Users who don't need AUR |
| `--skip-docker` | Docker and docker-compose | Non-containerized workflows |
| `--skip-fonts` | All font packages | Minimal installations |
| `--skip-gui` | GUI apps (Firefox, Discord, VS Code, etc.) | Server/headless setups |

**Note:** Even with `--skip-gui`, Alacritty terminal is still installed as it's essential.

## Features

### 1. Progress Tracking

Watch real-time installation progress with percentage completion:

```
[35%] Installing development tools... OK
[40%] Installing Neovim... OK
```

### 2. Resume Capability

If installation is interrupted (network issue, power loss, etc.), simply resume:

```bash
sudo ./install/install.sh --resume
```

The installer will:
- Detect the last successful step
- Skip completed steps
- Continue from where it left off
- Clean up state file on completion

### 3. Dry-Run Mode

Preview what will be installed without making any changes:

```bash
sudo ./install/install.sh --dry-run
```

Perfect for:
- Reviewing package list
- Checking disk space requirements
- Planning custom installations
- CI/CD testing

### 4. Smart Error Messages

When something goes wrong, get actionable suggestions:

```
[ERROR] No internet connection. Please check your network.

Network troubleshooting:
  • Check if you're connected: ip link show
  • Test DNS: nslookup archlinux.org
  • Restart NetworkManager: systemctl restart NetworkManager
```

### 5. Selective Installation

Customize your installation by skipping components:

```bash
# Lightweight server installation
sudo ./install/install.sh --skip-gui --skip-fonts --skip-docker

# Development without containers
sudo ./install/install.sh --skip-docker

# Official repos only (no AUR)
sudo ./install/install.sh --skip-aur
```

## Installation Scenarios

### Scenario 1: Full Desktop Installation

For complete development environment with all features:

```bash
sudo ./install/install.sh
```

**Includes:** Everything (SDDM, Niri, GUI apps, Docker, AUR, fonts, etc.)

### Scenario 2: Server/Headless Installation

For servers or minimal setups without GUI:

```bash
sudo ./install/install.sh --skip-gui --skip-fonts
```

**Includes:** CLI tools, development languages, Niri compositor (can be used headless)
**Excludes:** Firefox, Discord, VS Code, fonts

### Scenario 3: Official Repos Only

For users who prefer not to use AUR:

```bash
sudo ./install/install.sh --skip-aur
```

**Note:** Some packages like Starship will need manual installation

### Scenario 4: Recovery from Failure

Installation failed due to network timeout:

```bash
# Check what went wrong
cat /var/log/arch-coding-install-*.log

# Resume installation
sudo ./install/install.sh --resume
```

### Scenario 5: Testing/Preview

Preview installation before committing:

```bash
# See what would be installed
sudo ./install/install.sh --dry-run

# Install if satisfied
sudo ./install/install.sh
```

## Troubleshooting

### Installation Interrupted

**Problem:** Installation stopped mid-way (Ctrl+C, network failure, etc.)

**Solution:**
```bash
sudo ./install/install.sh --resume
```

### Want to See Package Installation Details

**Problem:** Need verbose output for debugging

**Solution:**
```bash
sudo ./install/install.sh --verbose
```

### Insufficient Disk Space

**Problem:** Not enough space for full installation

**Solution:**
```bash
# Clean package cache
sudo pacman -Scc

# Or skip large components
sudo ./install/install.sh --skip-gui --skip-fonts
```

### AUR Installation Failing

**Problem:** paru or AUR packages won't install

**Solution:**
```bash
# Skip AUR entirely
sudo ./install/install.sh --skip-aur

# Or resume after fixing issue
sudo ./install/install.sh --resume
```

## State Management

The installer uses `/var/tmp/jarch-install-state` to track progress:

```bash
# Check current state
cat /var/tmp/jarch-install-state

# Remove state (start fresh)
sudo rm /var/tmp/jarch-install-state
```

State file contains:
- Last completed step name
- Timestamp of completion

State is automatically cleaned up on successful installation.

## Logs

Installation logs are saved to:
```
/var/log/arch-coding-install-YYYYMMDD-HHMMSS.log
```

View logs:
```bash
# Latest log
ls -lt /var/log/arch-coding-install-*.log | head -1

# View with less
less /var/log/arch-coding-install-*.log

# Search for errors
grep -i error /var/log/arch-coding-install-*.log
```

## Combining Flags

You can combine multiple flags:

```bash
# Minimal installation with verbose output
sudo ./install/install.sh --skip-gui --skip-docker --skip-aur --verbose

# Resume with verbose mode
sudo ./install/install.sh --resume --verbose

# Dry-run minimal installation
sudo ./install/install.sh --dry-run --skip-gui
```

## Post-Installation

After successful installation:

1. **Reboot** your system
2. **SDDM** starts automatically
3. **Login** with your account
4. **First launch** configures shell and Neovim

Check installation:
```bash
# Verify packages
pacman -Q | grep -E "niri|zsh|neovim"

# Check services
systemctl status sddm
systemctl status docker  # if not skipped

# Test shell
echo $SHELL  # should be /bin/zsh
```

## Tips

1. **Always dry-run first** on production systems
2. **Use --resume** instead of restarting from scratch
3. **Skip unnecessary components** to save time and space
4. **Keep installation logs** for troubleshooting
5. **Check disk space** before starting (need ~10GB free)

## Advanced Usage

### Custom Installation Script

Create your own wrapper:

```bash
#!/bin/bash
# custom-install.sh - Minimal jArch for servers

./install/install.sh \
    --skip-gui \
    --skip-fonts \
    --skip-docker \
    --verbose
```

### CI/CD Integration

```yaml
# .github/workflows/test-install.yml
- name: Test jArch Installation
  run: |
    sudo ./install/install.sh --dry-run
```

### Automated Deployment

```bash
# For multiple servers
ansible-playbook -i hosts jarch-install.yml \
  --extra-vars "skip_gui=true skip_docker=true"
```

## Support

- **Issues:** https://github.com/Riain-stack/jArch/issues
- **Docs:** https://github.com/Riain-stack/jArch
- **Logs:** `/var/log/arch-coding-install-*.log`

---

**Version:** 1.2.0  
**Last Updated:** 2026-01-28
