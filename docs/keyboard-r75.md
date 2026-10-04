# Royal Kludge R75 — wired ANSI

This setup targets your **wired ANSI R75**, using the US layout and Windows mode.
Normal typing and media keys work through standard Linux USB HID input. QMK is keyboard
firmware; it is not a special NixOS typing driver. The configuration does not flash or
replace your keyboard firmware.

## Windows key and volume knob

`SUPER` in `home/desktop/keybindings.lua` is the Windows key. Use the keyboard's Windows
mode and make sure Windows-key lock is off. Use the mode/key-lock combination from the
manual for your exact hardware revision; do not assume instructions for the wireless R75
or R75 Pro apply.

The expected knob behavior is:

| Knob action | Expected event | Configured action |
|---|---|---|
| Turn clockwise | `XF86AudioRaiseVolume` | Increase default output volume by 5%, capped at 100% |
| Turn counterclockwise | `XF86AudioLowerVolume` | Decrease volume by 5% |
| Press knob | `XF86AudioMute` | Toggle mute |

These volume bindings work while locked. The regular media keys control MPRIS players
through `playerctl`.

After installation, open `wev` in a terminal, focus its event window and turn/press the
knob. Hyprland may consume already-bound events; if they do not appear in `wev`, use
`sudo libinput debug-events` from a temporary `nix shell nixpkgs#libinput` or temporarily
remove the relevant binding and rebuild. Observe keyboard identifiers with `lsusb` and
`hyprctl devices`. Check audio independently:

```bash
wpctl status
wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

If manually changing audio works but the knob does not, inspect the event mapping before
changing PipeWire. If the knob controls RGB brightness instead, change its mode/mapping
using the exact keyboard's manual/VIA definition.

## VIA and QMK access

`modules/nixos/keyboard.nix` enables NixOS's QMK device rules and installs `qmk`, `via`,
and `wev`. Launch the packaged desktop VIA app; Firefox does not provide VIA's WebHID
workflow. The packaged application still needs compatible firmware and, for some R75
revisions, the manufacturer's matching JSON definition.

Get the definition/manual from [Royal Kludge's downloads](https://rkgamingstore.com/pages/software).
Match **wired ANSI R75** and the USB VID:PID/hardware revision; do not load an ISO,
wireless or Pro firmware just because it has a similar name. Back up/export your VIA
layout before editing. Set encoder clockwise/counterclockwise/press actions to Volume Up,
Volume Down and Mute if the firmware exposes those controls.

If a device is not accessible:

1. Replug it after changing device rules and log in to the active local desktop session.
2. Inspect `lsusb` and `udevadm info /dev/hidrawN` for the matching device.
3. Check whether upstream QMK rules include its VID/PID. If not, add a narrowly scoped
   `services.udev.extraRules` entry with `TAG+="uaccess"` for that confirmed VID/PID.
   Do not make all hidraw devices world writable and do not run VIA as root.

No particular R75 bootloader sequence or firmware binary is bundled: a wired ANSI label
alone is insufficient to identify every board revision. Standard knob functionality is
the first-boot acceptance test; firmware changes are a separate optional task.
