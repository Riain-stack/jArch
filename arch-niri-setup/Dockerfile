FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base base-devel linux linux-firmware \
    btrfs-progs networkmanager \
    sudo vim git curl wget \
    openssh zsh fish \
    niri sddm sddm-config-import-git \
    waybar rofi wl-clipboard \
    foot fish tmux docker \
    neovim git lazygit \
    nodejs npm python python-pip rust cargo \
    go gopls pyright rust-analyzer \
    fzf ripgrep bat exa zoxide lsd tldr \
    ttf-jetbrains-mono ttf-nerd-fonts-symbols \
    grub efibootmgr

WORKDIR /opt

COPY install/install.sh /opt/install.sh
COPY .config/ /root/.config/
RUN chmod +x /opt/install.sh

CMD ["/usr/bin/zsh"]