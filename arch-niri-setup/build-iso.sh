#!/usr/bin/env bash

set -e

WORK_DIR=$(pwd)
BUILD_DIR="$WORK_DIR/build"
ISO_DIR="$BUILD_DIR/iso"

log() {
    echo "[$(date +%H:%M:%S)] $1"
}

clean_build() {
    log "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"/{iso,ext,iso/out}
}

prepare_base() {
    log "Preparing base ISO..."
    
    curl -Lo "$BUILD_DIR/archlinux.iso" "https://archlinux.org/download/"
    7z x "$BUILD_DIR/archlinux.iso" -y -o"$ISO_DIR"
    mount -o loop "$BUILD_DIR/archlinux.iso" /mnt 2>/dev/null || true
    cp -r /mnt/* "$ISO_DIR" 2>/dev/null || true
    umount /mnt 2>/dev/null || true
    
    mkdir -p "$ISO_DIR/arch/x86_64"
    mkdir -p "$ISO_DIR/config"
    mkdir -p "$ISO_DIR/profile"
}

create_profile() {
    log "Creating profile..."
    
    cat > "$BUILD_DIR/profile.efi.sh" <<'EOF'
#!/usr/bin/env bash

run_archiso_hooks() {
    modprobe nvi0
}
EOF
    chmod +x "$BUILD_DIR/profile.efi.sh"
    
    cat > "$BUILD_DIR/packages.x86_64" <<'EOF'
base
niri
sddm
waybar
neovim
git
nodejs
python
rust
EOF
}

copy_config() {
    log "Copying dotfiles and config..."
    
    cp -r "$WORK_DIR/.config" "$ISO_DIR/config/dotfiles"
    cp "$WORK_DIR/install/install.sh" "$ISO_DIR/install.sh"
    chmod +x "$ISO_DIR/install.sh"
}

create_iso() {
    log "Creating ISO..."
    
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "ARCH_NIRI_$(date +%Y%m%d)" \
        -eltorito-boot boot/EFI/BOOT.efi \
        -eltorito-platform 0xEF \
        -eltorito-bootable \
        -o "$BUILD_DIR/arch-niri.iso" \
        "$ISO_DIR"
    
    log "ISO created: $BUILD_DIR/arch-niri.iso"
}

main() {
    log "Building Arch Niri ISO..."
    
    clean_build
    prepare_base
    create_profile
    copy_config
    create_iso
    
    log "Build complete!"
    log "ISO: $BUILD_DIR/arch-niri.iso"
    log "Size: $(du -h "$BUILD_DIR/arch-niri.iso" | cut -f1)"
    
    log "Flash with:"
    log "  dd if=$BUILD_DIR/arch-niri.iso of=/dev/sdX bs=4M status=progress"
}

main