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
      awscli2
      awsls
      vscode
      procps
      brave
      bitwarden-desktop
      slack
      # github-copilot-cli
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
      gh 
      lynx
      gnumake 
      gcc
    ];
  };
}
