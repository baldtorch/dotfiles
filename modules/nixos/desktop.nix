# System integration installs the same Hyprland package used by Home Manager.
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start hyprland.desktop'";
      user = "greeter";
    };
  };
  security.polkit.enable = true;
  security.pam.services.hyprlock = { };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  services.gvfs.enable = true; # Removable drives in the file manager.
  services.udisks2.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
