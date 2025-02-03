{ config, pkgs, ... }:

{
   imports = [ 
                ../../../home/default.nix
	 ];
   home = { 
     packages = with pkgs; [ 
     ];
   };
}
