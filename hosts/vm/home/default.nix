{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../home/default
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
     ];
   };
}
