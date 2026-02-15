{ pkgs, ... }:

{ 
  imports = [
    ../configuration.nix
    ../gui.nix
    ../mate.nix
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
    virtio-win
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

        # NixOS 25.11: the ovmf submodule was removed; OVMF images are available by default.
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
