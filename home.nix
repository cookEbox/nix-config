{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = (import ./zsh.nix);
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       kde-gruvbox
       bat
       btop
       git
       git-crypt
       gnupg
       thunderbird
       zoom-us
       exa
       libreoffice-qt
       zathura
       onlyoffice-bin
       whatsapp-for-linux
       unzip
     ];
   };
}
