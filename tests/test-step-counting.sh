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
# Only count functions that call progress()
STEPS_MINIMAL=7   # base, display, niri, shell, neovim, fonts, wayland
STEPS_STANDARD=12 # minimal(7) + dev_tools, paru, aur_packages, security, sound
STEPS_FULL=13     # standard(12) + additional_tools

# Installation functions that call progress() from main()
# These are the only ones that increment the progress counter
declare -a install_sequence=(
    "install_base"
    "install_display"
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
    "install_sound"
)

# Map functions to components (for filtering by profile)
# Only includes functions that call progress()
declare -A function_to_component=(
    ["install_base"]="base"
    ["install_display"]="display"
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
    ["install_sound"]="sound"
)

should_run_in_profile() {
    local func=$1
    local profile=$2
    
    # Get component for this function
    local component="${function_to_component[$func]}"
    if [[ -z "$component" ]]; then
        # No component mapping = shouldn't happen
        return 1
    fi
    
    # Check if component should be installed in this profile
    case "$profile" in
        minimal)
            [[ "$component" =~ ^(base|display|niri|shell|neovim|fonts|wayland)$ ]]
            ;;
        standard)
            [[ "$component" =~ ^(base|display|niri|shell|neovim|fonts|wayland|dev_basic|aur|security|sound)$ ]]
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
    echo "Actual progress() calls that will execute: $actual"
    
    echo ""
    echo "Functions with progress() that will run:"
    local step=1
    for func in "${install_sequence[@]}"; do
        if should_run_in_profile "$func" "$profile"; then
            local component="${function_to_component[$func]}"
            printf "  %2d. %-35s [%s]\n" "$step" "$func" "$component"
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
