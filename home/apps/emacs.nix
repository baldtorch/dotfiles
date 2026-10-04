# PGTK Emacs is native Wayland; init.el contains the readable editor setup.
{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };
  xdg.configFile."emacs/init.el".source = ./emacs/init.el;
}
