{ config, lib, pkgs, nixpkgs, ... }:

{
  programs.home-manager.enable = true;
  imports = [ 
               ../../../home/default.nix
               ../../../home/mac.nix
	];
  home = { 
    stateVersion = "24.11";
    username = "nick"; 
    homeDirectory = "/Users/nick";
    packages = with pkgs; [ 
    ];
  };
}
