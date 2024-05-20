{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ../../home/default.nix
                ../../home/extra.nix
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       libsForQt5.kdenlive
       glaxnimate
       libsForQt5.korganizer
       libsForQt5.akonadi
       libsForQt5.kdepim-runtime
       libsForQt5.akonadi-mime
       libsForQt5.akonadi-calendar

     ];
   };
}
