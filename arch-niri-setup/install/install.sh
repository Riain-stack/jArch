#!/usr/bin/env bash

set -e

ARCH_MIRROR="https://archlinux.org/repos/core/os/x86_64"
WORKSPACE=$(pwd)
LOG_FILE="$WORKSPACE/install.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo "ERROR: $1" >&2
    exit 1
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

check_internet() {
    if ! ping -c 1 archlinux.org &>/dev/null; then
        error "No internet connection"
    fi
}

setup_disk() {
    local DISK="${1:-/dev/sda}"
    
    log "Partitioning disk $DISK..."
    
    wipefs -a "$DISK"
    
    parted "$DISK" --script mklabel gpt
    
    parted "$DISK" --script mkpart ESP fat32 1MiB 512MiB
    parted "$DISK" --script set 1 esp on
    
    parted "$DISK" --script mkpart primary 512MiB 100%
    
    mkfs.fat -F32 "$DISK"1
    mkfs.btrfs "$DISK"2
    
    mount "$DISK"2 /mnt
    mkdir -p /mnt/boot
    mount "$DISK"1 /mnt/boot
    
    log "Disk setup complete"
}

install_base() {
    log "Installing base system..."
    
    pacstrap -K /mnt \
        base base-devel linux linux-firmware \
        btrfs-progs networkmanager \
        sudo vim git curl wget \
        openssh zsh \
        fish \
        efibootmgr grub
    
    log "Base system installed"
}

configure_system() {
    log "Configuring system..."
    
    genfstab -U /mnt >> /mnt/etc/fstab
    
    arch-chroot /mnt /bin/bash <<'EOF'
        ln -sf /usr/share/zoneinfo/UTC /etc/localtime
        hwclock --systohc
        
        sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
        locale-gen
        echo "LANG=en_US.UTF-8" > /etc/locale.conf
        
        echo "arch-niri" > /etc/hostname
        
        echo "EDITOR=vim" >> /etc/environment
        
        sed -i 's/^%wheel.*/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
        
        pacman -S --noconfirm networkmanager
        systemctl enable NetworkManager
        
        sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/' /etc/mkinitcpio.conf
        
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
        grub-mkconfig -o /boot/grub/grub.cfg
EOF
    
    log "System configured"
}

setup_user() {
    local USERNAME="${1:-coder}"
    
    log "Creating user $USERNAME..."
    
    arch-chroot /mnt /bin/bash <<EOF
        useradd -m -s /usr/bin/fish -G wheel $USERNAME
        echo "$USERNAME:$USERNAME" | chpasswd
        
        mkdir -p /home/$USERNAME/.config
        mkdir -p /home/$USERNAME/projects
        
        chown -R $USERNAME:$USERNAME /home/$USERNAME
EOF
    
    log "User created"
}

install_gaming() {
    log "Installing packages..."
    
    arch-chroot /mnt /bin/bash <<'EOF'
        pacman -Syu --noconfirm
        
        pacman -S --needed --noconfirm \
            niri sddm sddm-qemu-virtio \
            waybar rofi wl-clipboard \
            foot \
            brightnessctl \
            xcolor-picker \
            pamixer \
            swayidle \
            slurp grim \
            neovim git lazygit \
            nodejs npm python python-pip rust cargo \
            docker docker-compose \
            fzf ripgrep fd bat exa \
            tealdeer zoxide \
            ttf-jetbrains-mono ttf-nerd-fonts-symbols \
            noto-fonts noto-fonts-cjk \
            unzip zip p7zip
        
        systemctl enable sddm
        
        useradd -m -s /usr/bin/bash -G docker coder
EOF
    
    log "Packages installed"
}

setup_dotfiles() {
    local USERNAME="${1:-coder}"
    
    log "Installing dotfiles..."
    
    mkdir -p "$WORKSPACE/.config/niri"
    mkdir -p "$WORKSPACE/.config/neovim"
    mkdir -p "$WORKSPACE/.config/fish"
    mkdir -p "$WORKSPACE/.config/waybar"
    mkdir -p "$WORKSPACE/.config/rofi"
    
    arch-chroot /mnt /bin/bash <<EOF
        pacman -S --noconfirm git stow
        su - coder -c "git clone https://github.com/user/dotfiles.git ~/dotfiles"
        su - coder -c "cd ~/dotfiles && stow niri neovim fish waybar rofi"
EOF
    
    log "Dotfiles installed"
}

main() {
    check_root
    check_internet
    
    log "Starting Arch Linux installation..."
    
    setup_disk
    install_base
    configure_system
    setup_user
    install_gaming
    setup_dotfiles
    
    log "Installation complete! Reboot now."
}

main "$@"