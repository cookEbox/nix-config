{pkgs, ... }:

{
  imports = [ 
               ./tmux
               ./macKitty
               ./nvim
               ./starship
               ./zsh
	];
  home = { 
    packages = with pkgs; [ 
      brave
      bitwarden-desktop
      slack
      copilot-cli
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
