#!/bin/bash
set -e

echo "=== Git Configuration ==="
echo ""

# Git configuration
read -p "Enter your full name: " git_name
read -p "Enter your email: " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"

echo ""
echo "Git configured:"
git config --global user.name
git config --global user.email

echo ""
echo "Generating SSH key for GitHub/GitLab..."
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "$git_email"

echo ""
echo "Your SSH public key (add this to GitHub Settings > SSH and GPG keys):"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""

# Source bashrc to ensure any updates are loaded
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
