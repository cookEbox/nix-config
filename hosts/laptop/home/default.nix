{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../../home/default.nix
                ../../../home/extra.nix
                ../../../home/dconf/laptop.nix
	 ];
   home = { 
     packages = with pkgs; [ 
     ];
   };
}
