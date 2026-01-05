#!/bin/bash
set -e

echo "=== Dotfiles Configuration (bare repo method) ==="
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

if [[ "$dotfiles_repo" == git@* ]] && [ ! -f ~/.ssh/id_ed25519 ]; then
    echo ""
    echo "SSH URL detected but no SSH key found."
    read -p "Run configure-git.sh first? (y/n, or use HTTPS instead): " configure_git
    if [[ "$configure_git" == "y" ]]; then
        /usr/local/bin/configure-git.sh
    else
        read -p "Enter your dotfiles repo URL: " dotfiles_repo
    fi
fi

if [ -z "$dotfiles_repo" ]; then
    echo "Skipping dotfiles sync"
    exit 0
fi

git clone --bare "$dotfiles_repo" ~/.dotfiles

dot config status.showUntrackedFiles no

checkout_dotfiles

echo "Dotfiles synced from $dotfiles_repo"
