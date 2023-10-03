# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

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

  # Enable unfree packages
  nixpkgs.config.allowUnfree = true; 

  # Use the systemd-boot EFI boot loader.
  boot.loader = { 
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "nixBox"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "uk";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  services.fwupd.enable = true;
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  

  # Configure keymap in X11
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "altwin:menu_win";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "altwin:menu_win";
  #   "caps:escape"; # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nick = {
    shell = pkgs.zsh;
    isNormalUser = true;
    initialPassword = "P@ssword01";
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
  # packages = with pkgs; [
  #   thunderbird
  #   firefox
  #   zoom-us
  # ];
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
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    win-virtio
    win-spice
    gnome.adwaita-icon-theme
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable dconf (System Management Tool)
  programs.dconf.enable = true;

  # virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;



  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

