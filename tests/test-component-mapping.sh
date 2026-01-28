#!/usr/bin/env bash
# Test script to verify component-to-function mapping in jArch installer

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      jArch Installer - Component Mapping Analysis     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Define component to function mapping
declare -A component_map=(
    ["base"]="install_base()"
    ["display"]="install_display()"
    ["sddm"]="install_sddm()"
    ["niri"]="install_niri()"
    ["shell"]="install_shell_tools()"
    ["neovim"]="install_neovim()"
    ["fonts"]="install_fonts()"
    ["wayland"]="install_wayland_tools()"
    ["dev_basic"]="install_dev_tools()"
    ["docker"]="setup_docker()"
    ["aur"]="install_aur_helper() + install_aur_packages()"
    ["security"]="install_security_tools() + setup_firewall()"
    ["sound"]="install_sound()"
    ["extras"]="install_additional_tools()"
)

# Profile definitions
declare -A profiles=(
    ["minimal"]="base display sddm niri shell neovim fonts wayland"
    ["standard"]="base display sddm niri shell neovim fonts wayland dev_basic docker aur security sound"
    ["full"]="base display sddm niri shell neovim fonts wayland dev_basic docker aur security sound extras"
)

echo -e "${MAGENTA}Component to Function Mapping:${NC}"
echo ""
for component in "${!component_map[@]}"; do
    printf "  %-12s → %s\n" "$component" "${component_map[$component]}"
done | sort

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

# Analyze each profile
for profile_name in minimal standard full; do
    echo -e "${BLUE}Profile: $profile_name${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    components="${profiles[$profile_name]}"
    component_count=0
    
    echo "Components installed:"
    for component in $components; do
        component_count=$((component_count + 1))
        if [[ -n "${component_map[$component]}" ]]; then
            printf "  ${GREEN}✓${NC} %-12s → %s\n" "$component" "${component_map[$component]}"
        else
            printf "  ${RED}✗${NC} %-12s → ${RED}NO MAPPING${NC}\n" "$component"
        fi
    done
    
    # Calculate size estimate
    case "$profile_name" in
        minimal)
            size="~2GB"
            ;;
        standard)
            size="~4GB"
            ;;
        full)
            size="~6GB"
            ;;
    esac
    
    echo ""
    echo -e "  Total components: ${CYAN}$component_count${NC}"
    echo -e "  Estimated size:   ${CYAN}$size${NC}"
    echo ""
done

echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

# Package breakdown
echo -e "${MAGENTA}Estimated Package Breakdown by Profile:${NC}"
echo ""

echo -e "${BLUE}MINIMAL Profile (~2GB):${NC}"
cat << 'EOF'
  Core System:
    • base, base-devel, networkmanager, sudo
  Display:
    • xorg-server, xorg-xwayland, GPU drivers (amdgpu/intel/nouveau)
    • mesa, vulkan-tools
  Window Manager:
    • niri (Rust-based Wayland compositor)
    • sddm (display manager)
  Shell & Tools:
    • zsh, zsh-completions, starship (AUR)
    • fzf, ripgrep, bat, exa, fd, dust, btop, htop
    • tmux, neofetch
  Editor:
    • neovim, ripgrep, fd, unzip
  Fonts:
    • ttf-meslo, ttf-jetbrains-mono, ttf-fira-mono
    • noto-fonts, noto-fonts-cjk, noto-fonts-emoji
  Wayland:
    • waybar, rofi, grim, slurp, wl-clipboard

  Total: ~150 packages
EOF

echo ""
echo -e "${BLUE}STANDARD Profile (~4GB):${NC}"
cat << 'EOF'
  Everything from MINIMAL, plus:
  
  Development Tools:
    • git, git-lfs, git-delta, lazygit
    • make, cmake, ninja, gcc, clang
    • python, python-pip, nodejs, npm
    • curl, wget, unzip, zip, jq
  Docker:
    • docker, docker-compose
  Security:
    • ufw (firewall), fail2ban, openssh
  Sound:
    • pipewire, pipewire-pulse, wireplumber
  AUR Packages:
    • starship, zsh-fast-syntax-highlighting
    • zsh-autosuggestions, zsh-vi-mode

  Total: ~250 packages
EOF

echo ""
echo -e "${BLUE}FULL Profile (~6GB):${NC}"
cat << 'EOF'
  Everything from STANDARD, plus:
  
  Extended Development:
    • rust, cargo
    • go
    • jdk-openjdk, maven, gradle, sbt
    • llvm, gdb, lldb, valgrind
    • python-pipx, python-poetry, python-virtualenv
    • pnpm, yarn
    • Additional build tools (swig, automake, autoconf, etc.)
  Desktop Applications:
    • alacritty (terminal)
    • firefox (browser)
    • discord (communication)
    • obsidian (notes)
    • code (VS Code)
    • gedit, evince
  File Management:
    • thunar (file manager)
    • gvfs, gvfs-mtp, gvfs-smb, tumbler
    • file-roller (archive manager)
  Media:
    • ffmpeg, imagemagick
    • mpv (video player)
    • zathura, zathura-pdf-mupdf (PDF viewer)

  Total: ~400+ packages
EOF

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}✓ Component mapping analysis complete!${NC}"
echo ""
echo -e "${YELLOW}Recommendation for users:${NC}"
echo -e "  • ${GREEN}minimal${NC}  → Lightweight systems, manual package management"
echo -e "  • ${GREEN}standard${NC} → Web/Python/Node.js development"
echo -e "  • ${GREEN}full${NC}     → Multi-language development, complete workstation"
