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
# Drop Privileges and Run Main Process
# -----------------------------------------------------------------------------

echo "Devbox container started."
echo "User: ${TARGET_USER}"

# The Rex server is the main process, so the container stops if it does.
# --tailscale runs Rex's own tailnet node; its login persists in the home volume.
# Tailscale ACLs decide who may connect, so the node still works once it is
# tagged and has no owner.
REX_SERVER=(rex server run --tailscale --tailscale-hostname "$(hostname)-rex" --tailscale-allow-tailnet-members)

# Drop to non-root user for the main process
if [ "$(id -u)" = "0" ]; then
    exec sudo -H -u "${TARGET_USER}" "${REX_SERVER[@]}"
else
    # Already running as non-root user
    exec "${REX_SERVER[@]}"
fi
