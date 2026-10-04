# Your Arch config uses HDMI-A-1 at 1080p/60 Hz. Change this after `hyprctl monitors all`.
{ settings, ... }:
{
  xdg.configFile."hypr/monitors.lua".text = ''
    -- Explicit primary output plus automatic handling of additional monitors.
    hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
    hl.config({ input = { kb_layout = "${settings.keyboardLayout}" } })
  '';
}
