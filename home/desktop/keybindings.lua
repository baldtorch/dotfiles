-- SUPER is the Windows key. Essential Omarchy controls, expressed in native Hyprland.
local function bind(keys, description, dispatcher, options)
  options = options or {}
  options.description = description
  hl.bind(keys, dispatcher, options)
end
bind("SUPER + W", "Close window", hl.dsp.window.close())
bind("SUPER + J", "Toggle split", hl.dsp.layout("togglesplit"))
bind("SUPER + P", "Pseudo tile", hl.dsp.window.pseudo())
bind("SUPER + T", "Float / tile", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + F", "Fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind("SUPER + ALT + F", "Maximize within work area", hl.dsp.window.fullscreen({ mode = "maximized" }))
for key, direction in pairs({ LEFT = "l", RIGHT = "r", UP = "u", DOWN = "d" }) do
  bind("SUPER + " .. key, "Focus " .. direction, hl.dsp.focus({ direction = direction }))
  bind("SUPER + SHIFT + " .. key, "Swap " .. direction, hl.dsp.window.swap({ direction = direction }))
  bind("SUPER + SHIFT + ALT + " .. key, "Move workspace to monitor " .. direction,
    hl.dsp.workspace.move({ monitor = direction }))
end
for n = 1, 10 do
  local key = "code:" .. tostring(n + 9) -- Physical number row, with 0 as workspace 10.
  bind("SUPER + " .. key, "Workspace " .. n, hl.dsp.focus({ workspace = tostring(n) }))
  bind("SUPER + SHIFT + " .. key, "Move to workspace " .. n, hl.dsp.window.move({ workspace = tostring(n) }))
  bind("SUPER + SHIFT + ALT + " .. key, "Move silently to workspace " .. n,
    hl.dsp.window.move({ workspace = tostring(n), follow = false }))
end
bind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
bind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
bind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
bind("SUPER + S", "Scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
bind("SUPER + ALT + S", "Move to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
bind("ALT + TAB", "Next window", hl.dsp.window.cycle_next())
bind("ALT + SHIFT + TAB", "Previous window", hl.dsp.window.cycle_next({ next = false }))
bind("ALT + TAB", "Raise window", hl.dsp.window.bring_to_top())
bind("ALT + SHIFT + TAB", "Raise window", hl.dsp.window.bring_to_top())
bind("CTRL + ALT + TAB", "Next monitor", hl.dsp.focus({ monitor = "+1" }))
bind("CTRL + ALT + SHIFT + TAB", "Previous monitor", hl.dsp.focus({ monitor = "-1" }))
bind("SUPER + mouse_down", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
bind("SUPER + mouse_up", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
bind("SUPER + mouse:272", "Drag window", hl.dsp.window.drag(), { mouse = true })
bind("SUPER + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })
-- Same physical minus/equal keys as Omarchy; Shift resizes vertically.
for _, item in ipairs({
  { "SUPER + code:20", -100, 0 }, { "SUPER + code:21", 100, 0 },
  { "SUPER + SHIFT + code:20", 0, -100 }, { "SUPER + SHIFT + code:21", 0, 100 },
}) do
  bind(item[1], "Resize window", hl.dsp.window.resize({ x = item[2], y = item[3], relative = true }), { repeating = true })
end
-- Essential launchers. Super+Space opens Rofi in place of the Omarchy menu.
bind("SUPER + RETURN", "Terminal", hl.dsp.exec_cmd("uwsm app -- foot"))
bind("SUPER + SHIFT + RETURN", "Browser", hl.dsp.exec_cmd("uwsm app -- firefox"))
bind("SUPER + SHIFT + F", "Files", hl.dsp.exec_cmd("uwsm app -- thunar"))
bind("SUPER + SPACE", "Applications", hl.dsp.exec_cmd("rofi -show drun"))
bind("SUPER + CTRL + SPACE", "Wallpaper", hl.dsp.exec_cmd("rice-theme choose"))
bind("SUPER + ESCAPE", "Lock screen", hl.dsp.exec_cmd("loginctl lock-session"))
bind("SUPER + SHIFT + SPACE", "Toggle bar", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
bind("PRINT", "Region screenshot to clipboard", hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | wl-copy']]))
-- R75 knob firmware should emit these standard consumer/media events.
bind("XF86AudioRaiseVolume", "Volume up", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Volume down", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
bind("XF86AudioMute", "Mute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
bind("XF86AudioMicMute", "Mute microphone", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
for key, command in pairs({ XF86AudioPlay = "play-pause", XF86AudioPause = "play-pause", XF86AudioNext = "next", XF86AudioPrev = "previous" }) do
  bind(key, command, hl.dsp.exec_cmd("playerctl " .. command), { locked = true })
end
