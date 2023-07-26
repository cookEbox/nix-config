{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
               ./zsh.nix 
	       ./nvim/nvim.nix
	     ];
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
       cmus
       xclip
       rnix-lsp
       haskell-language-server
       nodePackages_latest.typescript-language-server
     ];
   };
}
