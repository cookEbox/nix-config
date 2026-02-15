{
  # Ensure Home Manager manages Alacritty
  programs.alacritty = {
    enable = true;
    settings = {
      # Font settings
      # If your text looks "zoomed"/too large, reduce this value.
      font.size = 11.0;

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
