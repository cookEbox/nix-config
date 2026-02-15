{ ... }:

{ 
  imports = [
    ./hardware-configuration.nix
    ../configuration.nix
    ../gui.nix
    ../mate.nix
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
