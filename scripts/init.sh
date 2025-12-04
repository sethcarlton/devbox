#!/bin/bash
set -e

echo "=== Devbox Initialization ==="
echo ""

# Suppress sudo hint message on first login
if [ ! -f "$HOME/.sudo_as_admin_successful" ]; then
    touch "$HOME/.sudo_as_admin_successful"
fi

/usr/local/bin/install-tools.sh
/usr/local/bin/setup-git.sh
/usr/local/bin/configure-opencode.sh

echo "=== Initialization Complete ==="
echo ""
