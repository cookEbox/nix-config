{ config, pkgs, ... }:

{ 
  imports = [
    ./hardware-configuration.nix
    ../configuration.nix
  ];

  boot = {
    loader = { 
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "nixVM";

}
