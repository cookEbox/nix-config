{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      macos_option_as_alt = "both";
      shell = "${pkgs.tmux}/bin/tmux";
    };

    # On macOS, Option+<key> can be interpreted as a special character depending on keyboard layout.
    # Force Option+j/k to send an ESC-prefixed sequence so tmux sees Meta-j/Meta-k.
    keybindings = {
      "alt+j" = "send_text all \\x1bj";
      "alt+k" = "send_text all \\x1bk";
    };
  };
  home.file = { 
    ".aerospace.toml".source = ./aerospace.toml;
  };

}
