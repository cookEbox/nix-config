{ pkgs, lib, ... }:

{
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      substituters = [ "https://nixcache.reflex-frp.org" ];
      trusted-public-keys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  fonts = { 
    fontconfig.enable = true;
    packages = [ pkgs.dejavu_fonts ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };

  nixpkgs.config = { 
    allowUnfree = true; 
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  networking = {
    networkmanager.enable = true;
    nameservers = [ "1.1.1.1" ];
    firewall = { 
    enable = true;

    # Desktop: default is allow outbound, block inbound
    allowPing = false;

    # If you want inbound SSH to your desktop (usually no):
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];

    # If using Tailscale / WireGuard:
    trustedInterfaces = [ "tailscale0" "wg0" ];

    # Logging is useful while stabilising
    logRefusedConnections = true;
    };
  };

  services = {
    udev.extraRules = ''
      # Rules for Oryx web flashing and live training
      KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

      # Legacy rules for live training over webusb (Not needed for firmware v21+)
        # Rule for all ZSA keyboards
        SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
        # Rule for the Moonlander
        SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
        # Rule for the Ergodox EZ
        SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
        # Rule for the Planck EZ
        SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

      # Wally Flashing rules for the Ergodox EZ
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
      ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
      KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

      # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
      # Keymapp Flashing rules for the Voyager
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
    '';
    fwupd.enable = true;
    xserver = {
      enable = true;
      displayManager.lightdm.greeters.slick.enable = true;
      desktopManager.mate.enable = true;
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
      xkb = {
        layout = "gb";
        options = "altwin:menu_win";
      };
    }; 
    # Desktop: keep SSH disabled unless you explicitly need inbound access.
    # If you do need it, re-enable and use the hardened settings below.
    openssh = {
      enable = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "nick" ];
      };
    };

    pulseaudio.enable = false;

    # Flatpak provides strong sandboxing for browsers/Electron apps.
    flatpak.enable = true;
  };

  # AppArmor is a safe default on NixOS and reduces impact of app compromise.
  security.apparmor.enable = true;

  # Low-friction kernel/sysctl hardening.
  security = {
    protectKernelImage = true;
    sudo.execWheelOnly = true;
    sudo.wheelNeedsPassword = true;
  };

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
  };

  users.groups.plugdev = { };
  users.users.nick = {
    shell = pkgs.zsh;
    isNormalUser = true;
    # Do not store plaintext passwords in Nix (ends up in the Nix store + git history).
    # Set the password interactively once with: passwd
    extraGroups = [ "wheel" "libvirtd" "lp" "scanner" "plugdev" ];
  };

  environment = { 
    sessionVariables = {
      DIRENV_LOG_FORMAT = "\"\"";
      };
    systemPackages = with pkgs; [
      audacity
      alacritty
      neovim 
      wget
      firefox
      htop
      neofetch
      pfetch
      adwaita-icon-theme
      prismlauncher
      mesa
      libglvnd
      vulkan-tools
    ];
  };

  programs = {
    zsh.enable = true;
    dconf.enable = true; 
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11"; 
}

