FROM ubuntu:latest

# -----------------------------------------------------------------------------
# BUILD ARGUMENTS
# -----------------------------------------------------------------------------
# Default user configuration
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=100

# -----------------------------------------------------------------------------
# BASE SYSTEM SETUP
# -----------------------------------------------------------------------------
# 'unminimize' restores man pages and documentation for a "real" system feel.
RUN yes | unminimize

# Install core development tools and utilities
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    sudo \
    apt-utils \
    language-pack-en \
    build-essential \
    pkg-config \
    bzip2 \
    rsync \
    vim \
    curl \
    htop \
    git \
    tmux \
    unzip \
    # [FUTURE] Uncomment openssh-server and avahi-daemon to enable SSH and mDNS \
    # openssh-server \
    # avahi-daemon \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# [FUTURE] SERVICE CONFIGURATION
# -----------------------------------------------------------------------------
# Avahi (mDNS) configuration
# RUN sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf

# SSH configuration
# RUN mkdir /var/run/sshd
# Uncomment to use persistent host keys (prevents "host identification changed" warnings on rebuild)
# COPY ssh_keys/etc/ssh/ssh_host_* /etc/ssh/
# Uncomment to disable root login and password authentication
# COPY sshd_config.d/disable_root_and_passwords.conf /etc/ssh/sshd_config.d/

# -----------------------------------------------------------------------------
# USER CONFIGURATION
# -----------------------------------------------------------------------------
# Remove the default ubuntu user to avoid conflicts with the UID (1000)
RUN userdel -r ubuntu 2>/dev/null || true

# Create the user with the specified UID/GID
RUN useradd ${USERNAME} \
    --uid ${USER_UID} \
    --gid ${USER_GID} \
    --groups users,sudo \
    --create-home \
    --shell /bin/bash

# Enable passwordless sudo for the user
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# -----------------------------------------------------------------------------
# DEVELOPMENT LIBRARIES
# -----------------------------------------------------------------------------
# Install dev libraries separate from base system to optimize layer caching
RUN apt-get update && \
    apt-get install -y sqlite3 && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# ENTRYPOINT & SETUP SCRIPTS
# -----------------------------------------------------------------------------
COPY scripts/ /tmp/devbox-scripts/
RUN chmod +x /tmp/devbox-scripts/*.sh && \
    mv /tmp/devbox-scripts/*.sh /usr/local/bin/ && \
    rm -rf /tmp/devbox-scripts

# -----------------------------------------------------------------------------
# SWITCH USER
# -----------------------------------------------------------------------------
USER ${USERNAME}
WORKDIR /home/${USERNAME}

CMD ["/usr/local/bin/start.sh"]
