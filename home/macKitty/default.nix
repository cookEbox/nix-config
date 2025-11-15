{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      macos_option_as_alt = "both";
      terminal.shell = {
        program = "${pkgs.tmux}/bin/tmux";
      };
      window.padding = {
        x = 5;
        y = 0;
      };
    };
  };
}
