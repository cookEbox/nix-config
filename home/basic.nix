{pkgs, ... }:

{
  imports = [
    ./tmux
    ./nvim
    ./starship
    ./zsh
    ./alacritty
    ./rofi
  ];

  home = {
    packages = with pkgs; [
      tty-clock
      zip
      emojipick
      neofetch
      jq
      nix-direnv
      lsd
      bat
      btop
      git
      unzip
      ripgrep
      tldr
      lsof
      direnv
      kitty
    ];

    file = {
      ".config/direnv/direnv.toml" = {
        text = ''
          hide_env_diff = true
        '';
      };

      # Global direnv helpers (loaded by direnv for all projects).
      # This keeps API keys out of the Nix store and git history.
      ".config/direnv/direnvrc" = {
        text = ''
          use_openai() {
            if [ -f "$HOME/.config/openai/api_key" ]; then
              export OPENAI_API_KEY="$(cat "$HOME/.config/openai/api_key")"
            fi

            # Set your preferred model ID (must be a valid OpenAI API model name you have access to)
            export OPENAI_MODEL="gpt-5.2"
          }

          use_tavily() {
            if [ -f "$HOME/.config/tavily/api_key" ]; then
              export TAVILY_API_KEY="$(cat "$HOME/.config/tavily/api_key")"
            else
              echo "use_tavily: missing $HOME/.config/tavily/api_key" >&2
              return 1
            fi
          }
        '';
      };
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
