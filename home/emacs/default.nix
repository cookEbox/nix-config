{
  programs.emacs = {
    enable = true;
    useUserEmacs = true;   # Allow the use of ~/.emacs or ~/.emacs.d/init.el
    extraConfig = ''
      ;; Place any additional configuration here
      (setq display-line-numbers-type 'relative)
      (global-display-line-numbers-mode t)
      (load-theme 'gruvbox-dark-hard t)
    '';
  };
}

