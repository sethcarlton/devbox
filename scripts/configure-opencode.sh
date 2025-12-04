#!/bin/bash
set -e

echo "=== OpenCode Configuration ==="
echo ""

if [ ! -d ~/.config/opencode ]; then
    echo "OpenCode is not installed. Install it first then run this script again."
    exit 0
fi

cd ~/.config/opencode

if [ -d .git ] && git remote get-url origin &>/dev/null; then
    git pull origin main || git pull origin master || echo "Warning: Could not pull from remote"
    echo "OpenCode config synced"
    exit 0
fi

read -p "Enter your OpenCode config repo URL (or press Enter to skip): " opencode_repo
if [ -z "$opencode_repo" ]; then
    echo "Skipping OpenCode config sync"
    exit 0
fi

[ ! -d .git ] && git init -b main
git remote add origin "$opencode_repo"
git pull origin main || git pull origin master || echo "Warning: Could not pull from remote"
echo "OpenCode config synced from $opencode_repo"
