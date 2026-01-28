#!/usr/bin/env bash
# jArch Update Script
# Updates system packages, AUR packages, and syncs dotfiles

set -eo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME=$(eval echo ~"${SUDO_USER:-$USER}")
LOG_FILE="/tmp/jarch-update-$(date +%Y%m%d-%H%M%S).log"

# Flags
UPDATE_SYSTEM=true
UPDATE_AUR=true
SYNC_DOTFILES=false
CHECK_JARCH=true
BACKUP_FIRST=false
DRY_RUN=false

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC}  $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[OK]${NC}    $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC}  $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

show_help() {
    cat << EOF
jArch Update Script - Keep your system up to date

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help              Show this help message
  -d, --dry-run           Show what would be updated without making changes
  -s, --sync-dotfiles     Sync dotfiles from jArch repository
  -b, --backup            Create backup before updating
  --no-system             Skip system package updates
  --no-aur                Skip AUR package updates
  --no-check              Skip jArch version check

Examples:
  # Full update (system + AUR)
  sudo ./update.sh

  # Update and sync dotfiles
  sudo ./update.sh --sync-dotfiles

  # Dry run to see what would be updated
  ./update.sh --dry-run

  # Update with backup first
  sudo ./update.sh --backup

  # Only update system packages
  sudo ./update.sh --no-aur

EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -s|--sync-dotfiles)
                SYNC_DOTFILES=true
                shift
                ;;
            -b|--backup)
                BACKUP_FIRST=true
                shift
                ;;
            --no-system)
                UPDATE_SYSTEM=false
                shift
                ;;
            --no-aur)
                UPDATE_AUR=false
                shift
                ;;
            --no-check)
                CHECK_JARCH=false
                shift
                ;;
            *)
                error "Unknown option: $1\nUse --help for usage information"
                ;;
        esac
    done
}

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    ╔════════════════════════════════════════╗
    ║        jArch Update Script             ║
    ╚════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

check_jarch_version() {
    if [[ "$CHECK_JARCH" != true ]]; then
        return 0
    fi

    log "Checking for jArch updates..."
    
    cd "$SCRIPT_DIR" || return 1
    
    # Fetch latest from origin
    git fetch origin main --quiet 2>/dev/null || {
        warn "Could not check for jArch updates (network issue)"
        return 0
    }
    
    # Check if we're behind
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    
    if [[ "$LOCAL" != "$REMOTE" ]]; then
        warn "jArch repository has updates available!"
        echo ""
        echo -e "${YELLOW}To update jArch itself:${NC}"
        echo "  cd $SCRIPT_DIR"
        echo "  git pull origin main"
        echo ""
        read -p "Pull latest jArch changes now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "Pulling latest jArch changes..."
            git pull origin main
            success "jArch repository updated!"
        fi
    else
        success "jArch is up to date"
    fi
}

create_backup() {
    if [[ "$BACKUP_FIRST" != true ]]; then
        return 0
    fi

    if [[ ! -x "$SCRIPT_DIR/backup.sh" ]]; then
        warn "backup.sh not found, skipping backup"
        return 0
    fi

    log "Creating backup before update..."
    if "$SCRIPT_DIR/backup.sh" --archive; then
        success "Backup created"
    else
        warn "Backup failed, continuing anyway..."
    fi
}

update_system_packages() {
    if [[ "$UPDATE_SYSTEM" != true ]]; then
        log "Skipping system package updates"
        return 0
    fi

    log "Updating system packages..."
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${CYAN}[DRY-RUN]${NC} Would run: pacman -Syu --noconfirm"
        return 0
    fi

    # Update package database
    pacman -Sy --noconfirm || {
        error "Failed to sync package database"
    }

    # Check for updates
    local updates=$(pacman -Qu | wc -l)
    
    if [[ $updates -eq 0 ]]; then
        success "System packages are up to date"
        return 0
    fi

    log "Found $updates package(s) to update"
    
    # Perform update
    if pacman -Su --noconfirm; then
        success "System packages updated successfully"
    else
        error "System package update failed"
    fi
}

