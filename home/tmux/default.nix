{pkgs, ... }:

{
  programs.tmux = {
    enable = true;
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

      unbind r
      bind r source-file ~/.config/tmux/tmux.conf
       
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

      bind-key X display-popup -E "tmux ls | fzf -m --prompt='Kill sessions > ' | cut -d: -f1 | xargs -r -n1 tmux kill-session -t"
      bind-key S display-popup -E 'tmux switch-client -t "$(tmux ls | fzf --prompt="Switch to session > " | cut -d: -f1)"'

      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse
      '';
  };
}
