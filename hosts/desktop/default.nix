{ pkgs, config, ... }:

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
      screenSection = ''
        Option         "metamodes" "DP-3: nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}, DP-0: nvidia-auto-select +1920+0 {ForceFullCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
        Option         "TripleBuffer" "on"
    '';
    }; 
  };

  hardware.nvidia = { 
    open = false;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = false; # Disable experimental power management
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