update_aur_packages() {
    if [[ "$UPDATE_AUR" != true ]]; then
        log "Skipping AUR package updates"
        return 0
    fi

    if ! command -v paru &> /dev/null; then
        warn "paru not installed, skipping AUR updates"
        return 0
    fi

    log "Updating AUR packages..."
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${CYAN}[DRY-RUN]${NC} Would run: paru -Syu --noconfirm"
        return 0
    fi

    # Run as the actual user, not root
    local actual_user="${SUDO_USER:-$USER}"
    
    if sudo -u "$actual_user" paru -Sua --noconfirm; then
        success "AUR packages updated successfully"
    else
        warn "AUR package update had issues"
    fi
}

sync_dotfiles() {
    if [[ "$SYNC_DOTFILES" != true ]]; then
        return 0
    fi

    log "Syncing dotfiles from jArch repository..."
    
    if [[ ! -d "$SCRIPT_DIR/dotfiles" ]]; then
        error "Dotfiles directory not found at $SCRIPT_DIR/dotfiles"
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${CYAN}[DRY-RUN]${NC} Would sync dotfiles to $USER_HOME/.config/"
        return 0
    fi

    # Backup existing dotfiles
    local backup_dir="$USER_HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    log "Backing up existing dotfiles to $backup_dir"
    mkdir -p "$backup_dir"
    
    # Copy configs that will be replaced
    for config_dir in niri nvim ripgrep zsh; do
        if [[ -d "$USER_HOME/.config/$config_dir" ]]; then
            cp -r "$USER_HOME/.config/$config_dir" "$backup_dir/" 2>/dev/null || true
        fi
    done
    [[ -f "$USER_HOME/.config/starship.toml" ]] && cp "$USER_HOME/.config/starship.toml" "$backup_dir/" 2>/dev/null || true

    # Sync dotfiles
    mkdir -p "$USER_HOME/.config"
    cp -r "$SCRIPT_DIR/dotfiles/.config/"* "$USER_HOME/.config/" || {
        error "Failed to sync dotfiles"
    }

    # Fix ownership
    local actual_user="${SUDO_USER:-$USER}"
    chown -R "$actual_user":"$actual_user" "$USER_HOME/.config"

    success "Dotfiles synced successfully"
    log "Backup saved to: $backup_dir"
}

clean_package_cache() {
    log "Cleaning package cache..."
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${CYAN}[DRY-RUN]${NC} Would clean package cache"
        return 0
    fi

    # Keep last 3 versions of packages
    paccache -rk3 2>/dev/null || {
        warn "paccache not available, skipping cache cleanup"
        return 0
    }

    success "Package cache cleaned"
}

check_sudo() {
    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    if [[ "$UPDATE_SYSTEM" == true ]] || [[ "$UPDATE_AUR" == true ]]; then
        if [[ $EUID -ne 0 ]]; then
            error "This script must be run with sudo for system updates"
        fi
    fi
}

print_summary() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${GREEN}Update Summary${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    
    [[ "$CHECK_JARCH" == true ]] && echo "✓ jArch version check"
    [[ "$BACKUP_FIRST" == true ]] && echo "✓ Backup created"
    [[ "$UPDATE_SYSTEM" == true ]] && echo "✓ System packages updated"
    [[ "$UPDATE_AUR" == true ]] && echo "✓ AUR packages updated"
    [[ "$SYNC_DOTFILES" == true ]] && echo "✓ Dotfiles synced"
    echo "✓ Package cache cleaned"
    
    echo ""
    echo -e "${GREEN}✓ Update completed successfully!${NC}"
    echo ""
    echo "Log saved to: $LOG_FILE"
    echo ""
}

main() {
    parse_args "$@"
    print_banner
    
    if [[ "$DRY_RUN" == true ]]; then
        log "DRY-RUN MODE - No changes will be made"
        echo ""
    fi

    check_sudo
    check_jarch_version
    create_backup
    update_system_packages
    update_aur_packages
    sync_dotfiles
    clean_package_cache
    
    if [[ "$DRY_RUN" != true ]]; then
        print_summary
    else
        echo ""
        echo -e "${CYAN}Dry-run complete. Run without --dry-run to apply changes.${NC}"
    fi
}

main "$@"
