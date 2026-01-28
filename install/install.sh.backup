#!/usr/bin/env bash
set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

LOG_FILE="/var/log/arch-coding-install-$(date +%Y%m%d-%H%M%S).log"
STATE_FILE="/var/tmp/jarch-install-state"

# Installation options
DRY_RUN=false
RESUME=false
SKIP_AUR=false
SKIP_DOCKER=false
SKIP_FONTS=false
SKIP_GUI=false
VERBOSE=false

# Progress tracking
TOTAL_STEPS=20
CURRENT_STEP=0

log() { echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }

progress() { 
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percent=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    echo -ne "\r${BLUE}[${percent}%]${NC} $1..." | tee -a "$LOG_FILE"
}
done_msg() { echo -e "\r${GREEN}[DONE]${NC}    $1... OK" | tee -a "$LOG_FILE"; }

fail_msg() { echo -e "\r${RED}[FAIL]${NC}    $1... FAILED" | tee -a "$LOG_FILE"; }

skip_if_installed() {
    local pkg=$1
    if command -v "$pkg" &> /dev/null; then
        warn "$pkg already installed, skipping"
        return 1
    fi
    return 0
}

# State management for resume functionality
save_state() {
    local step=$1
    if [[ "$DRY_RUN" == false ]]; then
        echo "$step" > "$STATE_FILE"
        echo "$(date +%s)" >> "$STATE_FILE"
    fi
}

load_state() {
    if [[ -f "$STATE_FILE" ]]; then
        LAST_STEP=$(head -n 1 "$STATE_FILE")
        LAST_TIME=$(tail -n 1 "$STATE_FILE")
        log "Found previous installation state at step: $LAST_STEP"
        return 0
    fi
    return 1
}

should_skip_step() {
    local step=$1
    if [[ "$RESUME" == true ]] && [[ -n "$LAST_STEP" ]]; then
        # Define step order
        local steps=("check_arch" "check_network" "check_disk_space" "install_base" 
                     "install_display" "install_sddm" "install_niri" "install_shell_tools"
                     "install_dev_tools" "install_neovim" "install_aur_helper" 
                     "install_aur_packages" "install_fonts" "install_additional_tools"
                     "install_wayland_tools" "install_security_tools" "setup_firewall"
                     "install_sound" "backup_configs" "setup_dotfiles" "create_user_configs"
                     "setup_docker")
        
        local found_last=false
        for s in "${steps[@]}"; do
            if [[ "$s" == "$LAST_STEP" ]]; then
                found_last=true
            fi
            if [[ "$s" == "$step" ]] && [[ "$found_last" == false ]]; then
                return 0  # Skip this step
            fi
        done
    fi
    return 1  # Don't skip
}

show_help() {
    cat << EOF
${CYAN}jArch Installer${NC} - Arch Linux Coding Distribution

${GREEN}Usage:${NC}
    sudo ./install.sh [OPTIONS]

${GREEN}Options:${NC}
    --dry-run           Preview installation without making changes
    --resume            Resume from previous failed installation
    --skip-aur          Skip AUR helper and AUR packages installation
    --skip-docker       Skip Docker installation and setup
    --skip-fonts        Skip fonts installation
    --skip-gui          Skip GUI applications (Firefox, Discord, etc.)
    --verbose           Show detailed output from package installations
    -h, --help          Show this help message

${GREEN}Examples:${NC}
    sudo ./install.sh                    # Full installation
    sudo ./install.sh --dry-run          # Preview what will be installed
    sudo ./install.sh --resume           # Resume interrupted installation
    sudo ./install.sh --skip-aur --skip-docker

${GREEN}Features:${NC}
    • Progress tracking with percentage completion
    • Resume capability for interrupted installations
    • Selective component installation
    • Comprehensive error messages with suggestions
    • Automatic configuration backups

EOF
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                log "Dry-run mode enabled - no changes will be made"
                shift
                ;;
            --resume)
                RESUME=true
                shift
                ;;
            --skip-aur)
                SKIP_AUR=true
                log "Will skip AUR packages installation"
                shift
                ;;
            --skip-docker)
                SKIP_DOCKER=true
                log "Will skip Docker installation"
                shift
                ;;
            --skip-fonts)
                SKIP_FONTS=true
                log "Will skip fonts installation"
                shift
                ;;
            --skip-gui)
                SKIP_GUI=true
                log "Will skip GUI applications"
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                error "Unknown option: $1\nUse --help for usage information"
                ;;
        esac
    done
}

