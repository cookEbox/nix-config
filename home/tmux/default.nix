{ config, pkgs, lib, ... } :

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

      # set-option -g status-position top
    extraConfig = ''
      unbind C-q
      unbind q
      set-option -g prefix C-s
      bind s send-prefix
      bind C-s last-window
      set -g status off 

      bind -n C-l select-pane -L
      bind -n C-; select-pane -R
      bind -n C-j select-pane -U
      bind -n C-k select-pane -D
       
      bind -n C-J previous-window
      bind -n C-K next-window

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

      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse

      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5
      bind -r m resize-pane -Z

      '';
  };
}
