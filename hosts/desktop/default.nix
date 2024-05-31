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
    kernelParams = ["amd_iommu=on"];
    loader = { 
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "nixBox";

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    win-virtio
    win-spice
    virglrenderer
  ];

  services = { 
    spice-vdagentd.enable = true;
    xserver = {
      videoDrivers = [ "nvidia" ];
    }; 
  };

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