handle_error() {
    local exit_code=$?
    local line_no=$1
    error "Script failed at line $line_no with exit code $exit_code"
    error "Log file: $LOG_FILE"
    echo ""
    echo -e "${YELLOW}Troubleshooting suggestions:${NC}"
    echo "  1. Check the log file: cat $LOG_FILE"
    echo "  2. Verify internet connection: ping -c 3 archlinux.org"
    echo "  3. Update package database: sudo pacman -Sy"
    echo "  4. Resume installation: sudo ./install.sh --resume"
    echo ""
    echo -e "${CYAN}For more help, visit: https://github.com/Riain-stack/jArch/issues${NC}"
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
    if should_skip_step "check_network"; then
        log "Skipping network check (already completed)"
        return
    fi
    
    progress "Checking network connectivity"
    if [[ "$DRY_RUN" == true ]]; then
        done_msg "Checking network connectivity (dry-run)"
        return
    fi
    
    if ! ping -c 1 archlinux.org &> /dev/null; then
        fail_msg "Checking network connectivity"
        echo ""
        echo -e "${YELLOW}Network troubleshooting:${NC}"
        echo "  • Check if you're connected: ip link show"
        echo "  • Test DNS: nslookup archlinux.org"
        echo "  • Restart NetworkManager: systemctl restart NetworkManager"
        error "No internet connection. Please check your network."
    fi
    done_msg "Checking network connectivity"
    save_state "check_network"
}

check_disk_space() {
    if should_skip_step "check_disk_space"; then
        log "Skipping disk space check (already completed)"
        return
    fi
    
    progress "Checking disk space"
    local space_kb=$(df -k / | tail -1 | awk '{print $4}')
    local space_mb=$((space_kb / 1024))
    local required_mb=10240

    if [[ $space_mb -lt $required_mb ]]; then
        fail_msg "Checking disk space"
        echo ""
        echo -e "${YELLOW}Disk space troubleshooting:${NC}"
        echo "  • Clean package cache: sudo pacman -Scc"
        echo "  • Remove orphaned packages: sudo pacman -Rns \$(pacman -Qtdq)"
        echo "  • Check large files: du -sh /* | sort -h"
        error "Insufficient disk space. Need at least ${required_mb}MB free, found ${space_mb}MB"
    fi
    done_msg "Checking disk space (${space_mb}MB free)"
    save_state "check_disk_space"
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
    if should_skip_step "install_base"; then
        log "Skipping base packages (already installed)"
        return
    fi
    
    progress "Installing base packages"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would install: base base-devel networkmanager sudo"
        done_msg "Installing base packages (dry-run)"
        return
    fi
    
    local cmd_output="/dev/null"
    [[ "$VERBOSE" == true ]] && cmd_output="/dev/stdout"
    
    if ! pacman -Syu --noconfirm --needed base base-devel networkmanager sudo > "$cmd_output" 2>&1; then
        fail_msg "Installing base packages"
        warn "System update failed, retrying..."
        pacman -Syu --noconfirm --needed base base-devel networkmanager sudo > "$cmd_output" 2>&1 || {
            echo -e "${YELLOW}Suggestion: Try 'sudo pacman -Sy archlinux-keyring' first${NC}"
            error "Failed to install base packages"
        }
    fi
    done_msg "Installing base packages"
    save_state "install_base"
}

install_display() {
    log "Installing display server and drivers..."
    progress "Installing display server"
    pacman -S --noconfirm --needed xorg-server xorg-xwayland xf86-video-amdgpu xf86-video-intel xf86-video-nouveau libgl libglvnd mesa vulkan-tools > /dev/null 2>&1
    done_msg "Installing display server"
}

install_sddm() {
    log "Installing SDDM..."
    if pacman -Q sddm &> /dev/null; then
        warn "SDDM already installed"
    else
        pacman -S --noconfirm --needed sddm
        systemctl enable sddm.service || true
    fi
}

install_niri() {
    log "Installing Niri..."
    pacman -S --noconfirm --needed niri
}

