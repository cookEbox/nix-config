{ config, lib, pkgs, nixpkgs, ... }:

{
  programs.home-manager.enable = true;
  imports = [ 
               ../../../home/default.nix
               ../../../home/basic.nix
	];
  home = { 
    stateVersion = "25.05";
    username = "admin"; 
    homeDirectory = "/home/admin";
    packages = with pkgs; [ 
    ];
  };
}
