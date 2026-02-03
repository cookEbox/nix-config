{ pkgs, ... }:

let
  tmuxSessionSwitch = pkgs.writeShellScript "tmux-session-switch" ''
    set -euo pipefail

    # Ensure we talk to the *current* tmux server even if the popup environment is missing TMUX.
    # If TMUX is set, it looks like: "/path/to/socket,server-pid,client-id".
    socket=""
    if [ -n "''${TMUX-}" ]; then
      socket="''${TMUX%%,*}"
    fi

    if [ -n "''${socket}" ]; then
      sessions="$(${pkgs.tmux}/bin/tmux -S "''${socket}" list-sessions 2>&1 || true)"
    else
      sessions="$(${pkgs.tmux}/bin/tmux list-sessions 2>&1 || true)"
    fi

    # If tmux returned an error, show it so we can diagnose why the list is empty.
    if printf '%s' "''${sessions}" | ${pkgs.gnugrep}/bin/grep -qi "^no server running"; then
      echo "tmux: no server running"
      echo "(popup may be missing TMUX env; try restarting tmux server)"
      exit 0
    fi

    if [ -z "''${sessions}" ]; then
      echo "No sessions found."
      exit 0
    fi

    session="$(printf '%s\n' "''${sessions}" | ${pkgs.fzf}/bin/fzf --prompt='Switch to session > ' | cut -d: -f1)"
    [ -n "''${session}" ] || exit 0

    if [ -n "''${socket}" ]; then
      ${pkgs.tmux}/bin/tmux -S "''${socket}" switch-client -t "''${session}"
    else
      ${pkgs.tmux}/bin/tmux switch-client -t "''${session}"
    fi
  '';

  tmuxSessionKill = pkgs.writeShellScript "tmux-session-kill" ''
    set -euo pipefail

    socket=""
    if [ -n "''${TMUX-}" ]; then
      socket="''${TMUX%%,*}"
    fi

    if [ -n "''${socket}" ]; then
      sessions="$(${pkgs.tmux}/bin/tmux -S "''${socket}" list-sessions 2>&1 || true)"
    else
      sessions="$(${pkgs.tmux}/bin/tmux list-sessions 2>&1 || true)"
    fi

    if [ -z "''${sessions}" ]; then
      echo "No sessions found."
      exit 0
    fi

    printf '%s\n' "''${sessions}" \
      | ${pkgs.fzf}/bin/fzf -m --prompt='Kill sessions > ' \
      | cut -d: -f1 \
      | while IFS= read -r session; do
          [ -n "''${session}" ] || continue
          if [ -n "''${socket}" ]; then
            ${pkgs.tmux}/bin/tmux -S "''${socket}" kill-session -t "''${session}"
          else
            ${pkgs.tmux}/bin/tmux kill-session -t "''${session}"
          fi
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
      # Use vim-tmux-navigator for seamless nvim <-> tmux navigation.
      #
      # If you see "unknown command: TmuxNavigateLeft", the tmux plugin isn't loaded.
      # In that case, we fall back to native select-pane bindings below.
      if-shell -b '${pkgs.tmux}/bin/tmux list-commands | ${pkgs.gnugrep}/bin/grep -q "^TmuxNavigateLeft"' \
        'bind -n C-h TmuxNavigateLeft; bind -n C-j TmuxNavigateDown; bind -n C-k TmuxNavigateUp; bind -n C-l TmuxNavigateRight; bind -n C-\\ TmuxNavigatePrevious' \
        'bind -n C-h select-pane -L; bind -n C-j select-pane -D; bind -n C-k select-pane -U; bind -n C-l select-pane -R; bind -n C-\\ last-pane'

      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse
    '';
  };
}

