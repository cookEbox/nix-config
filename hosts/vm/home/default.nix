{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../home/default.nix
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
     ];
   };
}
