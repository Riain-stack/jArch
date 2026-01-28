#!/usr/bin/env bash
# Test script to verify step counting accuracy for progress tracking

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     jArch Installer - Step Counting Verification      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Based on installer's calculate_steps() function
STEPS_MINIMAL=12
STEPS_STANDARD=16
STEPS_FULL=20

# Installation function sequence from main()
declare -a install_sequence=(
    "check_arch"
    "check_network"
    "check_disk_space"
    "check_sudo"
    "install_base"
    "install_display"
    "install_sddm"
    "install_niri"
    "install_shell_tools"
    "install_dev_tools"
    "install_neovim"
    "install_aur_helper"
    "install_aur_packages"
    "install_fonts"
    "install_additional_tools"
    "install_wayland_tools"
    "install_security_tools"
    "setup_firewall"
    "install_sound"
    "backup_configs"
    "setup_dotfiles"
    "create_user_configs"
    "setup_docker"
    "verify_installation"
)

# Map functions to components (for filtering by profile)
declare -A function_to_component=(
    ["install_base"]="base"
    ["install_display"]="display"
    ["install_sddm"]="sddm"
    ["install_niri"]="niri"
    ["install_shell_tools"]="shell"
    ["install_dev_tools"]="dev_basic"
    ["install_neovim"]="neovim"
    ["install_aur_helper"]="aur"
    ["install_aur_packages"]="aur"
    ["install_fonts"]="fonts"
    ["install_additional_tools"]="extras"
    ["install_wayland_tools"]="wayland"
    ["install_security_tools"]="security"
    ["setup_firewall"]="security"
    ["install_sound"]="sound"
    ["setup_docker"]="docker"
)

should_run_in_profile() {
    local func=$1
    local profile=$2
    
    # Always run non-install functions (checks, backups, etc.)
    if [[ ! "$func" =~ ^(install_|setup_) ]]; then
        return 0
    fi
    
    # Get component for this function
    local component="${function_to_component[$func]}"
    if [[ -z "$component" ]]; then
        # No component mapping = always run (like backup_configs, etc.)
        return 0
    fi
    
    # Check if component should be installed in this profile
    case "$profile" in
        minimal)
            [[ "$component" =~ ^(base|display|sddm|niri|shell|neovim|fonts|wayland)$ ]]
            ;;
        standard)
            [[ "$component" =~ ^(base|display|sddm|niri|shell|neovim|fonts|wayland|dev_basic|docker|aur|security|sound)$ ]]
            ;;
        full)
            return 0
            ;;
    esac
}

count_steps_for_profile() {
    local profile=$1
    local count=0
    
    for func in "${install_sequence[@]}"; do
        if should_run_in_profile "$func" "$profile"; then
            count=$((count + 1))
        fi
    done
    
    echo $count
}

test_profile_steps() {
    local profile=$1
    local expected=$2
    
    echo -e "${BLUE}Testing $profile profile${NC}"
    echo "Expected steps from calculate_steps(): $expected"
    
    local actual=$(count_steps_for_profile "$profile")
    echo "Actual steps from function sequence: $actual"
    
    echo ""
    echo "Functions that will run:"
    local step=1
    for func in "${install_sequence[@]}"; do
        if should_run_in_profile "$func" "$profile"; then
            local component="${function_to_component[$func]:-always}"
            printf "  %2d. %-30s [%s]\n" "$step" "$func" "$component"
            step=$((step + 1))
        fi
    done
    
    echo ""
    if [[ $actual -eq $expected ]]; then
        echo -e "${GREEN}✓ PASS${NC} - Step count matches ($actual = $expected)"
    else
        echo -e "${RED}✗ FAIL${NC} - Step count mismatch (expected: $expected, got: $actual)"
        echo -e "${YELLOW}  This will cause incorrect progress percentages!${NC}"
    fi
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Run tests
test_profile_steps "minimal" "$STEPS_MINIMAL"
test_profile_steps "standard" "$STEPS_STANDARD"
test_profile_steps "full" "$STEPS_FULL"

echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${MAGENTA}Analysis Summary:${NC}"
echo ""
echo "The progress tracking in jArch uses these step counts:"
echo "  minimal:  $STEPS_MINIMAL steps"
echo "  standard: $STEPS_STANDARD steps"
echo "  full:     $STEPS_FULL steps"
echo ""
echo -e "${YELLOW}Note:${NC} Progress percentages are calculated as:"
echo "  percentage = (CURRENT_STEP * 100 / TOTAL_STEPS)"
echo ""
echo "Each function that calls progress() increments CURRENT_STEP."
echo "If the actual function count doesn't match TOTAL_STEPS,"
echo "the progress bar won't reach 100% (or might exceed it)."
echo ""
echo -e "${GREEN}✓ Step counting verification complete!${NC}"
