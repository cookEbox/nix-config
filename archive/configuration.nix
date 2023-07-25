# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
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
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

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
  
  home-manager.useGlobalPkgs = true;
  home-manager.users.nick = { pkgs, ... }: {
    home.stateVersion = "23.05";
    home.packages = with pkgs; [ 
      kde-gruvbox
      bat
      btop
      git
      git-crypt
      gnupg
      thunderbird
      zoom-us
      zsh
      exa
      libreoffice-qt
      zathura
      onlyoffice-bin
      whatsapp-for-linux
      unzip
    ];

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      shellAliases = {
	cat = "bat";
	sl = "exa";
        ls = "exa";
        l = "exa -l";
        la = "exa -la";
        ll = "exa -lah";
	lt = "exa --tree";
        ip = "ip --color=auto";
        update = "cd ~/.config/nix-config/ && sudo nixos-rebuild switch --flake '.#' --impure && cd - && source ~/.zshrc";
	upgrade = "cd ~/.config/nix-config/ && sudo nixos-rebuild switch --flake '.#' --impure --upgrade && nix-store --gc && nix-store --optimise -vv && cd -";
        config = "nvim ~/.config/nix-config/configuration.nix";
	add = "~/.config/addaddcommit.sh";
	server = "ssh root@192.168.1.140";
        };
      history = {
        size = 10000;
        path = "/home/nick/.config/zsh/history";
      };
      plugins = with pkgs; [
        {
          name = "agkozak-zsh-prompt";
          src = fetchFromGitHub {
            owner = "agkozak";
            repo = "agkozak-zsh-prompt";
            rev = "v3.7.0";
            sha256 = "1iz4l8777i52gfynzpf6yybrmics8g4i3f1xs3rqsr40bb89igrs";
          };
          file = "agkozak-zsh-prompt.plugin.zsh";
        }
        {
          name = "formarks";
          src = fetchFromGitHub {
            owner = "wfxr";
            repo = "formarks";
            rev = "8abce138218a8e6acd3c8ad2dd52550198625944";
            sha256 = "1wr4ypv2b6a2w9qsia29mb36xf98zjzhp3bq4ix6r3cmra3xij90";
          };
          file = "formarks.plugin.zsh";
        }
        {
          name = "zsh-syntax-highlighting";
          src = fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0.6.0";
            sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
          };
          file = "zsh-syntax-highlighting.zsh";
        }
        {
          name = "zsh-abbrev-alias";
          src = fetchFromGitHub {
            owner = "momo-lab";
            repo = "zsh-abbrev-alias";
            rev = "637f0b2dda6d392bf710190ee472a48a20766c07";
            sha256 = "16saanmwpp634yc8jfdxig0ivm1gvcgpif937gbdxf0csc6vh47k";
          };
          file = "abbrev-alias.plugin.zsh";
        }
        {
          name = "zsh-autopair";
          src = fetchFromGitHub {
            owner = "hlissner";
            repo = "zsh-autopair";
            rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
            sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
          };
          file = "autopair.zsh";
        }
      ];
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

  };
}

