# hosts/gaming.nix
{ pkgs, ... }:

{
  programs.steam = {
    enable = true;

    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    gamescopeSession.enable = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamemode.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.kernel.sysctl = {
    # Proton / modern game compatibility.
    "vm.max_map_count" = 2147483642;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    gamescope
    protontricks
    vulkan-tools
    mesa-demos
  ];
}
