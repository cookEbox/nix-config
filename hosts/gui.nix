{ pkgs, ... }:

{
  # GUI-only defaults (kept separate from hosts/configuration.nix so non-GUI systems
  # can reuse the base config without pulling in a display manager/audio stack).

  # Display manager (graphical login)
  services.xserver.displayManager.lightdm = { 
    enable = true;
    greeters.slick.enable = true;
  };

  # Keyring (credentials storage). Enables PAM integration so the keyring can
  # unlock on login and apps (Evolution/Bitwarden/browsers) can use libsecret.

  services.gnome.gnome-keyring.enable = true;
  # Modern Linux audio stack.
  # Keep PulseAudio disabled and provide PulseAudio compatibility via PipeWire.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  xdg.portal = { 
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Recommended for PipeWire scheduling.
  security.rtkit.enable = true;
}

