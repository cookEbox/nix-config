{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    # theme = "~/.config/rofi/themes/gruvbox-dark-soft.rasi";
  };
}
