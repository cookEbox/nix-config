{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../../home/default.nix
	 ];
   home = { 
     packages = with pkgs; [ 
     ];
   };
}
