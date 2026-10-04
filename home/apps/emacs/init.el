;;; init.el --- Small, readable Wayland Emacs setup -*- lexical-binding: t; -*-
;; Package versions come from Nix. Add packages in ../emacs.nix, not package-install.
(setq inhibit-startup-screen t
      make-backup-files nil
      auto-save-default t
      indent-tabs-mode nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(electric-pair-mode 1)
;; Inherit the system font configured by fonts.nix and theme.nix.
(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 110)
;; Built-in Eglot: M-x eglot starts a language server available in the project shell.
(add-hook 'prog-mode-hook #'show-paren-mode)
(defun rice-refresh-theme ()
  "Load the current wallpaper palette; run again after changing wallpapers."
  (interactive)
  (let* ((state (or (getenv "XDG_STATE_HOME") (expand-file-name "~/.local/state")))
         (path (expand-file-name "rice/current/palette.json" state)))
    (when (file-readable-p path)
      (let ((colors (json-parse-string (with-temp-buffer (insert-file-contents path) (buffer-string)))))
        (set-face-attribute 'default nil :background (gethash "surface" colors) :foreground (gethash "on_surface" colors))
        (set-face-attribute 'cursor nil :background (gethash "primary" colors))
        (set-face-attribute 'region nil :background (gethash "surface_container" colors))
        (set-face-attribute 'mode-line nil :background (gethash "primary" colors) :foreground (gethash "on_primary" colors))
        (set-face-attribute 'font-lock-keyword-face nil :foreground (gethash "primary" colors))
        (set-face-attribute 'font-lock-string-face nil :foreground (gethash "secondary" colors))))))
(rice-refresh-theme)
;;; init.el ends here
