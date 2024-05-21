{ pkgs, ... }:

{ 
  imports = [
    ../configuration.nix 
    ../extra.nix
    ./hardware-configuration.nix
  ];

  boot = {
    kernelModules = ["vfio-pci"];
    blacklistedKernelModules = ["nouveau"];
    loader = { 
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "nixLap";

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    win-virtio
    win-spice
    virglrenderer
  ];

  services.spice-vdagentd.enable = true;

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
}
