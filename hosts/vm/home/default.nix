{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../../home/default.nix
                ../../../home/dconf/laptop.nix
	 ];
   home = { 
     packages = with pkgs; [ 
     ];
   };
}
