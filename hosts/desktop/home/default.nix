{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../../home/default.nix
                ../../../home/extra.nix
                ../../../home/dconf/desktop.nix
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       libsForQt5.kdenlive
     ];
   };
}
