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
       brave
       kde-gruvbox
       bat
       btop
       git
       git-crypt
       gnupg
       thunderbird
       zoom-us
       discord
       eza
       zathura
       onlyoffice-bin
       whatsapp-for-linux
       teams-for-linux
       unzip
       cmus
       xclip
       cargo
       gccgo13
       ripgrep
       tldr
       nerdfonts
       hydra-check
       mpv
       android-tools
       krita
       feh
       lsof
       xdotool
       virtiofsd
       libsForQt5.kdenlive
       mediainfo
       glaxnimate
       audacity
       libsForQt5.korganizer
       libsForQt5.akonadi
       libsForQt5.kdepim-runtime
       libsForQt5.akonadi-mime
       libsForQt5.akonadi-calendar
       gimp
       weechat
       obs-studio

       zig
       jre8
       llvmPackages_9.clang-unwrapped
       direnv
       nodejs_20
       rnix-lsp
       elmPackages.elm-language-server
       lua-language-server
       nodePackages.browser-sync
       nodePackages.typescript-language-server
       nodePackages.bash-language-server
       sqls
     ];
   };
}
