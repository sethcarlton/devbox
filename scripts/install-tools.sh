#!/bin/bash
set -e

echo "=== Tooling Installation ==="
echo ""

# Install NVM if not present
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    echo "NVM installed"
else
    echo "NVM already installed"
fi

# Source NVM to make it available in this script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    echo "Installing Node.js (LTS)..."
    nvm install --lts
    nvm alias default 'lts/*'
    echo "Node.js installed"
else
    echo "Node.js already installed ($(node -v))"
fi

# Install Bun if not present
if [ ! -d "$HOME/.bun" ]; then
    echo "Installing Bun (latest)..."
    curl -fsSL https://bun.sh/install | bash
    echo "Bun installed"
else
    echo "Bun already installed"
fi

# Install OpenCode if not present
if ! command -v opencode &> /dev/null; then
    echo "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
    echo "OpenCode installed"
else
    echo "OpenCode already installed"
fi

echo ""
echo "=== Tooling Installation Complete ==="
echo ""

# Source bashrc to make tools available in current session
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
