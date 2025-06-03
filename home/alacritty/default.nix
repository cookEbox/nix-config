{
  # Ensure Home Manager manages Alacritty
  programs.alacritty = {
    enable = true;
    settings = {
      # Add your other Alacritty settings here
      terminal.shell = {
        program = "tmux";
      };

      # Window padding
      window.padding = {
        x = 5;  # Horizontal padding
        y = 0;  # Vertical padding
      };
    };
  };

  # Other Home Manager configurations
}
