# Mako reads the generated theme directly, so Home Manager and Matugen never overwrite each other.
{ config, pkgs, ... }:
{
  home.packages = [ pkgs.mako ];
  systemd.user.services.mako = {
    Unit = {
      Description = "Notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [
        "graphical-session.target"
        "rice-theme-init.service"
      ];
      Requires = [ "rice-theme-init.service" ];
    };
    Service = {
      ExecStart = "${pkgs.mako}/bin/mako --config ${config.xdg.stateHome}/rice/current/mako.conf";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