install_shell_tools() {
    log "Installing shell tools..."
    progress "Installing shell tools"
    pacman -S --noconfirm --needed zsh zsh-completions fzf ripgrep bat exa fd dust tmux htop btop neofetch > /dev/null 2>&1
    done_msg "Installing shell tools"
}

install_dev_tools() {
    if should_skip_step "install_dev_tools"; then
        log "Skipping development tools (already installed)"
        return
    fi
    
    progress "Installing development tools"
    
    local packages=(
        git git-lfs git-delta lazygit
        make cmake ninja gcc clang llvm gdb lldb valgrind
        python python-pip python-pipx python-poetry python-virtualenv
        nodejs npm pnpm yarn
        rust cargo go
        jdk-openjdk maven gradle sbt
        swig patch diffutils patchutils automake autoconf libtool pkgconf bison flex gperf intltool which
        unzip zip p7zip jq yq httpie curl wget rsync cpio tar gzip xz bzip2 lz4 zstd
    )
    
    # Add docker if not skipped
    if [[ "$SKIP_DOCKER" == false ]]; then
        packages+=(docker docker-compose)
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would install development tools: ${packages[*]}"
        done_msg "Installing development tools (dry-run)"
        return
    fi
    
    local cmd_output="/dev/null"
    [[ "$VERBOSE" == true ]] && cmd_output="/dev/stdout"

    pacman -S --noconfirm --needed "${packages[@]}" > "$cmd_output" 2>&1

    done_msg "Installing development tools"
    save_state "install_dev_tools"
}

install_neovim() {
    log "Installing Neovim..."
    pacman -S --noconfirm --needed neovim ripgrep fd unzip

    if command -v nvim &> /dev/null; then
        su - $SUDO_USER -c "nvim --headless '+Lazy! sync' +qa" 2>/dev/null || true
    fi
}

install_aur_helper() {
    if [[ "$SKIP_AUR" == true ]]; then
        log "Skipping AUR helper installation (--skip-aur)"
        return
    fi
    
    if should_skip_step "install_aur_helper"; then
        log "Skipping paru (already installed)"
        return
    fi
    
    command -v paru &> /dev/null && { warn "paru already installed"; save_state "install_aur_helper"; return; }

    progress "Installing paru AUR helper"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would install paru from AUR"
        done_msg "Installing paru (dry-run)"
        return
    fi
    
    cd /tmp || error "Cannot access /tmp"
    rm -rf /tmp/paru
    sudo -u $SUDO_USER git clone https://aur.archlinux.org/paru.git || {
        echo -e "${YELLOW}Suggestion: Check if git is installed and you have internet access${NC}"
        error "Failed to clone paru"
    }
    cd paru || error "Failed to enter paru directory"
    
    local cmd_output="/dev/null"
    [[ "$VERBOSE" == true ]] && cmd_output="/dev/stdout"
    
    sudo -u $SUDO_USER makepkg -si --noconfirm > "$cmd_output" 2>&1 || warn "Paru installation failed"
    cd - || true
    rm -rf /tmp/paru
    done_msg "Installing paru"
    save_state "install_aur_helper"
}

install_aur_packages() {
    if [[ "$SKIP_AUR" == true ]]; then
        log "Skipping AUR packages (--skip-aur)"
        return
    fi
    
    if should_skip_step "install_aur_packages"; then
        log "Skipping AUR packages (already installed)"
        return
    fi
    
    command -v paru &> /dev/null || { warn "paru not available, skipping AUR packages"; return; }

    progress "Installing AUR packages"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would install: starship zsh-fast-syntax-highlighting zsh-autosuggestions zsh-vi-mode"
        done_msg "Installing AUR packages (dry-run)"
        return
    fi
    
    local cmd_output="/dev/null"
    [[ "$VERBOSE" == true ]] && cmd_output="/dev/stdout"
    
    sudo -u $SUDO_USER paru -S --noconfirm \
        starship zsh-fast-syntax-highlighting zsh-autosuggestions zsh-vi-mode > "$cmd_output" 2>&1 \
        || warn "AUR package installation failed"
    done_msg "Installing AUR packages"
    save_state "install_aur_packages"
}

