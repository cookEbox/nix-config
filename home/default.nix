{ pkgs, ... }:

let
  # Provide a stable system-wide `concat` command. The actual script is deployed into
  # ~/.config/concat/concat.sh via `home.file`, so this also works for remote flake
  # installs (e.g. from GitHub) without depending on the repo path at runtime.
  concat = pkgs.writeShellApplication {
    name = "concat";
    runtimeInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.findutils
    ];
    text = ''
      exec ${pkgs.bash}/bin/bash "$HOME/.config/concat/concat.sh" "$@"
    '';
  };

in
{
  imports = [
    ./ranger
  ];

  home = {
    packages = with pkgs; [
      nmap
      gitui
      zathura
      feh

      # LSP server binaries (used by Neovim's built-in LSP)
      nil
      lua-language-server

      # Custom scripts
      concat
    ];

    file = {
      # Deploy the script to a stable location in the home directory.
      ".config/concat/concat.sh" = {
        source = ../concat.sh;
        executable = true;
      };

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
            local key_file="$HOME/.config/openai/api_key"

            if [ -f "$key_file" ]; then
              export OPENAI_API_KEY="$(tr -d '\n' < "$key_file")"
            else
              echo "use_openai: missing $key_file" >&2
              return 1
            fi

            export OPENAI_MODEL="gpt-5.5"
          }

          use_claude() {
            local key_file="$HOME/.config/claude/api_key"

            if [ -f "$key_file" ]; then
              export ANTHROPIC_API_KEY="$(tr -d '\n' < "$key_file")"

              # Optional compatibility alias for your own code.
              export CLAUDE_API_KEY="$ANTHROPIC_API_KEY"
            else
              echo "use_claude: missing $key_file" >&2
              return 1
            fi

            # Good default for an agent: cheaper/faster than Opus, strong for coding.
            export ANTHROPIC_MODEL="claude-sonnet-4-6"

            # Optional compatibility alias for your own code.
            export CLAUDE_MODEL="$ANTHROPIC_MODEL"
          }

          use_tavily() {
            local key_file="$HOME/.config/tavily/api_key"

            if [ -f "$key_file" ]; then
              export TAVILY_API_KEY="$(tr -d '\n' < "$key_file")"
            else
              echo "use_tavily: missing $key_file" >&2
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
