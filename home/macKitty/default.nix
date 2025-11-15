{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      macos_option_as_alt = "both";
      shell = "${pkgs.tmux}/bin/tmux";
    };
  };
}
