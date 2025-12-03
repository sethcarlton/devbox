#!/bin/bash
set -e

# -----------------------------------------------------------------------------
# Home Directory Initialization
# -----------------------------------------------------------------------------
# When using a persistent volume mount, the home directory may be empty.
# This section copies default skeleton files if they don't exist.

if [ -d "$HOME" ]; then
    if [ ! -f "$HOME/.bashrc" ]; then
        echo "Initializing home directory with default files..."
        
        if [ -d "/etc/skel" ]; then
            cp -rn /etc/skel/. "$HOME/" 2>/dev/null || true
            echo "Default configuration files copied from /etc/skel"
        fi
        
        # Ensure proper ownership (in case running as root initially)
        if [ "$(id -u)" = "0" ]; then
            chown -R "$(stat -c '%u:%g' "$HOME")" "$HOME"
        fi
    fi
fi

# -----------------------------------------------------------------------------
# Service Startup Script
# -----------------------------------------------------------------------------

# [FUTURE] mDNS / Avahi
# To enable mDNS (e.g. devbox.local), uncomment the following line:
# service avahi-daemon start

# [FUTURE] SSH Server
# To enable the internal SSH server, uncomment the following line:
# /usr/sbin/sshd -D &

# -----------------------------------------------------------------------------
# Main Process
# -----------------------------------------------------------------------------

echo "Devbox container started."
echo "User: $(whoami)"

# Keep the container running indefinitely
tail -f /dev/null
