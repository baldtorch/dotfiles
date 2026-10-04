-- Minimal fast desktop. See keybindings.lua for Omarchy-compatible window controls.
local config_dir = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local state_dir = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
hl.config({
  general = {
    gaps_in = 4, gaps_out = 8, border_size = 2,
    layout = "dwindle", resize_on_border = true,
    col = { active_border = "rgb(a9c7ff)", inactive_border = "rgb(44474e)" },
  },
  decoration = {
    rounding = 6, active_opacity = 1.0, inactive_opacity = 1.0,
    blur = { enabled = false }, shadow = { enabled = false },
  },
  animations = { enabled = false }, -- Turn on if you prefer motion over minimum latency.
  dwindle = { preserve_split = true },
  input = { follow_mouse = 1, repeat_rate = 35, repeat_delay = 300 },
  misc = { disable_hyprland_logo = true, disable_splash_rendering = true },
})
dofile(config_dir .. "/hypr/monitors.lua")
dofile(config_dir .. "/hypr/keybindings.lua")
-- Color generation is atomic; fallback colors above work even before first login.
local theme = state_dir .. "/rice/current/hyprland.lua"
local file = io.open(theme, "r")
if file then file:close(); dofile(theme) end
