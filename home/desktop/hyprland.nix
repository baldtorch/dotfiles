# Lua configuration matches Hyprland 0.55 in the pinned NixOS release.
{ config, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # Installed once through the NixOS module.
    portalPackage = null;
    configType = "lua";
    systemd.enable = false; # UWSM owns graphical-session.target and session variables.
    extraConfig = builtins.readFile ./hyprland.lua;
  };
  # A polkit agent is required for GUI authentication (mounts, network settings).
  services.hyprpolkitagent.enable = true;
}
