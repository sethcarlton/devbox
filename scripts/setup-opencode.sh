#!/bin/bash
set -e

echo "=== OpenCode Configuration ==="
echo ""

read -p "Enter your OpenCode config repo URL (or press Enter to skip): " opencode_repo

if [ -n "$opencode_repo" ]; then
    mkdir -p ~/.config/opencode
    git clone "$opencode_repo" ~/.config/opencode
    echo "OpenCode config cloned to ~/.config/opencode"
else
    echo "Skipping OpenCode config setup"
fi

echo ""

# Source bashrc to ensure any updates are loaded
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
