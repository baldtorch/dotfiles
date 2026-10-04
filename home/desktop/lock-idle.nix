# Lock after ten minutes; turn displays off after fifteen. No automatic desktop suspend.
{ config, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;
      background = [
        {
          monitor = "";
          path = "${config.xdg.stateHome}/rice/current/wallpaper";
          blur_passes = 0;
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "300, 55";
          position = "0, -80";
          placeholder_text = "Password";
        }
      ];
    };
  };
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = ''hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' '';
      };
      listener = [
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = ''hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' '';
          on-resume = ''hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' '';
        }
      ];
    };
  };
}
