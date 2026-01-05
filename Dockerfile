FROM ubuntu:latest

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
    procps \
    file \
    pkg-config \
    bzip2 \
    rsync \
    vim \
    curl \
    htop \
    git \
    unzip \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# USER CONFIGURATION
# -----------------------------------------------------------------------------
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=100
ENV DEVBOX_USER=${USERNAME}

# Remove the default ubuntu user to avoid conflicts with the UID (1000)
RUN userdel -r ubuntu 2>/dev/null || true

# Create the user with the specified UID/GID
RUN useradd ${USERNAME} \
    --uid ${USER_UID} \
    --gid ${USER_GID} \
    --groups users,sudo \
    --create-home \
    --shell /bin/zsh

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
# RUNTIME CONFIGURATION
# -----------------------------------------------------------------------------
WORKDIR /

CMD ["/usr/local/bin/start.sh"]
