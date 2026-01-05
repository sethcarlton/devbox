# Devbox

A personal, containerized development environment with optional support for:

- Persistent home directory
- Tailscale
- Unraid support

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

Your directories persist in `~/devbox/` (or wherever you choose) on your host machine.

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

**Build:**

_Important: Ensure Username, UID, and GID match an Unraid user who has access to the share (you can find these with the `id username` command in Unraid)._

```bash
docker build \
  --build-arg USERNAME=seth \
  --build-arg USER_UID=1000 \
  --build-arg USER_GID=100 \
  -t devbox .
```

**Setup:**

First, create an unraid share. Use a Cache pool instead of the Array. Here, we have named it `devbox`. Then, on the Unraid host, create your `home_dir`.

```bash
mkdir -p /mnt/user/devbox/home_dir
```

**Run:**

_Notes:_

- The username in the home volume path should match your Unraid user
- The `/config` volume is optional — it enables auto-detection for tools like Tailscale that expect an appdata-style config directory
- You could also mount a separate directory (eg. `/mnt/user/devbox/code:/code`) for code, but I just work out of `~/code`. This also simplifies permissions.

```bash
docker run -d \
  --name devbox \
  --hostname devbox \
  -v /mnt/user/devbox/home_dir:/home/seth \
  -v /mnt/user/appdata/devbox:/config \
  devbox
```

## Initialize Container

### First-Time Setup

Connect to the container (or SSH in if Tailscale is already set up) and run the initialization script:

```bash
docker exec -it -u dev devbox zsh
# or docker exec -it -u dev devbox bash
init.sh
```

Available scripts:

- `init.sh` — runs dotfiles.sh (entry point)
- `dotfiles.sh` — sync dotfiles using the bare repo method
- `configure-git.sh` — configure git name/email and generate SSH key

See [my dotfiles](https://github.com/sethcarlton/dotfiles) for docs on initializing tools.

## Tailscale (Unraid)

This covers Tailscale integration via Unraid's built-in Docker hook. You could also install Tailscale manually inside the container if instead.

### How It Works

The container starts as root to allow Unraid's Tailscale hook to run with proper privileges, then drops to your user for the main process.

### Setup

In your Unraid Docker template settings:

1. Set **Use Tailscale** to `On`
2. Set **Tailscale Hostname** to `devbox`
3. Enable **Tailscale SSH**

Then:

5. Start the container and check the logs for the authentication link
6. Authenticate via the link
7. Disable key expiry for devbox in the [Tailscale admin console](https://login.tailscale.com/admin/machines)

Once connected, you can reach devbox from any device on your Tailnet via its hostname or Tailscale IP.

## Remote Workflow

SSH in with `ssh devbox`, start your dev server with `--host`, and preview via `{tailscale-ip}:{port}` from any device on your Tailnet.

Use tmux to keep sessions alive — run opencode or claude code, walk away, close your laptop, resume from anywhere.
