#!/bin/bash

# jArch Backup Script
# Backs up jArch configuration and scripts

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATE=$(date +%Y%m%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
ARCHIVE_NAME="jarch-backup-${DATE}.tar.gz"

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_git() {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        print_error "Not a git repository!"
        exit 1
    fi
}

create_archive() {
    print_info "Creating backup archive..."
    
    if [ -f "${ARCHIVE_NAME}" ]; then
        print_warning "Archive ${ARCHIVE_NAME} exists, skipping..."
        return 0
    fi
    
    tar -czf "${ARCHIVE_NAME}" \
        --exclude='.git' \
        --exclude='*.log' \
        --exclude='*.tar.gz' \
        --exclude='archiso' \
        --exclude='*.iso' \
        dotfiles/ install/ arch-niri-setup/ *.md LICENSE .gitignore 2>/dev/null || true
    
    SIZE=$(du -h "${ARCHIVE_NAME}" | cut -f1)
    print_success "Archive created: ${ARCHIVE_NAME} (${SIZE})"
}

commit_push() {
    print_info "Committing changes..."
    
    if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
        git add .
        VERSION=$(git describe --tags 2>/dev/null || git rev-parse --short HEAD)
        git commit -m "Backup: jArch ${VERSION} - ${TIMESTAMP}"
        print_success "Changes committed"
        
        print_info "Pushing to remote..."
        git push && print_success "Pushed to remote!" || print_error "Push failed"
    else
        print_info "No changes to commit"
    fi
}

show_status() {
    print_info "Repository Status:"
    git status --short
    echo ""
    print_info "Recent Commits:"
    git log --oneline -5
    echo ""
    print_info "Backups:"
    ls -lh jarch-backup-*.tar.gz 2>/dev/null | awk '{print $9, "(" $5 ")"}' || echo "No backups found"
}

# Main
cd "${BACKUP_DIR}"
check_git

case "${1:-}" in
    --full|-f)
        create_archive
        commit_push
        ;;
    --archive|-a)
        create_archive
        ;;
    --commit|-c)
        commit_push
        ;;
    --status|-s)
        show_status
        ;;
    --help|-h|*)
        echo "jArch Backup Manager"
        echo ""
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  -f, --full      Full backup (archive + commit + push)"
        echo "  -a, --archive   Create archive only"
        echo "  -c, --commit    Commit and push changes"
        echo "  -s, --status    Show status"
        echo "  -h, --help      Show this help"
        ;;
esac
