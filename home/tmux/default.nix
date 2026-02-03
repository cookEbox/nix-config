{ pkgs, ... }:

let
  tmuxSessionSwitch = pkgs.writeShellScript "tmux-session-switch" ''
    set -euo pipefail

    session="$(tmux ls 2>/dev/null | ${pkgs.fzf}/bin/fzf --prompt='Switch to session > ' | cut -d: -f1)"
    [ -n "''${session}" ] || exit 0

    tmux switch-client -t "''${session}"
  '';

  tmuxSessionKill = pkgs.writeShellScript "tmux-session-kill" ''
    set -euo pipefail

    tmux ls 2>/dev/null \
      | ${pkgs.fzf}/bin/fzf -m --prompt='Kill sessions > ' \
      | cut -d: -f1 \
      | while IFS= read -r session; do
          [ -n "''${session}" ] || continue
          tmux kill-session -t "''${session}"
        done
  '';

in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    shortcut = "q";
    escapeTime = 10;
    keyMode = "vi";
    terminal = "tmux-256color";
    historyLimit = 50000;
    plugins = with pkgs.tmuxPlugins;
      [
        gruvbox
        vim-tmux-navigator
        fzf-tmux-url
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
            '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            '';
        }
      ];

    extraConfig = ''
      unbind C-q
      unbind q
      set-option -g prefix C-s
      bind s send-prefix
      bind C-a last-window
      set -g status off 

      bind j new-window -c "#{pane_current_path}" 
       
      bind -n M-j previous-window
      bind -n M-k next-window

      # Note: no tmux config reload binding. Restart tmux (`tmux kill-server`) to apply changes.
       
      setw -g mouse on
       
      unbind %
      unbind [
      bind-key [ split-window -h
      unbind '"'
      bind-key ] split-window -v
      bind-key . split-window -v -p 20

      bind-key -n 'C-y' copy-mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
      bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

      # Session management popups
      # Use Nix-generated scripts to avoid brittle quoting and improve portability.
      bind-key X display-popup -E "${tmuxSessionKill}"
      bind-key S display-popup -E "${tmuxSessionSwitch}"

      # Pane navigation (vim home row)
      # Seamless nvim <-> tmux navigation via tmux plugin `vim-tmux-navigator`
      # (and Neovim plugin `vim-tmux-navigator`, already enabled in home/nvim/default.nix).
      #
      # The tmux plugin provides these commands:
      #   TmuxNavigateLeft/Down/Up/Right/Previous
      # which will:
      #   - move between tmux panes when you're not in (n)vim
      #   - forward the keypress into (n)vim when you are
      bind -n C-h TmuxNavigateLeft
      bind -n C-j TmuxNavigateDown
      bind -n C-k TmuxNavigateUp
      bind -n C-l TmuxNavigateRight
      bind -n C-\\ TmuxNavigatePrevious

      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse
      '';
  };
}
