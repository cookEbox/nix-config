{ pkgs, ... }:

{
   imports = [ 
                ../../../home/default.nix
                ../../../home/basic.nix
                ../../../home/extra.nix
                ../../../home/dconf/desktop.nix
                ../../../home/xmonad
                ../../../home/x11-desktop/default.nix


	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       kdePackages.kdenlive
     ];
   };
}