setup_dotfiles() {
    if should_skip_step "setup_dotfiles"; then
        log "Skipping dotfiles setup (already configured)"
        return
    fi
    
    progress "Setting up dotfiles"
    
    local USER_HOME
    USER_HOME=$(eval echo ~$SUDO_USER)
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would copy dotfiles to $USER_HOME/.config/"
        log "Would create symlink: ~/.zshrc -> ~/.config/zsh/.zshrc"
        log "Would set default shell to zsh for $SUDO_USER"
        done_msg "Setting up dotfiles (dry-run)"
        return
    fi

    mkdir -p "$USER_HOME/.config" "$USER_HOME/.local/share" "$USER_HOME/.cache"

    if [[ -d "${SCRIPT_DIR}/dotfiles/.config" ]]; then
        cp -r "${SCRIPT_DIR}/dotfiles/.config/"* "$USER_HOME/.config/"
        ln -sf "$USER_HOME/.config/zsh/.zshrc" "$USER_HOME/.zshrc"
        chown -R $SUDO_USER:$SUDO_USER "$USER_HOME/.config" "$USER_HOME/.zshrc"
    else
        warn "Dotfiles directory not found at ${SCRIPT_DIR}/dotfiles/.config"
    fi

    if ! grep -q "${SUDO_USER}.*zsh" /etc/passwd; then
        chsh -s /bin/zsh $SUDO_USER || warn "Failed to set default shell to zsh"
    fi
    done_msg "Setting up dotfiles"
    save_state "setup_dotfiles"
}

