# Nix + Home Manager with Flakes

This repository manages both **NixOS system configurations** and **Home
Manager configurations** (standalone or on top of NixOS) using flakes.

It allows you to share configuration across multiple machines (desktop,
laptop, VMs, Raspberry Pi, etc.) while keeping each host's specifics
isolated under `./hosts/<name>`.

------------------------------------------------------------------------

## Structure

-   `nixosConfigurations`: for full NixOS systems (desktop, laptop, VM).
-   `homeConfigurations`: for Home Manager (standalone or non-NixOS
    machines like Raspberry Pi).

Each host has its own directory, for example:

    hosts/
      desktop/
        home/
      laptop/
        home/
      vm/
        home/
      pi/
        home/
      work/
        home/

------------------------------------------------------------------------

## Usage

### 1. Enable flakes (all hosts)

Make sure flakes are enabled in `/etc/nix/nix.conf`:

    experimental-features = nix-command flakes

Restart the daemon if needed:

``` sh
sudo systemctl restart nix-daemon
```

If you find that `nix` or `nix-store` are not on your PATH (common on
Raspberry Pi OS), fix it with:

``` sh
sudo ln -sf /nix/var/nix/profiles/default/bin/nix       /usr/local/bin/nix
sudo ln -sf /nix/var/nix/profiles/default/bin/nix-store /usr/local/bin/nix-store
```

------------------------------------------------------------------------

### 2. Deploy NixOS machines

On a NixOS host (e.g. desktop/laptop/vm), rebuild directly from GitHub:

``` sh
sudo nixos-rebuild switch --flake github:<youruser>/<yourrepo>#nixBox
sudo nixos-rebuild switch --flake github:<youruser>/<yourrepo>#nixLap
sudo nixos-rebuild switch --flake github:<youruser>/<yourrepo>#nixVM
```

------------------------------------------------------------------------

### 3. Deploy Home Manager (standalone)

For non-NixOS hosts (e.g. Raspberry Pi, work machine), use Home Manager
via flakes.

#### Apply locally (on the machine):

``` sh
nix run github:nix-community/home-manager/release-25.05 --   switch --flake github:<youruser>/<yourrepo>#pi
```

or

``` sh
nix run github:nix-community/home-manager/release-25.05 --   switch --flake github:<youruser>/<yourrepo>#work
```

#### Apply remotely (from another machine):

``` sh
nix run github:nix-community/home-manager/release-25.05 --   switch --flake github:<youruser>/<yourrepo>#pi   --target-host user@pi-hostname --build-host user@pi-hostname
```

------------------------------------------------------------------------

### 4. Pinning versions

To ensure reproducibility, pin to a commit hash:

``` sh
sudo nixos-rebuild switch --flake github:<youruser>/<yourrepo>?rev=<GIT_COMMIT>#nixBox
```

or

``` sh
nix run github:nix-community/home-manager/release-25.05 --   switch --flake "github:<youruser>/<yourrepo>?rev=<GIT_COMMIT>#pi"
```

------------------------------------------------------------------------

## Neovim: GitHub Copilot

This repo enables GitHub Copilot in Neovim via [`zbirenbaum/copilot.lua`](https://github.com/zbirenbaum/copilot.lua) (Nix-managed).

### Requirements

These are already provided by the Nix config:

- `curl`
- `node` **>= 22**
- Neovim **>= 0.11**

### First-time setup (recommended: device code sign-in)

1. Apply your Home Manager / NixOS config so Neovim has the plugin.
2. Open Neovim.
3. Run:

   ```vim
   :Copilot auth
   ```

4. Follow the prompt:
   - Copy the one-time code
   - Open the GitHub URL it gives you
   - Paste the code and authorise Copilot for your GitHub account

To check which account is signed in:

```vim
:Copilot auth info
```

To sign out / switch accounts:

```vim
:Copilot auth signout
:Copilot auth signin
```

**Where credentials live** (upstream default):

- `~/.config/github-copilot/apps.json` (or `$XDG_CONFIG_HOME/github-copilot/apps.json`)

### Token-based setup (optional)

Upstream notes that tokens are **not officially supported**, but it can work if you set an auth token environment variable.

1. First authenticate once using `:Copilot auth`.
2. Then capture the token:

   ```vim
   :Copilot auth info
   ```

3. Set one of these environment variables (choose one):

- `GH_COPILOT_TOKEN`
- `GITHUB_COPILOT_TOKEN`

How you set this is up to you (direnv, shell profile, etc.). If the variable is present **even if empty**, Copilot will try to use it.

### Simple user guide (with this repo’s defaults)

Copilot suggestions are enabled but **auto-trigger is OFF** to avoid fighting `nvim-cmp`.

In **insert mode**:

- Accept suggestion: `Ctrl-l`
- Next suggestion: `Alt-n`
- Previous suggestion: `Alt-p`
- Dismiss suggestion: `Ctrl-]`

Notes:

- If your terminal doesn’t send `Alt-n`/`Alt-p` correctly, change the keymaps in:
  - `home/nvim/copilot_config.lua`
- Copilot inline suggestions are automatically hidden while the `nvim-cmp` completion menu is open.
- Copilot is configured not to attach to likely-secret files (e.g. `.env*`, `*secret*`, `*.pem`, `*.key`, `*.p12`).

------------------------------------------------------------------------

## Notes

-   Always set `home.username`, `home.homeDirectory`, and
    `home.stateVersion` in each Home Manager config.

-   Use the right system identifier:

    -   `x86_64-linux` for desktops/laptops/VMs\
    -   `aarch64-linux` for 64-bit Raspberry Pi OS\
    -   `armv7l-linux` for 32-bit Raspberry Pi OS\

-   For non-NixOS, you may need to set your login shell once manually:

    ``` sh
    chsh -s $(command -v zsh)
    ```

-   To set up passwordless SSH access (for remote apply):

    1.  Leave `PasswordAuthentication yes` enabled in
        `/etc/ssh/sshd_config`.\
    2.  Run `ssh-copy-id user@host` from your desktop.\
    3.  Verify you can log in without a password.\
    4.  Only then disable password authentication by setting
        `PasswordAuthentication no`.

------------------------------------------------------------------------

With this setup, you can manage **NixOS machines, standalone Linux
hosts, and even Raspberry Pis** from a single flake repository.
