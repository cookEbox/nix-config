
{ config, pkgs, ... }:

{

  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
    }; 
    # Enable CUPS to print documents for a WiFi printer
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };
  };

  hardware.opengl.enable = true;

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    zsh.enable = true;
    dconf.enable = true; # Enable dconf (System Management Tool)
  };

}

