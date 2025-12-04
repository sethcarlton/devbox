#!/bin/bash
set -e

# -----------------------------------------------------------------------------
# Target User Configuration
# -----------------------------------------------------------------------------
# DEVBOX_USER is set in the Dockerfile via ENV
TARGET_USER="${DEVBOX_USER:-dev}"
TARGET_HOME="/home/${TARGET_USER}"

# -----------------------------------------------------------------------------
# Home Directory Initialization (runs as root)
# -----------------------------------------------------------------------------
# When using a persistent volume mount, the home directory may be empty.
# This section copies default skeleton files if they don't exist.

if [ -d "$TARGET_HOME" ]; then
    if [ ! -f "$TARGET_HOME/.bashrc" ]; then
        echo "Initializing home directory with default files..."
        
        if [ -d "/etc/skel" ]; then
            cp -rn /etc/skel/. "$TARGET_HOME/" 2>/dev/null || true
            echo "Default configuration files copied from /etc/skel"
        fi
    fi
    
    # Ensure proper ownership
    if [ "$(id -u)" = "0" ]; then
        chown -R "${TARGET_USER}:" "$TARGET_HOME"
    fi
fi

# -----------------------------------------------------------------------------
# Service Startup Script (runs as root)
# -----------------------------------------------------------------------------

# [FUTURE] mDNS / Avahi
# To enable mDNS (e.g. devbox.local), uncomment the following line:
# service avahi-daemon start

# [FUTURE] SSH Server
# To enable the internal SSH server, uncomment the following line:
# /usr/sbin/sshd -D &

# -----------------------------------------------------------------------------
# Drop Privileges and Run Main Process
# -----------------------------------------------------------------------------

echo "Devbox container started."
echo "User: ${TARGET_USER}"

# Drop to non-root user for the main process
if [ "$(id -u)" = "0" ]; then
    exec sudo -u "${TARGET_USER}" tail -f /dev/null
else
    # Already running as non-root user
    exec tail -f /dev/null
fi
