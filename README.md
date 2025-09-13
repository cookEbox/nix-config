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
