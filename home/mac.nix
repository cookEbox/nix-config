{pkgs, ... }:

{
  imports = [ 
               ./tmux/darwin.nix
               ./macKitty
               ./nvim
               ./starship
               ./zsh
	];
  home = { 
    packages = with pkgs; [ 
      aerospace
      zip
      neofetch
      jq
      nix-direnv
      lsd
      bat
      btop
      git
      unzip
      ripgrep
      tldr
      lsof
      direnv
      qutebrowser
    ];
  };
}
