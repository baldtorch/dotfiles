# Top status bar: modest polling intervals keep idle CPU use low.
{ config, settings, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 8;
      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "cpu"
        "memory"
        "network"
        "pulseaudio"
        "tray"
      ];
      "hyprland/window".max-length = 40;
      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
      };
      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip-format = "{:%Y-%m-%d}";
      };
      cpu = {
        interval = 5;
        format = "CPU {usage}%";
      };
      memory = {
        interval = 5;
        format = "RAM {percentage}%";
      };
      network = {
        interval = 5;
        format-ethernet = "LAN";
        format-wifi = "{essid}";
        format-disconnected = "Offline";
        on-click = "foot -e nmtui";
      };
      pulseaudio = {
        format = "VOL {volume}%";
        format-muted = "Muted";
        on-click = "pavucontrol";
      };
      tray.spacing = 8;
    };
    style = ''
      /* Colors are generated into mutable state, never into Home Manager's symlinks. */
      @import url("${config.xdg.stateHome}/rice/current/waybar.css");
      * { font-family: "${settings.font}"; font-size: 12px; border: none; min-height: 0; }
      window#waybar { background: @surface; color: @on_surface; }
      #workspaces button { color: @on_surface; padding: 0 9px; border-radius: 0; }
      #workspaces button.active { color: @on_primary; background: @primary; }
      #workspaces button.urgent { background: @error; }
      #clock, #cpu, #memory, #network, #pulseaudio, #tray { padding: 0 8px; }
    '';
  };
  systemd.user.services.waybar.Unit.After = [ "rice-theme-init.service" ];
  systemd.user.services.waybar.Unit.Requires = [ "rice-theme-init.service" ];
}
