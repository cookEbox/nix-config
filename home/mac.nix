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
      aws-vault
      awscli2
      awsls
      vscode
      procps
      brave
      # bitwarden-desktop
      slack
      # github-copilot-cli
      aerospace
      zip
      fastfetch
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
      gh 
      lynx
      gnumake 
      gcc
    ];
  };
}
