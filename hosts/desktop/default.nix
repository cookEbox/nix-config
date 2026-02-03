{ pkgs, unstable, ... }:

{
  # Prefer Ladybird from nixos-unstable while keeping the rest of the system on stable.
  nixpkgs.overlays = [
    (final: prev: {
      ladybird = unstable.ladybird;
    })
  ];

  imports = [
    ../configuration.nix
    ../extra.nix
    ./hardware-configuration.nix
  ];

  security.pam.loginLimits = [
    { domain = "*"; item = "nofile"; type = "soft"; value = "1048576"; }
    { domain = "*"; item = "nofile"; type = "hard"; value = "1048576"; }
  ];

  boot = {
    kernelModules = ["vfio-pci" "xe"];
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

  hardware.graphics.enable32Bit = true; 

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    virtio-win
    win-spice
    virglrenderer
  ];

  services = { 
    logind.settings.Login = { IdleAction = "ignore"; };
    spice-vdagentd.enable = true;
    xserver = {
      videoDrivers = [ "modesetting" ];
      serverFlagsSection = ''
        Option "BlankTime" "0"
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "0"
      '';
    }; 
  };

  # virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;

        # NixOS 25.11: the ovmf submodule was removed; OVMF images are available by default.
        # Keep this block minimal; if you need a specific OVMF variant later, we can re-add
        # the appropriate qemu/firmware configuration.
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
