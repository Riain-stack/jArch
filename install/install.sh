#!/usr/bin/env bash
set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="/var/log/arch-coding-install-$(date +%Y%m%d-%H%M%S).log"
DRY_RUN=false
SKIP_INSTALLED=false
INSTALL_PROFILE="full"
TOTAL_STEPS=0
CURRENT_STEP=0

log() { 
    local msg="${GREEN}[INFO]${NC} $1"
    echo -e "$msg"
    if [[ -w "$LOG_FILE" ]] 2>/dev/null && [[ "$DRY_RUN" == false ]]; then
        echo -e "$msg" >> "$LOG_FILE" 2>/dev/null
    fi
}
warn() { 
    local msg="${YELLOW}[WARN]${NC} $1"
    echo -e "$msg"
    if [[ -w "$LOG_FILE" ]] 2>/dev/null && [[ "$DRY_RUN" == false ]]; then
        echo -e "$msg" >> "$LOG_FILE" 2>/dev/null
    fi
}
error() { 
    local msg="${RED}[ERROR]${NC} $1"
    echo -e "$msg"
    if [[ -w "$LOG_FILE" ]] 2>/dev/null; then
        echo -e "$msg" >> "$LOG_FILE" 2>/dev/null
    fi
    exit 1
}

progress() { 
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percent=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local msg="${BLUE}[${percent}%]${NC} $1..."
    echo -ne "\r$msg"
    if [[ -w "$LOG_FILE" ]] 2>/dev/null && [[ "$DRY_RUN" == false ]]; then
        echo "$msg" >> "$LOG_FILE" 2>/dev/null
    fi
}
done_msg() { 
    local msg="${GREEN}[DONE]${NC}    $1... OK"
    echo -e "\r$msg"
    if [[ -w "$LOG_FILE" ]] 2>/dev/null && [[ "$DRY_RUN" == false ]]; then
        echo "$msg" >> "$LOG_FILE" 2>/dev/null
    fi
}

fail_msg() { echo -e "\r${RED}[FAIL]${NC}    $1... FAILED" | tee -a "$LOG_FILE"; }

show_help() {
    cat << EOF
${CYAN}jArch Installer${NC} - Arch Linux Coding Distribution

Usage: sudo ./install.sh [OPTIONS]

${YELLOW}Options:${NC}
  -h, --help              Show this help message
  -d, --dry-run           Preview installation without making changes
  -s, --skip-installed    Skip packages that are already installed
  -p, --profile PROFILE   Installation profile (minimal/standard/full)
                          minimal:  Core system + Niri + basic tools
                          standard: Minimal + dev tools + common apps
                          full:     Everything (default)

${YELLOW}Examples:${NC}
  sudo ./install.sh                    # Full installation
  sudo ./install.sh --dry-run          # Preview what will be installed
  sudo ./install.sh --profile minimal  # Minimal installation
  sudo ./install.sh --skip-installed   # Skip already installed packages

${YELLOW}Profiles:${NC}
  ${GREEN}minimal${NC}  - Niri, SDDM, Zsh, Neovim, basic CLI tools (~2GB)
  ${GREEN}standard${NC} - Minimal + Python, Node.js, Docker, Git (~4GB)
  ${GREEN}full${NC}     - Standard + Rust, Go, Java, all extras (~6GB)

For more information: https://github.com/Riain-stack/jArch
EOF
    exit 0
}

skip_if_installed() {
    local pkg=$1
    if [[ "$SKIP_INSTALLED" == true ]] && command -v "$pkg" &> /dev/null; then
        warn "$pkg already installed, skipping"
        return 1
    fi
    return 0
}

dry_run_msg() {
    [[ "$DRY_RUN" == true ]] && echo -e "${CYAN}[DRY-RUN]${NC} Would execute: $1"
}

