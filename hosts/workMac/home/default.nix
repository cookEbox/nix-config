{ pkgs, ... }:

{
  programs.home-manager.enable = true;
  imports = [ 
               ../../../home/default.nix
               ../../../home/mac.nix
               
	];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  home = { 
    stateVersion = "24.11";
    username = "nick"; 
    homeDirectory = "/Users/nick";
    packages = with pkgs; [ 
    ];
  };
}
