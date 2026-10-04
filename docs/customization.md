# Customize the setup

Read each file's comments before editing. Most personal changes belong in
`hosts/workstation/settings.nix`, `home/desktop/` or `home/apps/`. After edits, stage new
files, build, test, then switch. Never edit files directly in `/nix/store`.

## Common changes

| Change | File |
|---|---|
| Username, timezone, keyboard layout, feature switches | `hosts/workstation/settings.nix` |
| Add/remove an application or compiler | `home/packages.nix` |
| Boot entries retained and timeout | `modules/nixos/boot.nix` |
| Monitor resolution/refresh/scale | `home/desktop/monitors.nix` |
| Windows-key shortcuts | `home/desktop/keybindings.lua` |
| Gaps, borders, rounding, animation/blur switches | `home/desktop/hyprland.lua` |
| Bar position, modules, intervals and spacing | `home/desktop/waybar.nix` |
| Launcher behavior and font | `home/desktop/launcher.nix` |
| Lock/idle timers | `home/desktop/lock-idle.nix` |
| Shared font family and size | `hosts/workstation/settings.nix` |
| Which palette colors apps use | `scripts/rice-theme.py` → `render()` |
| Which named colors Matugen extracts | `assets/palette.json.template` |
| Firefox, VS Code, Emacs, Neovim | Corresponding files under `home/apps/` |
| Add a server, printer or other service | A module under `modules/nixos/`, imported by the host |

Font changes apply through the shared settings to GTK/Qt, Foot, Rofi and notifications.
Waybar uses a separate CSS size for its compact layout, VS Code uses an editor size, and
Emacs declares its face in `init.el`; adjust those if you change the font globally.
Websites and applications with private rendering engines can ignore desktop defaults.

## Native Hyprland Lua

This flake pins Hyprland through Nixpkgs and uses its Lua API. Do not paste legacy
`bind = ...` or `windowrulev2 = ...` snippets into the Lua files. Consult the documentation
for the **installed version**, especially after updating the lockfile:
[Hyprland configuration](https://wiki.hypr.land/Configuring/Start/).

```lua
-- Example: add this to home/desktop/keybindings.lua before rebuilding.
bind("SUPER + SHIFT + E", "Emacs", hl.dsp.exec_cmd("uwsm app -- emacs"))
```

`SUPER` is the Windows key. The configuration does not use Caps Lock or Alt as a Super
replacement. If the Windows key does nothing, check Windows mode/key-lock on the keyboard
and inspect events with `wev`.

Run `hyprctl monitors all` to see connector names and modes. Use the mode the display
actually advertises; an unsupported refresh rate cannot be made to work by declaring it.
The RX 6600 XT is automatically selected on this machine; avoid hardcoding `card0`.

## Wallpaper and theme customization

Run `rice-theme apply /path/to/image.png` or place PNG/JPEG/WebP files in
`~/Pictures/Wallpapers` and use Super+Ctrl+Space. The default original artwork is committed
under `assets/` and can be regenerated with `python3 scripts/make-wallpaper.py`.

The command copies the selected image, generates Matugen's palette into a fresh directory,
validates the colors, writes app configurations, then atomically switches the `current`
symlink. Failed image decoding does not replace the working theme. Files are generated
under `~/.local/state/rice/generations/`; the newest three are retained.

Generated palette data is not part of the Nix store or Home Manager's managed files.
After changing the renderer/templates and rebuilding, run `rice-theme refresh` to
re-render the selected wallpaper. Logging in also regenerates it. For an exact visual
reproduction on another machine, copy the original wallpaper there and apply it with the
same locked configuration.

GTK/Qt palette support varies across apps. The bar, borders and notifications reload;
Rofi reads its theme on launch. New Foot windows read the new colors. Neovim updates when
focused or with `:RiceTheme`. Emacs updates with `M-x rice-refresh-theme`. VS Code and
Steam retain their own themes.

## Development shells

All requested everyday language tools are installed. Use a shell when a project needs an
explicit reproducible environment:

```bash
nix develop .#java
nix develop .#c-cpp
nix develop .#go
nix develop .#rust
nix develop .#javascript
```

For automatic activation in this repo, put `use flake .#rust` in `.envrc` and run
`direnv allow` after reviewing it. For an independent project, give that project its own
flake/lockfile instead of coupling it permanently to this desktop repository.

Neovim enables native LSP configurations for Go, Rust and C/C++. Emacs includes built-in
Eglot; start it with `M-x eglot`. Java/TypeScript language servers and additional editor
plugins are optional additions. Nix pins editor plugins declared here; project dependency
lockfiles still belong to their own projects.

## Adding another computer

Copy the host directory, generate its hardware configuration on that machine, and add a
named entry under `nixosConfigurations` in `flake.nix`. Refactor `settings` per host first
if the username or hardware differs. The existing graphics and Intel microcode modules
are deliberately specific to this desktop; do not blindly reuse them for another GPU/CPU.
