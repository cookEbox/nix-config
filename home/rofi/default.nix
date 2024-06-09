{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = "gruvbox-dark-hard";
    extraConfig = {
      show-icons = true;
      display-drun = "Applications:";
      drun-display-format = "{icon} {name}";
      # icon-theme = "Gruvbox";
    };
  };
}
