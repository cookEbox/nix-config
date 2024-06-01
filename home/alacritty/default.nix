{
  # Ensure Home Manager manages Alacritty
  programs.alacritty = {
    enable = true;
    settings = {
      # Add your other Alacritty settings here

      # Window padding
      window.padding = {
        x = 20;  # Horizontal padding
        y = 20;  # Vertical padding
      };
    };
  };

  # Other Home Manager configurations
}
