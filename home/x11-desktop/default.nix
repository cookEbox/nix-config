{ pkgs, ... }:

let
  cliphistX11Watch = pkgs.writeShellApplication {
    name = "cliphist-x11-watch";
    runtimeInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.cliphist
      pkgs.clipnotify
      pkgs.xclip
    ];
    text = ''
      # Watches the X11 clipboard and stores changes into cliphist.
      #
      # Requires:
      # - clipnotify: emits an event whenever the clipboard owner changes
      # - xclip: reads the clipboard content
      set -euo pipefail

      # Ensure cliphist DB exists.
      cliphist list >/dev/null 2>&1 || true

      # Store the current clipboard once at startup (best-effort).
      xclip -selection clipboard -o 2>/dev/null | cliphist store || true

      # Then store on every clipboard change.
      clipnotify | while IFS= read -r _; do
        xclip -selection clipboard -o 2>/dev/null | cliphist store || true
      done
    '';
  };

  cliphistRofi = pkgs.writeShellApplication {
    name = "cliphist-rofi-picker";
    runtimeInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.cliphist
      pkgs.rofi
      pkgs.xclip
    ];
    text = ''
      # Rofi picker for cliphist on X11.
      # Select an entry to copy it back into the clipboard.
      set -euo pipefail

      selection="$(cliphist list | rofi -dmenu -i -p 'Clipboard')"

      # User cancelled.
      if [ -z "$selection" ]; then
        exit 0
      fi

      # Decode + set clipboard.
      # Note: cliphist can store non-text; xclip is text-oriented, so this is MVP.
      printf '%s' "$selection" | cliphist decode | xclip -selection clipboard -in
    '';
  };

in
{
  # Desktop-only X11/XMonad "glue".
  # Keep this HM-first so it can be reused on non-NixOS bases later.

  home.packages = with pkgs; [
    # Clipboard
    cliphist
    clipnotify
    xclip
    cliphistX11Watch
    cliphistRofi

    # Notifications
    dunst

    # Network / Bluetooth applets (tray icons)
    networkmanagerapplet # provides `nm-applet`
    blueman # provides `blueman-applet`

    # File manager
    nemo

    # Audio utilities
    pavucontrol
    volumeicon
    pamixer
    wireplumber # provides `wpctl`

    # Compositor (optional early MVP)
    picom

    # Night light / colour temperature
    redshift

    # Polkit auth agent
    polkit_gnome

    # Secret storage + password manager
    gnome-keyring
    bitwarden-desktop

    # Bar / widgets
    eww
  ];

  # Keyring (credentials storage). Keep this at HM-level for portability.
  # On NixOS, PAM integration can still be handled at the system layer.
  services.gnome-keyring.enable = true;

  # Provide Polkit authentication prompts in lightweight WMs (XMonad, etc.).
  # DEs like MATE typically start this automatically; XMonad does not.
  #
  # Your Home Manager version doesn't expose `services.polkit-gnome-authentication-agent-1`,
  # so we define a user systemd service directly.
  systemd.user.services.polkit-gnome-auth-agent = {
    Unit = {
      Description = "Polkit authentication agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Keep config files out of inline Nix strings so they’re easier to edit and review.
  home.file = {
    ".config/dunst/dunstrc".source = ./config/dunst/dunstrc;
    ".config/picom/picom.conf".source = ./config/picom/picom.conf;
    ".config/eww/eww.yuck".source = ./config/eww/eww.yuck;
    ".config/eww/eww.scss".source = ./config/eww/eww.scss;
    ".config/redshift/redshift.conf".source = ./config/redshift/redshift.conf;
  };
}