retry_command() {
    local max_attempts=3
    local attempt=1
    local command="$@"
    
    while [ $attempt -le $max_attempts ]; do
        if eval "$command"; then
            return 0
        else
            warn "Attempt $attempt/$max_attempts failed. Retrying..."
            sleep 2
            attempt=$((attempt + 1))
        fi
    done
    
    return 1
}

handle_error() {
    local exit_code=$?
    local line_no=$1
    error "Script failed at line $line_no with exit code $exit_code"
    error "Log file: $LOG_FILE"
    exit $exit_code
}

trap 'handle_error ${LINENO}' ERR

check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        error "This script must be run on Arch Linux or Arch-based distro"
    fi
}

check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        log "Please run with sudo"
        sudo -v || error "Failed to acquire sudo permissions"
    fi
}

check_network() {
    log "Checking network connectivity..."
    if ! retry_command "ping -c 1 archlinux.org &> /dev/null"; then
        error "No internet connection. Please check your network."
    fi
    log "Network connectivity OK"
}

should_install() {
    local component=$1
    
    case "$INSTALL_PROFILE" in
        minimal)
            [[ "$component" =~ ^(base|display|sddm|niri|shell|neovim|fonts|wayland)$ ]]
            ;;
        standard)
            [[ "$component" =~ ^(base|display|sddm|niri|shell|neovim|fonts|wayland|dev_basic|docker|security|sound|aur)$ ]]
            ;;
        full)
            return 0
            ;;
        *)
            error "Unknown profile: $INSTALL_PROFILE"
            ;;
    esac
}

check_disk_space() {
    log "Checking disk space..."
    local space_kb=$(df -k / | tail -1 | awk '{print $4}')
    local space_mb=$((space_kb / 1024))
    local required_mb=10240

    if [[ $space_mb -lt $required_mb ]]; then
        error "Insufficient disk space. Need at least ${required_mb}MB free, found ${space_mb}MB"
    fi
    log "Disk space OK (${space_mb}MB free)"
}

backup_configs() {
    log "Backing up existing configurations..."
    local USER_HOME
    USER_HOME=$(eval echo ~$SUDO_USER)

    [[ -d "$USER_HOME/.config" ]] && tar -czf "$USER_HOME/.config-backup-$(date +%Y%m%d).tar.gz" "$USER_HOME/.config" 2>/dev/null
    [[ -f "$USER_HOME/.zshrc" ]] && cp "$USER_HOME/.zshrc" "$USER_HOME/.zshrc-backup-$(date +%Y%m%d)" 2>/dev/null
    [[ -f "$USER_HOME/.zshenv" ]] && cp "$USER_HOME/.zshenv" "$USER_HOME/.zshenv-backup-$(date +%Y%m%d)" 2>/dev/null

    log "Configurations backed up to $USER_HOME"
}

install_base() {
    should_install "base" || return 0
    log "Installing base packages..."
    progress "Installing base packages"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -Syu --noconfirm --needed base base-devel networkmanager sudo"
        done_msg "Installing base packages (dry-run)"
        return 0
    fi
    
    if ! retry_command "pacman -Syu --noconfirm --needed base base-devel networkmanager sudo > /dev/null 2>&1"; then
        fail_msg "Installing base packages"
        error "Failed to install base packages after retries"
    fi
    done_msg "Installing base packages"
}

install_display() {
    should_install "display" || return 0
    log "Installing display server and drivers..."
    progress "Installing display server"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed xorg-server xorg-xwayland xf86-video-amdgpu xf86-video-intel xf86-video-nouveau libgl libglvnd mesa vulkan-tools"
        done_msg "Installing display server (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed xorg-server xorg-xwayland xf86-video-amdgpu xf86-video-intel xf86-video-nouveau libgl libglvnd mesa vulkan-tools > /dev/null 2>&1" || warn "Some display packages failed"
    done_msg "Installing display server"
}

