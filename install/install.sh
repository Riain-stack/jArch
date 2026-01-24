#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

progress() { echo -ne "\r${BLUE}[PROGRESS]${NC} $1..."; }
done_msg() { echo -e "\r${GREEN}[DONE]${NC}    $1... OK"; }

skip_if_installed() {
    local pkg=$1
    if command -v "$pkg" &> /dev/null; then
        warn "$pkg already installed, skipping"
        return 1
    fi
    return 0
}

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
    if ! ping -c 1 archlinux.org &> /dev/null; then
        error "No internet connection. Please check your network."
    fi
    log "Network connectivity OK"
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
    log "Installing base packages..."
    pacman -Syu --noconfirm --needed base base-devel networkmanager sudo
}

install_display() {
    log "Installing display server and drivers..."
    pacman -S --noconfirm --needed xorg-server xorg-xwayland xf86-video-amdgpu xf86-video-intel xf86-video-nouveau libgl libglvnd mesa vulkan-tools
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
    pacman -S --noconfirm --needed zsh zsh-completions fzf ripgrep bat exa fd dust tmux htop btop neofetch
}

install_dev_tools() {
    log "Installing development tools..."

    pacman -S --noconfirm --needed \
        git git-lfs git-delta lazygit \
        make cmake ninja gcc clang llvm gdb lldb valgrind \
        docker docker-compose \
        python python-pip python-pipx python-poetry python-virtualenv \
        nodejs npm pnpm yarn \
        rust cargo go \
        jdk-openjdk maven gradle sbt \
        swig patch diffutils patchutils automake autoconf libtool pkgconf bison flex gperf intltool which \
        unzip zip p7zip jq yq httpie curl wget rsync cpio tar gzip xz bzip2 lz4 zstd
}

install_neovim() {
    log "Installing Neovim..."
    pacman -S --noconfirm --needed neovim ripgrep fd unzip

    if command -v nvim &> /dev/null; then
        su - $SUDO_USER -c "nvim --headless '+Lazy! sync' +qa" 2>/dev/null || true
    fi
}

install_aur_helper() {
    log "Installing paru AUR helper..."
    command -v paru &> /dev/null && { warn "paru already installed"; return; }

    cd /tmp
    sudo -u $SUDO_USER git clone https://aur.archlinux.org/paru.git
    cd paru
    sudo -u $SUDO_USER makepkg -si --noconfirm --noextract
    cd -
    rm -rf /tmp/paru
}

install_aur_packages() {
    log "Installing AUR packages..."
    command -v paru &> /dev/null && \
        sudo -u $SUDO_USER paru -S --noconfirm \
            starship zsh-fast-syntax-highlighting zsh-autosuggestions zsh-vi-mode \
        || warn "paru not available, skipping AUR packages"
}

setup_dotfiles() {
    log "Setting up dotfiles..."
    local USER_HOME
    USER_HOME=$(eval echo ~$SUDO_USER)

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
    log "Installing fonts..."
    pacman -S --noconfirm --needed \
        ttf-meslo ttf-jetbrains-mono ttf-fira-mono ttf-dejavu \
        noto-fonts noto-fonts-cjk noto-fonts-emoji
}

install_additional_tools() {
    log "Installing additional coding tools..."
    pacman -S --noconfirm --needed \
        alacritty firefox discord obsidian code gedit evince \
        file-roller thunar gvfs gvfs-mtp gvfs-smb tumbler \
        ffmpeg imagemagick mpv zathura zathura-pdf-mupdf
}

setup_docker() {
    log "Setting up Docker..."
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
    if [[ -z "$SUDO_USER" ]]; then
        SUDO_USER=$(who | awk 'NR==1 {print $1}')
        export SUDO_USER
    fi

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && cd .. && pwd)"

    log "Starting Arch Coding Distro installation..."
    log "Target user: $SUDO_USER"

    check_arch
    check_network
    check_disk_space

    log "Updating system..."
    pacman -Syu --noconfirm || warn "System update failed, continuing..."

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

    log "Installation complete!"
    log ""
    log "Next steps:"
    log "1. Reboot your system"
    log "2. SDDM will start automatically"
    log "3. Login with your user account"
    log "4. Starship prompt will configure on first launch"
    log ""
    log "Key features installed:"
    log "  - Niri Wayland compositor"
    log "  - SDDM display manager"
    log "  - Zsh with plugins"
    log "  - Neovim with lazy.nvim"
    log "  - Development tools (Python, Node.js, Rust, Go, Java)"
    log "  - Git, Docker, tmux"
    log "  - Modern tools (ripgrep, fd, fzf, bat, exa)"
    log ""
    log "To customize further, edit:"
    log "  - ~/.config/niri/config.kdl"
    log "  - ~/.config/starship.toml"
    log "  - ~/.zshrc"
}

main "$@"