create_user_configs() {
    log "Creating user configurations..."
    local USER_HOME
    USER_HOME=$(eval echo ~$SUDO_USER)

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

install_fonts() {
    if [[ "$SKIP_FONTS" == true ]]; then
        log "Skipping fonts installation (--skip-fonts)"
        return
    fi
    
    if should_skip_step "install_fonts"; then
        log "Skipping fonts (already installed)"
        return
    fi
    
    progress "Installing fonts"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would install: ttf-meslo ttf-jetbrains-mono ttf-fira-mono ttf-dejavu noto-fonts noto-fonts-cjk noto-fonts-emoji"
        done_msg "Installing fonts (dry-run)"
        return
    fi
    
    local cmd_output="/dev/null"
    [[ "$VERBOSE" == true ]] && cmd_output="/dev/stdout"
    
    pacman -S --noconfirm --needed \
        ttf-meslo ttf-jetbrains-mono ttf-fira-mono ttf-dejavu \
        noto-fonts noto-fonts-cjk noto-fonts-emoji > "$cmd_output" 2>&1
    done_msg "Installing fonts"
    save_state "install_fonts"
}

install_additional_tools() {
    if [[ "$SKIP_GUI" == true ]]; then
        log "Skipping GUI applications (--skip-gui)"
        # Still install Alacritty terminal
        if [[ "$DRY_RUN" == false ]]; then
            pacman -S --noconfirm --needed alacritty > /dev/null 2>&1
        fi
        return
    fi
    
    if should_skip_step "install_additional_tools"; then
        log "Skipping additional tools (already installed)"
        return
    fi
    
    progress "Installing additional tools"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would install: alacritty firefox discord obsidian code gedit evince file-roller thunar gvfs ffmpeg imagemagick mpv zathura"
        done_msg "Installing additional tools (dry-run)"
        return
    fi
    
    local cmd_output="/dev/null"
    [[ "$VERBOSE" == true ]] && cmd_output="/dev/stdout"
    
    pacman -S --noconfirm --needed \
        alacritty firefox discord obsidian code gedit evince \
        file-roller thunar gvfs gvfs-mtp gvfs-smb tumbler \
        ffmpeg imagemagick mpv zathura zathura-pdf-mupdf > "$cmd_output" 2>&1
    done_msg "Installing additional tools"
    save_state "install_additional_tools"
}

setup_docker() {
    if [[ "$SKIP_DOCKER" == true ]]; then
        log "Skipping Docker setup (--skip-docker)"
        return
    fi
    
    if should_skip_step "setup_docker"; then
        log "Skipping Docker setup (already configured)"
        return
    fi
    
    progress "Setting up Docker"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would add $SUDO_USER to docker group and enable docker service"
        done_msg "Setting up Docker (dry-run)"
        return
    fi
    
    if ! groups $SUDO_USER | grep -q docker; then
        usermod -aG docker $SUDO_USER
        log "Added $SUDO_USER to docker group (logout required to take effect)"
    fi

    if ! systemctl is-active docker &> /dev/null; then
        systemctl enable docker.service || true
        systemctl start docker.service || warn "Docker service failed to start"
    fi
    done_msg "Setting up Docker"
    save_state "setup_docker"
}

install_wayland_tools() {
    log "Installing Wayland tools..."
    pacman -S --noconfirm --needed waybar rofi grim slurp wl-clipboard
}

install_security_tools() {
    log "Installing security tools..."
    pacman -S --noconfirm --needed ufw fail2ban openssh
}

setup_firewall() {
    log "Setting up firewall..."

    if command -v ufw &> /dev/null; then
        ufw --force enable
        ufw allow SSH
        log "UFW firewall enabled with SSH allowed"
    fi
}

install_sound() {
    log "Installing sound support..."
    pacman -S --noconfirm --needed pipewire pipewire-pulse wireplumber
}

main() {
    parse_args "$@"
    
    if [[ -z "$SUDO_USER" ]]; then
        SUDO_USER=$(who | awk 'NR==1 {print $1}')
        export SUDO_USER
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && cd .. && pwd)"

    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║         jArch - Arch Linux Coding Distribution        ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}DRY-RUN MODE: No changes will be made${NC}"
        echo ""
    fi
    
    if [[ "$RESUME" == true ]]; then
        if load_state; then
            log "Resuming installation from: $LAST_STEP"
        else
            warn "No previous installation state found, starting fresh"
            RESUME=false
        fi
    fi

    log "Starting Arch Coding Distro installation..."
    log "Target user: $SUDO_USER"
    log "Log file: $LOG_FILE"
    echo ""

    check_arch
    check_network
    check_disk_space

    if [[ "$DRY_RUN" == false ]]; then
        progress "Updating system"
        pacman -Syu --noconfirm > /dev/null 2>&1 || warn "System update failed, continuing..."
        done_msg "Updating system"
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

    # Clean up state file on successful completion
    [[ -f "$STATE_FILE" ]] && rm -f "$STATE_FILE"
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          Installation Complete Successfully!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Dry-run completed. No changes were made."
        log "Run without --dry-run to perform actual installation."
        exit 0
    fi
    
    log "${GREEN}Next steps:${NC}"
    log "  1. Reboot your system"
    log "  2. SDDM will start automatically"
    log "  3. Login with your user account"
    log "  4. Starship prompt will configure on first launch"
    echo ""
    log "${CYAN}Key features installed:${NC}"
    log "  • Niri Wayland compositor"
    log "  • SDDM display manager"
    log "  • Zsh with starship, autosuggestions, syntax highlighting, vi-mode"
    log "  • Neovim with lazy.nvim, LSP, treesitter, Kanagawa theme"
    log "  • Development tools (Python, Node.js, Rust, Go, Java)"
    [[ "$SKIP_DOCKER" == false ]] && log "  • Docker and docker-compose"
    [[ "$SKIP_AUR" == false ]] && log "  • AUR helper (paru) with additional packages"
    log "  • Git, tmux, lazygit"
    log "  • Modern CLI tools (ripgrep, fd, fzf, bat, exa, dust, btop)"
    log "  • Security (UFW, fail2ban, openssh)"
    log "  • Sound (PipeWire)"
    log "  • Wayland tools (waybar, rofi, grim, slurp, wl-clipboard)"
    echo ""
    log "${MAGENTA}Configuration files:${NC}"
    log "  ~/.config/niri/config.kdl  - Window manager"
    log "  ~/.config/starship.toml     - Prompt theme"
    log "  ~/.config/zsh/.zshrc        - Shell config"
    log "  ~/.config/nvim/init.lua     - Neovim config"
    log "  ~/.zshenv                    - Environment variables"
    echo ""
    log "Installation log: $LOG_FILE"
    echo ""
    log "${BLUE}Keyboard shortcuts (Niri - Mod = Super/Win):${NC}"
    log "  Mod+Shift+Return - Terminal"
    log "  Mod+Shift+E      - Exit Niri"
    log "  Mod+1-5          - Switch workspaces"
    log "  Mod+F            - Maximize"
    log "  Mod+Shift+F      - Fullscreen"
    echo ""
    echo -e "${YELLOW}Note: If installation was interrupted, run: sudo ./install.sh --resume${NC}"
}

main "$@"