# A fast native Wayland terminal. New windows pick up the current wallpaper palette.
{ config, settings, ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${settings.font}:size=${toString settings.fontSize}";
        include = "${config.xdg.stateHome}/rice/current/foot.ini";
        pad = "10x10";
      };
      scrollback.lines = 10000;
    };
  };
}
