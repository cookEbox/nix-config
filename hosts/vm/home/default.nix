{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../../home/default.nix
                ../../../home/basic.nix
                ../../../home/dconf/laptop.nix
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
     ];
   };
}
