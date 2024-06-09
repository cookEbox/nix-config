{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../../home/default.nix
                ../../../home/extra.nix
                ../../../home/dconf/desktop.nix
	 ];
   home = { 
     packages = with pkgs; [ 
       libsForQt5.kdenlive
     ];
   };
}
