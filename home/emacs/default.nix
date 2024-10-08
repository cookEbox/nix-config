{ config, pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.magit
      epkgs.evil
      epkgs.gruvbox-theme
      epkgs.evil-surround
      epkgs.evil-nerd-commenter
      epkgs.evil-goggles
      epkgs.evil-matchit
      epkgs.evil-numbers
      epkgs.evil-visualstar
      epkgs.evil-collection
      epkgs.smex
    ];
    extraConfig = ''

      (require 'package)
      (package-initialize)

      ;; Theme and relative numbers
      (setq display-line-numbers-type 'relative)
      (global-display-line-numbers-mode)
      (load-theme 'gruvbox-dark-hard t)

      ;; Evil mode and other packages
      (require 'evil-collection)
      (evil-collection-init)
      (require 'evil)
      (evil-mode 1)
      (require 'evil-goggles)
      (evil-goggles-mode)
      (require 'evil-matchit)
      (global-evil-matchit-mode 1)
      (require 'evil-nerd-commenter)
      (define-key evil-normal-state-map (kbd "gc") 'evilnc-comment-or-uncomment-lines)
      (require 'evil-numbers)
      (define-key evil-normal-state-map (kbd "C-c +") 'evil-numbers/inc-at-pt)
      (define-key evil-normal-state-map (kbd "C-c -") 'evil-numbers/dec-at-pt)
      (require 'evil-surround)
      (global-evil-surround-mode 1)
      (require 'evil-visualstar)
      (global-evil-visualstar-mode)

      ;; Enable Evil mode in wdired
      (add-hook 'wdired-mode-hook 'evil-normal-state)
      (add-hook 'wdired-mode-exit-hook 'evil-normal-state)

      ;; ;; Source .zshrc 
      ;; (defadvice async-shell-command (before async-shell-command-with-zshrc activate)
      ;; (setq command (concat "source ~/.zshrc && " command)))

      ;; (defadvice shell-command (before shell-command-with-zshrc activate)
      ;; (setq command (concat "source ~/.zshrc && " command)))

      (require 'smex)
      (smex-initialize)
      (global-set-key (kbd "M-x") 'smex)

      (ido-mode 1)
      (setq ido-enable-flex-matching 1)
      (setq ido-everywhere 1)
      
    '';
 
  };
}