install_sddm() {
    should_install "sddm" || return 0
    log "Installing SDDM..."
    
    if [[ "$SKIP_INSTALLED" == true ]] && pacman -Q sddm &> /dev/null; then
        warn "SDDM already installed, skipping"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed sddm && systemctl enable sddm.service"
        return 0
    fi
    
    if ! pacman -Q sddm &> /dev/null; then
        pacman -S --noconfirm --needed sddm
        systemctl enable sddm.service || true
    fi
}

install_niri() {
    should_install "niri" || return 0
    log "Installing Niri..."
    progress "Installing Niri"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed niri"
        done_msg "Installing Niri (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed niri" || error "Failed to install Niri"
    done_msg "Installing Niri"
}

install_shell_tools() {
    should_install "shell" || return 0
    log "Installing shell tools..."
    progress "Installing shell tools"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed zsh zsh-completions fzf ripgrep bat exa fd dust tmux htop btop neofetch"
        done_msg "Installing shell tools (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed zsh zsh-completions fzf ripgrep bat exa fd dust tmux htop btop neofetch > /dev/null 2>&1" || warn "Some shell tools failed"
    done_msg "Installing shell tools"
}

install_dev_tools() {
    should_install "dev_basic" || return 0
    log "Installing development tools..."
    progress "Installing development tools"

    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed git python nodejs rust go docker [and more dev tools]"
        done_msg "Installing development tools (dry-run)"
        return 0
    fi

    local basic_tools="git git-lfs git-delta make cmake ninja gcc clang python python-pip nodejs npm curl wget unzip zip jq"
    local full_tools="lazygit llvm gdb lldb valgrind docker docker-compose python-pipx python-poetry python-virtualenv pnpm yarn rust cargo go jdk-openjdk maven gradle sbt swig patch diffutils patchutils automake autoconf libtool pkgconf bison flex gperf intltool which p7zip yq httpie rsync cpio tar gzip xz bzip2 lz4 zstd"

    if [[ "$INSTALL_PROFILE" == "full" ]]; then
        retry_command "pacman -S --noconfirm --needed $basic_tools $full_tools > /dev/null 2>&1" || warn "Some dev tools failed"
    else
        retry_command "pacman -S --noconfirm --needed $basic_tools > /dev/null 2>&1" || warn "Some dev tools failed"
    fi

    done_msg "Installing development tools"
}

install_neovim() {
    should_install "neovim" || return 0
    log "Installing Neovim..."
    progress "Installing Neovim"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed neovim ripgrep fd unzip"
        done_msg "Installing Neovim (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed neovim ripgrep fd unzip" || error "Failed to install Neovim"

    if command -v nvim &> /dev/null; then
        su - $SUDO_USER -c "nvim --headless '+Lazy! sync' +qa" 2>/dev/null || true
    fi
    done_msg "Installing Neovim"
}

install_aur_helper() {
    should_install "aur" || return 0
    log "Installing paru AUR helper..."
    
    if [[ "$SKIP_INSTALLED" == true ]] && command -v paru &> /dev/null; then
        warn "paru already installed, skipping"
        return 0
    fi

    progress "Installing paru"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "git clone https://aur.archlinux.org/paru.git && makepkg -si"
        done_msg "Installing paru (dry-run)"
        return 0
    fi
    
    command -v paru &> /dev/null && { warn "paru already installed"; return; }

    cd /tmp || error "Cannot access /tmp"
    rm -rf /tmp/paru
    sudo -u $SUDO_USER git clone https://aur.archlinux.org/paru.git || error "Failed to clone paru"
    cd paru || error "Failed to enter paru directory"
    sudo -u $SUDO_USER makepkg -si --noconfirm > /dev/null 2>&1 || warn "Paru installation failed"
    cd - || true
    rm -rf /tmp/paru
    done_msg "Installing paru"
}

