# Keep bindings in readable Lua; they do not call any Arch/Omarchy scripts.
{ ... }: { xdg.configFile."hypr/keybindings.lua".source = ./keybindings.lua; }
