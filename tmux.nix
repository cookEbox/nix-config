{ config, pkgs, lib, ... } :

{
  programs.tmux = {
    enable = true;
    shortcut = "q";
    escapeTime = 10;
    keyMode = "vi";
    terminal = "tmux-256color";
    historyLimit = 50000;

    extraConfig = ''
      unbind C-q
      unbind q
      set-option -g prefix C-s
      bind s send-prefix
      bind C-s last-window

      set-option -g status-position top
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
       
      bind -n S-Left previous-window
      bind -n S-Right next-window
       
      setw -g mouse on
       
      bind-key v split-window -h
      bind-key h split-window -v
       
      bind-key r source-file ~/.tmux.conf \; display-message "~/.tmux.conf reloaded."
      '';
  };
}
