# Rofi supports Wayland in the pinned release. Super+Space shows desktop entries.
{
  config,
  pkgs,
  settings,
  ...
}:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "${settings.font} ${toString settings.fontSize}";
    terminal = "foot";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = false;
      display-drun = "Apps";
    };
    theme = "${config.xdg.stateHome}/rice/current/rofi.rasi";
  };
}
