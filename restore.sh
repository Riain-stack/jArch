#!/bin/bash

# jArch Restore Script
# Restores jArch configurations from backup

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SAFETY_BACKUP="$HOME/.jarch-backups/restore_backup_${TIMESTAMP}"

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

backup_current() {
    print_step "Backing up current configuration..."
    mkdir -p "${SAFETY_BACKUP}"
    
    CONFIGS=(
        ".config/niri"
        ".config/alacritty"
        ".config/nvim"
        ".zshrc"
        ".gitconfig"
    )
    
    for config in "${CONFIGS[@]}"; do
        if [ -e "$HOME/$config" ]; then
            PARENT=$(dirname "${SAFETY_BACKUP}/${config}")
            mkdir -p "${PARENT}"
            cp -r "$HOME/$config" "${SAFETY_BACKUP}/${config}" 2>/dev/null || true
            print_info "Backed up: $config"
        fi
    done
    
    print_success "Safety backup: ${SAFETY_BACKUP}"
}

restore_dotfiles() {
    print_step "Restoring dotfiles..."
    
    if [ ! -d "${BACKUP_DIR}/dotfiles" ]; then
        print_error "Dotfiles directory not found!"
        return 1
    fi
    
    cd "${BACKUP_DIR}/dotfiles"
    
    # Shell configs
    if [ -d "shell" ]; then
        print_info "Restoring shell configs..."
        [ -f "shell/.zshrc" ] && cp shell/.zshrc "$HOME/" && print_info "  ✓ .zshrc"
        [ -f "shell/.bashrc" ] && cp shell/.bashrc "$HOME/" && print_info "  ✓ .bashrc"
    fi
    
    # Terminal
    if [ -d "terminal" ]; then
        print_info "Restoring terminal configs..."
        [ -d "terminal/alacritty" ] && mkdir -p "$HOME/.config/alacritty" && cp -r terminal/alacritty/* "$HOME/.config/alacritty/" && print_info "  ✓ Alacritty"
    fi
    
    # Editor
    if [ -d "editor" ]; then
        print_info "Restoring editor configs..."
        [ -d "editor/nvim" ] && mkdir -p "$HOME/.config/nvim" && cp -r editor/nvim/* "$HOME/.config/nvim/" && print_info "  ✓ Neovim"
    fi
    
    # Git
    if [ -d "git" ]; then
        print_info "Restoring git config..."
        [ -f "git/.gitconfig" ] && cp git/.gitconfig "$HOME/" && print_info "  ✓ Git"
    fi
    
    cd "${BACKUP_DIR}"
    print_success "Dotfiles restored!"
}

restore_niri() {
    print_step "Restoring Niri configuration..."
    
    if [ -d "${BACKUP_DIR}/dotfiles/niri" ]; then
        mkdir -p "$HOME/.config/niri"
        cp -r "${BACKUP_DIR}/dotfiles/niri/"* "$HOME/.config/niri/"
        print_success "Niri restored!"
    else
        print_warning "Niri config not found"
    fi
}

run_installer() {
    print_step "Running jArch installer..."
    
    if [ -f "${BACKUP_DIR}/install/install.sh" ]; then
        bash "${BACKUP_DIR}/install/install.sh"
        print_success "Installer completed!"
    else
        print_warning "Installer not found"
    fi
}

confirm() {
    echo ""
    print_warning "This will $1"
    print_info "Current config will be backed up to: ${SAFETY_BACKUP}"
    echo -n "Continue? [y/N]: "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) print_info "Cancelled"; return 1 ;;
    esac
}

# Main
cd "${BACKUP_DIR}"

if [ ! -d "${BACKUP_DIR}/dotfiles" ]; then
    print_error "jArch directory structure not found!"
    exit 1
fi

case "${1:-}" in
    --full|-f)
        if confirm "restore all configurations"; then
            backup_current
            restore_dotfiles
            restore_niri
            print_success "Full restore complete!"
        fi
        ;;
    --dotfiles|-d)
        if confirm "restore dotfiles"; then
            backup_current
            restore_dotfiles
        fi
        ;;
    --niri|-n)
        if confirm "restore Niri configuration"; then
            backup_current
            restore_niri
        fi
        ;;
    --install|-i)
        run_installer
        ;;
    --help|-h|*)
        echo "jArch Restore Manager"
        echo ""
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  -f, --full      Full restore (dotfiles + Niri)"
        echo "  -d, --dotfiles  Restore dotfiles only"
        echo "  -n, --niri      Restore Niri only"
        echo "  -i, --install   Run installer"
        echo "  -h, --help      Show this help"
        ;;
esac
