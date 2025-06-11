{
  services = {
    logind = {
      extraConfig = ''
        IdleAction=ignore
        IdleActionSec=0
      '';
    };

    # Enable CUPS to print documents for a WiFi printer
    blueman.enable = true;
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish ={
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
  };

  # systemd.targets = {
  #   sleep.enable = false;
  #   suspend.enable = false;
  #   hibernate.enable = false;
  #   hybridSleep.enable = false;
  # };

  hardware = { 
    enableAllFirmware = true;
    graphics.enable = true;
    sane.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  programs = {
    ladybird.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

}

