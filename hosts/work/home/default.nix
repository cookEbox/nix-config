{ config, lib, pkgs, nixpkgs, ... }:

{
  programs.home-manager.enable = true;
  imports = [ 
               ../../../home/default.nix
	];
  home = { 
    username = "nick"; 
    homeDirectory = "/home/nick";
    packages = with pkgs; [ 
    ];
  };
}