install_aur_packages() {
    should_install "aur" || return 0
    log "Installing AUR packages..."
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "paru -S --noconfirm starship zsh-fast-syntax-highlighting zsh-autosuggestions zsh-vi-mode"
        done_msg "Installing AUR packages (dry-run)"
        return 0
    fi
    
    command -v paru &> /dev/null || { warn "paru not available, skipping AUR packages"; return; }

    progress "Installing AUR packages"
    sudo -u $SUDO_USER paru -S --noconfirm \
        starship zsh-fast-syntax-highlighting zsh-autosuggestions zsh-vi-mode > /dev/null 2>&1 \
        || warn "AUR package installation failed"
    done_msg "Installing AUR packages"
}

setup_dotfiles() {
    log "Setting up dotfiles..."
    local USER_HOME
    USER_HOME=$(eval echo ~$SUDO_USER)

    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "cp -r dotfiles/.config/* $USER_HOME/.config/ && chsh -s /bin/zsh"
        return 0
    fi

    mkdir -p "$USER_HOME/.config" "$USER_HOME/.local/share" "$USER_HOME/.cache"

    cp -r "${SCRIPT_DIR}/dotfiles/.config/"* "$USER_HOME/.config/"
    ln -sf "$USER_HOME/.config/zsh/.zshrc" "$USER_HOME/.zshrc"

    chown -R $SUDO_USER:$SUDO_USER "$USER_HOME/.config" "$USER_HOME/.zshrc"

    if ! grep -q "${SUDO_USER}.*zsh" /etc/passwd; then
        chsh -s /bin/zsh $SUDO_USER || warn "Failed to set default shell to zsh"
    fi
}

create_user_configs() {
    log "Creating user configurations..."
    local USER_HOME
    USER_HOME=$(eval echo ~$SUDO_USER)

    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "Create $USER_HOME/.zshenv with environment variables"
        return 0
    fi

    cat > "$USER_HOME/.zshenv" << 'EOF'
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export EDITOR="nvim"
export VISUAL="nvim"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export BAT_THEME="Dracula"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
EOF

    chown $SUDO_USER:$SUDO_USER "$USER_HOME/.zshenv"
}

verify_installation() {
    log "Verifying installation..."
    local failed=0
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Skipping verification in dry-run mode"
        return 0
    fi
    
    # Check critical components
    local critical_components=(
        "niri:Niri compositor"
        "zsh:Zsh shell"
        "nvim:Neovim"
    )
    
    for item in "${critical_components[@]}"; do
        IFS=: read -r cmd name <<< "$item"
        if ! command -v "$cmd" &> /dev/null; then
            error "$name not found - installation may have failed"
            failed=1
        else
            log "✓ $name installed"
        fi
    done
    
    # Check optional components based on profile
    if [[ "$INSTALL_PROFILE" != "minimal" ]]; then
        local opt_components=(
            "git:Git"
            "python:Python"
            "node:Node.js"
        )
        
        for item in "${opt_components[@]}"; do
            IFS=: read -r cmd name <<< "$item"
            if ! command -v "$cmd" &> /dev/null; then
                warn "$name not found"
            else
                log "✓ $name installed"
            fi
        done
    fi
    
    if [[ "$INSTALL_PROFILE" == "full" ]]; then
        local full_components=(
            "docker:Docker"
            "rustc:Rust"
            "go:Go"
            "javac:Java"
        )
        
        for item in "${full_components[@]}"; do
            IFS=: read -r cmd name <<< "$item"
            if ! command -v "$cmd" &> /dev/null; then
                warn "$name not found"
            else
                log "✓ $name installed"
            fi
        done
    fi
    
    # Check services
    if systemctl is-enabled sddm.service &> /dev/null; then
        log "✓ SDDM service enabled"
    else
        warn "SDDM service not enabled"
    fi
    
    log "Verification complete!"
    return $failed
}

install_fonts() {
    should_install "fonts" || return 0
    log "Installing fonts..."
    progress "Installing fonts"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed ttf-meslo ttf-jetbrains-mono noto-fonts [and more]"
        done_msg "Installing fonts (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed ttf-meslo ttf-jetbrains-mono ttf-fira-mono ttf-dejavu noto-fonts noto-fonts-cjk noto-fonts-emoji > /dev/null 2>&1" || warn "Some fonts failed"
    done_msg "Installing fonts"
}

