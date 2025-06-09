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
  };

  services = {
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
    openssh.enable = true; 
    pulseaudio.enable = false;
  };

  users.users.nick = {
    shell = pkgs.zsh;
    isNormalUser = true;
    initialPassword = "P@ssword01";
    extraGroups = [ "wheel" "libvirtd" "lp" "scanner" ]; 
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
    ];
  };

  programs = {
    zsh.enable = true;
    dconf.enable = true; 
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11"; 
}

