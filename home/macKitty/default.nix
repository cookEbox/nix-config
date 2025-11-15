{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      macos_option_as_alt = "both";
      shell.program = "${pkgs.tmux}/bin/tmux";
    };
  };
}
