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

    # Home Manager's `shortcut` sets the default prefix. We override it below in extraConfig
    # but keep it set here so the module doesn't use the default C-b.
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

      # Window navigation.
      # Bind both j/k (vim-ish) and h/l (left/right) for convenience.
      bind -n M-j previous-window
      bind -n M-k next-window
      bind -n M-h previous-window
      bind -n M-l next-window

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
      # Do not bind to plugin-provided TmuxNavigate* commands; those can be missing depending on
      # tmux/plugin versions and lead to "unknown command" warnings.
      #
      # Instead, use the plugin's recommended "if-shell is_vim" pattern. This preserves:
      #  - C-h/j/k/l inside (n)vim for split navigation
      #  - C-h/j/k/l in tmux for pane navigation
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | ${pkgs.gnugrep}/bin/grep -iqE '^[^TXZ ]+ +(.*/)?(g?view|g?n?vim?x?)(diff)?$'"

      bind -n C-h if-shell "''${is_vim}" "send-keys C-h" "select-pane -L"
      bind -n C-j if-shell "''${is_vim}" "send-keys C-j" "select-pane -D"
      bind -n C-k if-shell "''${is_vim}" "send-keys C-k" "select-pane -U"
      bind -n C-l if-shell "''${is_vim}" "send-keys C-l" "select-pane -R"
      bind -n C-\\ if-shell "''${is_vim}" "send-keys C-\\" "last-pane"

      bind -T copy-mode-vi C-h select-pane -L
      bind -T copy-mode-vi C-j select-pane -D
      bind -T copy-mode-vi C-k select-pane -U
      bind -T copy-mode-vi C-l select-pane -R

      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse
    '';
  };
}

