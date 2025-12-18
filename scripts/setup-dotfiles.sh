#!/bin/bash
set -e

echo "=== Dotfiles Configuration ==="
echo ""

dot() {
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

checkout_dotfiles() {
    if ! dot checkout 2>/dev/null; then
        echo ""
        echo "Error: Checkout failed - conflicts with existing files in \$HOME"
        echo "Resolve conflicts manually or remove conflicting files, then run:"
        echo "  git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME checkout"
        exit 1
    fi
}

# Check if dotfiles already configured
if [ -d ~/.dotfiles ]; then
    echo "Dotfiles already cloned, pulling latest..."
    dot pull origin main || dot pull origin master || echo "Warning: Could not pull from remote"
    checkout_dotfiles
    echo "Dotfiles synced"
    exit 0
fi

read -p "Enter your dotfiles repo URL (or press Enter to skip): " dotfiles_repo
if [ -z "$dotfiles_repo" ]; then
    echo "Skipping dotfiles sync"
    exit 0
fi

# Clone bare repo
git clone --bare "$dotfiles_repo" ~/.dotfiles

# Hide untracked files
dot config status.showUntrackedFiles no

# Checkout dotfiles
checkout_dotfiles

echo "Dotfiles synced from $dotfiles_repo"
