{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ./zsh.nix 
                ./tmux.nix 
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
       # libreoffice-qt
       zathura
       onlyoffice-bin
       whatsapp-for-linux
       unzip
       cmus
       xclip
       cargo
       gccgo13
       ripgrep
       tldr
       nerdfonts
       hydra-check

       nodejs_20
       rnix-lsp
       vscode-langservers-extracted
       elmPackages.elm-language-server
       haskellPackages.haskell-language-server
       ghc
       luajitPackages.lua-lsp
       nodePackages.browser-sync
       nodePackages.typescript-language-server
       nodePackages.bash-language-server
       sqls
     ];
   };
}