install_additional_tools() {
    should_install "extras" || return 0
    log "Installing additional coding tools..."
    progress "Installing additional tools"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed alacritty firefox discord obsidian code [and more]"
        done_msg "Installing additional tools (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed alacritty firefox discord obsidian code gedit evince file-roller thunar gvfs gvfs-mtp gvfs-smb tumbler ffmpeg imagemagick mpv zathura zathura-pdf-mupdf > /dev/null 2>&1" || warn "Some additional tools failed"
    done_msg "Installing additional tools"
}

setup_docker() {
    should_install "docker" || return 0
    log "Setting up Docker..."
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "usermod -aG docker $SUDO_USER && systemctl enable docker.service"
        return 0
    fi
    
    if ! groups $SUDO_USER | grep -q docker; then
        usermod -aG docker $SUDO_USER
        log "Added $SUDO_USER to docker group (requires logout)"
    fi

    if ! systemctl is-active docker &> /dev/null; then
        systemctl enable docker.service || true
        systemctl start docker.service || warn "Docker service failed to start"
    fi
}

install_wayland_tools() {
    should_install "wayland" || return 0
    log "Installing Wayland tools..."
    progress "Installing Wayland tools"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed waybar rofi grim slurp wl-clipboard"
        done_msg "Installing Wayland tools (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed waybar rofi grim slurp wl-clipboard" || warn "Some Wayland tools failed"
    done_msg "Installing Wayland tools"
}

install_security_tools() {
    should_install "security" || return 0
    log "Installing security tools..."
    progress "Installing security tools"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed ufw fail2ban openssh"
        done_msg "Installing security tools (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed ufw fail2ban openssh" || warn "Some security tools failed"
    done_msg "Installing security tools"
}

setup_firewall() {
    should_install "security" || return 0
    log "Setting up firewall..."

    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "ufw --force enable && ufw allow SSH"
        return 0
    fi

    if command -v ufw &> /dev/null; then
        ufw --force enable
        ufw allow SSH
        log "UFW firewall enabled with SSH allowed"
    fi
}

install_sound() {
    should_install "sound" || return 0
    log "Installing sound support..."
    progress "Installing sound support"
    
    if [[ "$DRY_RUN" == true ]]; then
        dry_run_msg "pacman -S --noconfirm --needed pipewire pipewire-pulse wireplumber"
        done_msg "Installing sound support (dry-run)"
        return 0
    fi
    
    retry_command "pacman -S --noconfirm --needed pipewire pipewire-pulse wireplumber" || warn "Sound installation failed"
    done_msg "Installing sound support"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -d|--dry-run)
                DRY_RUN=true
                log "Running in dry-run mode (no changes will be made)"
                shift
                ;;
            -s|--skip-installed)
                SKIP_INSTALLED=true
                log "Will skip already installed packages"
                shift
                ;;
            -p|--profile)
                INSTALL_PROFILE="$2"
                if [[ ! "$INSTALL_PROFILE" =~ ^(minimal|standard|full)$ ]]; then
                    error "Invalid profile: $INSTALL_PROFILE. Must be minimal, standard, or full"
                fi
                log "Using installation profile: $INSTALL_PROFILE"
                shift 2
                ;;
            *)
                error "Unknown option: $1. Use --help for usage information"
                ;;
        esac
    done
}

calculate_steps() {
    # Only functions that call progress() are counted
    # Minimal: base, display, niri, shell, neovim, fonts, wayland
    # Standard adds: dev_tools, paru, aur_packages, security, sound
    # Full adds: additional_tools
    case "$INSTALL_PROFILE" in
        minimal)
            TOTAL_STEPS=7  # base, display, niri, shell, neovim, fonts, wayland
            ;;
        standard)
            TOTAL_STEPS=12  # minimal(7) + dev_tools, paru, aur_packages, security, sound
            ;;
        full)
            TOTAL_STEPS=13  # standard(12) + additional_tools
            ;;
    esac
}

