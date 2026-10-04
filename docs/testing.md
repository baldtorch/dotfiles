# Testing and acceptance

There are three distinct levels: evaluation, building, and actual hardware/runtime tests.
A successful first level does not imply the others passed.

## Before wiping Arch

Use Nix on x86_64 Linux with `nix-command` and `flakes` enabled. No command in this section
activates the configuration or formats disks.

```bash
# From the checkout; stage new files so Git-backed flakes include them.
git add .
nix develop -c bash -c 'git ls-files "*.nix" -z | xargs -0 nixfmt --check'
nix build .#checks.x86_64-linux.system-evaluation --no-link
nix build .#checks.x86_64-linux.theme --no-link -L
nix build .#checks.x86_64-linux.hyprland --no-link -L
nix develop -c bash -c 'git ls-files "*.lua" -z | xargs -0 -n1 luac -p'
```

The `system-evaluation` check forces the complete system derivation using fake mounts.
The theme check runs real Matugen extraction, tests filenames with spaces/quotes,
persistence after deleting the original image, and preserving a working theme after a
bad image. The Hyprland check loads the actual generated Lua and palette using the pinned
compositor's `--verify-config` mode; it does not start a desktop session.

The optional full build is much larger (roughly 20 GB unpacked at the initial pin):

```bash
nix build .#nixosConfigurations.check.config.system.build.toplevel --no-link -L
```

**Never install the `check` host.** Its root and EFI paths are fake. A VM build from this
host is not provided as a validated disk/boot test. The production `workstation` output
intentionally fails until you generate hardware and set `hardwareReady = true`.

## After generating real hardware, before installation/activation

```bash
nix flake check
nix build .#nixosConfigurations.workstation.config.system.build.toplevel
# On an already installed NixOS system:
nixos-rebuild build --flake .#workstation
sudo nixos-rebuild dry-activate --flake .#workstation
sudo nixos-rebuild test --flake .#workstation
```

Review `/` and `/boot` UUIDs and the LUKS mapping separately. A build cannot check whether
you chose the correct physical disk. On the live USB, `nixos-install --flake ...` installs
the target; `nixos-rebuild test` is for the installed NixOS system.

## First boot on the hardware

```bash
# General boot/service health
systemctl --failed
systemctl --user --failed
journalctl -b -p err
findmnt / /boot
lsblk -f

# Compositor and Radeon graphics
hyprctl configerrors
hyprctl monitors all
hyprctl systeminfo
vulkaninfo --summary
glxinfo -B

# Audio and keyboard
wpctl status
wev

# UI and palette
fc-match 'JetBrainsMono Nerd Font'
rice-theme apply /etc/nixos/assets/default-wallpaper.png
systemctl --user status rice-theme-init rice-wallpaper waybar mako

# Development tools
java -version
gcc --version
g++ --version
go version
rustc --version
cargo --version
node --version
bun --version

# Compute/virtualization
rocminfo
rocm-smi
hipcc --version
ls -l /dev/kvm
vm-curator --help
```

Manually confirm:

- Limine boots the encrypted SATA installation, prompts for its passphrase and offers
  retained generations. The NVMe partitions remain intact.
- The greeter accepts your user password; Super+Enter opens Foot; Super+Space opens Rofi.
- Focus, swap, workspace, scratchpad, fullscreen and resize shortcuts behave as documented.
- The wired ANSI R75 types correctly, Windows/Super works, and turning/pressing the knob
  changes volume/mute. Lock the screen and verify the volume binding there too.
- Waybar is at the top. Apply two differently colored images and inspect borders, bar,
  Rofi and Mako; open a new terminal; check GTK/Qt applications after restarting them.
- Print takes a region screenshot and copies it. Browser screen sharing can select a
  screen/window through the Hyprland portal.
- Audio output, microphone, network, Bluetooth (if used), idle lock and display wake work.
- Firefox, Emacs, Neovim, VS Code, cliamp and Codex start. Run `codex login` separately.
- Steam launches a game using the Radeon Vulkan driver; optionally test Proton-GE.
- Test a real compute workload if you need ROCm; `rocminfo` alone is insufficient.
- A small QEMU VM can use KVM. VM images stay outside Git.

After a proven boot, record the commit ID and test selecting a retained generation from
Limine before performing aggressive cleanup.

## Validation record

See the repository's latest CI run and the delivery notes for checks actually performed.
The initial preparation was done on Arch using an isolated portable Nix store; it did not
activate NixOS, modify the running desktop, format disks, or flash keyboard firmware.
Physical Limine boot, ROCm workloads, audio/knob behavior and games remain first-boot tests.
