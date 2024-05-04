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
      videoDrivers = [ "nvidia" ];
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      layout = "gb";
      xkbOptions = "altwin:menu_win";
    }; 
    # Enable CUPS to print documents for a WiFi printer
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
    openssh.enable = true; 
  };

  hardware.opengl.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nick = {
    shell = pkgs.zsh;
    isNormalUser = true;
    initialPassword = "P@ssword01";
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    zsh.enable = true;
    dconf.enable = true; # Enable dconf (System Management Tool)
  };


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