main() {
    parse_args "$@"
    
    if [[ -z "$SUDO_USER" ]]; then
        SUDO_USER=$(who | awk 'NR==1 {print $1}')
        export SUDO_USER
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && cd .. && pwd)"

    log "=========================================="
    log "jArch - Arch Linux Coding Distro Installer"
    log "=========================================="
    log "Profile: $INSTALL_PROFILE"
    log "Target user: $SUDO_USER"
    [[ "$DRY_RUN" == true ]] && log "Mode: DRY-RUN (no changes will be made)"
    [[ "$SKIP_INSTALLED" == true ]] && log "Mode: Skip already installed packages"
    log "=========================================="
    log ""

    calculate_steps

    check_arch
    check_network
    check_disk_space

    if [[ "$DRY_RUN" == false ]]; then
        log "Updating system..."
        retry_command "pacman -Syu --noconfirm" || warn "System update failed, continuing..."
    fi

    check_sudo
    install_base
    install_display
    install_sddm
    install_niri
    install_shell_tools
    install_dev_tools
    install_neovim
    install_aur_helper
    install_aur_packages
    install_fonts
    install_additional_tools
    install_wayland_tools
    install_security_tools
    setup_firewall
    install_sound
    backup_configs
    setup_dotfiles
    create_user_configs
    setup_docker
    
    verify_installation

    log ""
    log "=========================================="
    if [[ "$DRY_RUN" == true ]]; then
        log "Dry-run complete! No changes were made."
        log "Run without --dry-run to perform actual installation."
    else
        log "Installation complete!"
    fi
    log "=========================================="
    log ""
    
    if [[ "$DRY_RUN" == false ]]; then
        log "Next steps:"
        log "1. Reboot your system"
        log "2. SDDM will start automatically"
        log "3. Login with your user account"
        log "4. Starship prompt will configure on first launch"
        log ""
        
        log "Key features installed ($INSTALL_PROFILE profile):"
        log "  - Niri Wayland compositor"
        log "  - SDDM display manager"
        log "  - Zsh with starship, autosuggestions, syntax highlighting, vi-mode"
        log "  - Neovim with lazy.nvim, LSP, treesitter, Kanagawa theme"
        
        if [[ "$INSTALL_PROFILE" != "minimal" ]]; then
            log "  - Development tools (Python, Node.js, Git, Docker)"
        fi
        
        if [[ "$INSTALL_PROFILE" == "full" ]]; then
            log "  - Extended dev tools (Rust, Go, Java, Maven, Gradle)"
            log "  - Additional apps (Firefox, Discord, Obsidian, VS Code)"
        fi
        
        log "  - Modern CLI tools (ripgrep, fd, fzf, bat, exa, dust, btop)"
        log "  - Security (UFW, fail2ban, openssh)"
        log "  - Sound (PipeWire)"
        log "  - Wayland tools (waybar, rofi, grim, slurp, wl-clipboard)"
        log ""
        log "Configurations:"
        log "  - ~/.config/niri/config.kdl  - Window manager"
        log "  - ~/.config/starship.toml     - Prompt theme"
        log "  - ~/.config/zsh/.zshrc        - Shell config"
        log "  - ~/.config/nvim/init.lua     - Neovim config"
        log "  - ~/.zshenv                    - Environment"
        log ""
        log "Keyboard shortcuts (Niri - Mod = Super/Win):"
        log "  Mod+Shift+Return - Terminal"
        log "  Mod+Shift+E       - Exit Niri"
        log "  Mod+1-5           - Switch workspaces"
        log "  Mod+F             - Maximize"
        log "  Mod+Shift+F       - Fullscreen"
    fi
    
    log ""
    log "Installation log saved to: $LOG_FILE"
    log ""
}

main "$@"