{ pkgs, ... }:

{
  programs.home-manager.enable = true;
  imports = [ 
               ../../../home/default.nix
               ../../../home/mac.nix
               
	];
  # Disable direnv on workMac while we debug tmux regressions.
  # Keep it enabled on other hosts (e.g. desktop) via shared modules.
  programs.direnv = {
    enable = false;
    nix-direnv.enable = false;
  };
  home = { 
    stateVersion = "24.11";
    username = "nick"; 
    homeDirectory = "/Users/nick";
    packages = with pkgs; [ 
    ];
  };
}
