{ pkgs, ... }:

{
  # XMonad itself is enabled at the NixOS host layer (hosts/xmonad.nix).
  # This module provides the user-level config and session scripts.

  home = {
    packages = with pkgs; [
      # Required by some existing config helpers (clickable workspaces)
      xdotool

      # Utilities referenced by existing keybindings
      dmenu
      flameshot
      xfce.xfce4-volumed-pulse

      # Useful for the built-in help popup
      xmessage
    ];

    file = {
      # XMonad 0.18+ prefers the XDG path (~/.config/xmonad/xmonad.hs).
      # Keep the legacy path (~/.xmonad/xmonad.hs) too for compatibility.
      ".config/xmonad/xmonad.hs" = {
        source = ./xmonad.hs;
      };

      ".xmonad/xmonad.hs" = {
        source = ./xmonad.hs;
      };

      ".xmonad/autostart.sh" = {
        source = ./autostart.sh;
        executable = true;
      };

      ".xmonad/multiple-monitors.sh" = {
        source = ./multiple-monitors.sh;
        executable = true;
      };
    };
  };
}

