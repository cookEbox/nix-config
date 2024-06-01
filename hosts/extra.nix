{

  services = {
    # Enable CUPS to print documents for a WiFi printer
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

  hardware = { 
    opengl.enable = true;
    sane.enable = true;
  };

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

}

