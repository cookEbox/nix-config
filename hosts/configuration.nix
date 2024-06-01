{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
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
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.nick = {
    shell = pkgs.zsh;
    isNormalUser = true;
    initialPassword = "P@ssword01";
    extraGroups = [ "wheel" "libvirtd" "lp" "scanner" ]; 
  };

  environment.systemPackages = with pkgs; [
    audacity
    alacritty
    neovim 
    wget
    firefox
    htop
    neofetch
    pfetch
    gnome.adwaita-icon-theme
  ];

  programs = {
    zsh.enable = true;
    dconf.enable = true; 
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11"; 
}

