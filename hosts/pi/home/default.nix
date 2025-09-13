{ config, lib, pkgs, nixpkgs, ... }:

{
  programs.home-manager.enable = true;
  imports = [ 
               ../../../home/default.nix
	];
  home = { 
    stateVersion = "24.11";
    username = "admin"; 
    homeDirectory = "/home/admin";
    packages = with pkgs; [ 
    ];
  };
}
