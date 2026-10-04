# Validate the actual generated Lua with the pinned compositor, without starting a session.
{
  pkgs,
  home,
  theme,
}:
pkgs.runCommand "hyprland-config-check"
  {
    nativeBuildInputs = [
      pkgs.hyprland
      pkgs.lua
      theme
    ];
  }
  ''
    export XDG_CONFIG_HOME="$TMPDIR/config"
    export XDG_STATE_HOME="$TMPDIR/state"
    export XDG_CACHE_HOME="$TMPDIR/cache"
    export XDG_RUNTIME_DIR="$TMPDIR/runtime"
    mkdir -p "$XDG_CONFIG_HOME/hypr" "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
    cp ${
      pkgs.writeText "hyprland.lua" home.xdg.configFile."hypr/hyprland.lua".text
    } "$XDG_CONFIG_HOME/hypr/hyprland.lua"
    cp ${
      pkgs.writeText "monitors.lua" home.xdg.configFile."hypr/monitors.lua".text
    } "$XDG_CONFIG_HOME/hypr/monitors.lua"
    cp ${../home/desktop/keybindings.lua} "$XDG_CONFIG_HOME/hypr/keybindings.lua"
    for file in "$XDG_CONFIG_HOME"/hypr/*.lua; do luac -p "$file"; done
    rice-theme init --no-reload
    Hyprland --verify-config --config "$XDG_CONFIG_HOME/hypr/hyprland.lua"
    touch "$out"
  ''
