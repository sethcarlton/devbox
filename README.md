# Devbox

A containerized development environment with optional persistent home directory, SSH + mDNS, and/or Tailscale support. Can run on any Docker host (Unraid, Linux, macOS, Windows).

## Quick Start

### Example 1: Ephemeral

Home directory, code, and user data is wiped when the container is removed. Good for quick testing or one-off tasks.

**Build:**

```bash
docker build -t devbox .
```

**Run:**

```bash
docker run -d --name devbox --hostname devbox devbox
```

---

### Example 2: Persistent Directories

Your home directory and code persist in `~/devbox/` (or wherever you choose) on your host machine.

**Setup:**

```bash
mkdir -p ~/devbox/home_dir ~/devbox/code
```

**Build:**

```bash
docker build -t devbox .
```

**Run:**

```bash
docker run -d \
  --name devbox \
  --hostname devbox \
  -v ./home_dir:/home/dev \
  -v ./code:/code \
  devbox
```

---

### Example 3: Unraid With Persistent Share

**Setup:**

First, create an unraid share. Use a Cache pool instead of the Array. Here, we have named it `devbox`. Then, on the Unraid host, create your `home_dir` and `code` directories.

```bash
mkdir -p /mnt/user/devbox/home_dir /mnt/user/devbox/code
```

**Build:**

_Important: Ensure Username, UID, and GID match an Unraid user who has access to the share (you can find these with the `id username` command in Unraid)._

```bash
docker build \
  --build-arg USERNAME=seth \
  --build-arg USER_UID=1000 \
  --build-arg USER_GID=100 \
  -t devbox .
```

**Run:**

_Note the username in the home path map_

```bash
docker run -d \
  --name devbox \
  --hostname devbox \
  -v /mnt/user/devbox/home_dir:/home/seth \
  -v /mnt/user/devbox/code:/code \
  devbox
```

## Initialize Container

### First-Time Setup

Connect to the container and run the initialization script:

```bash
docker exec -it devbox bash
init.sh
```

This will:

- Install development tools (Node.js, Bun, OpenCode, etc.)
- Configure Git (name, email, SSH key)
- Optionally clone your OpenCode configuration

You can see what scripts are available in `/scripts`. They are all copied to the container at `/usr/local/bin/` and can be run ad-hoc.

## Advanced: Remote Access (SSH & mDNS) HAVE NOT TESTED ANY OF THIS YET

By default, this container uses `docker exec` for access. For SSH/mDNS support:

1. **Generate persistent SSH host keys:**

   ```bash
   mkdir -p ssh_keys && ssh-keygen -A -f ssh_keys/
   ```

2. **Add your laptop's public key to authorized_keys:**

   ```bash
   echo "ssh-ed25519 AAAA...your_key you@laptop" >> home_dir/.ssh/authorized_keys
   chmod 600 home_dir/.ssh/authorized_keys
   ```

3. **Uncomment SSH/Avahi sections in `Dockerfile` and `start.sh`**

4. **Rebuild and run with network access:**

   ```bash
   docker build -t devbox .
   docker run -d \
     --name devbox \
     --hostname devbox \
     --network br0 \
     -v /path/to/home_dir:/home/dev \
     devbox
   ```

5. **Connect via SSH:**
   ```bash
   ssh dev@devbox.local
   ```

**Note:** Use `--network br0` (macvlan on Unraid) for mDNS to work. To access other Docker containers, add a second network: `docker network connect your-network devbox`
