{ config, lib, pkgs, nixpkgs, ... }:

{
  programs.home-manager.enable = true;
  imports = [ 
               ../../../home/default.nix
	];
  home = { 
    stateVersion = "24.11";
    username = "COLUMBUS\\u.7863693"; 
    homeDirectory = "/home/u.7863693";
    packages = with pkgs; [ 
    ];
  };
}
