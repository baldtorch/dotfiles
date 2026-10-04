# Rollback and recovery

## A bad activation, but the system is still usable

Open a TTY (Ctrl+Alt+F3) if the desktop is broken, log in, and run:

```bash
sudo nixos-rebuild switch --rollback
```

This selects the previous system profile. Reboot for a kernel/boot change. Home Manager
is integrated into the system rebuild, but mutable application data and wallpaper state
are not rolled back. Revert the corresponding Git edit before the next normal rebuild,
or you will reintroduce the bad configuration.

To choose a specific retained generation:

```bash
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
# Replace 42 with a retained, known-good generation number.
sudo nix-env -p /nix/var/nix/profiles/system --switch-generation 42
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

Alternatively, check out a known-good Git commit (including its lockfile), inspect it,
and rebuild. A Git revision may need to download/build missing paths again.

## A bad boot

Reboot, enter the Limine menu and choose a previous NixOS generation. Once logged in,
select the desired generation persistently with the commands above. Boot-menu rollback
requires that the old generation and its boot files have been retained.

## Recover from a minimal installer USB

Boot in UEFI mode, connect networking, identify the existing SATA partitions by their
actual disk ID/UUID, and **mount them without formatting**:

```bash
sudo -i
lsblk -f
cryptsetup open /dev/disk/by-uuid/YOUR_LUKS_UUID cryptroot
mount /dev/mapper/cryptroot /mnt
mount --mkdir /dev/disk/by-uuid/YOUR_EFI_FILESYSTEM_UUID /mnt/boot
nixos-enter --root /mnt
```

Inside the installed system:

```bash
cd /etc/nixos
git status
# Repair an edit or restore a known-good revision without discarding uncommitted work.
# If your installed nixos-rebuild supports it, rebuild the repaired configuration:
nixos-rebuild boot --flake .#workstation
# If the bootloader itself needs reinstalling:
nixos-rebuild boot --install-bootloader --flake .#workstation
```

Do not reset/reformat the NVMe. If an EFI firmware blocks variable writes, consult the
Limine/NixOS EFI documentation before changing `canTouchEfiVariables` or removable-media
installation options. The standard setup intentionally does not force unsafe bootloader
writes. For a lost repository, clone the known-good Git revision elsewhere and restore
or regenerate hardware declarations for the mounted existing disks.

If rebuilding is unavailable but old generations remain, list profiles under
`/nix/var/nix/profiles/` and select a known-good generation as above, using its
`switch-to-configuration boot` action while in recovery. Exit the recovery shell,
unmount, close the LUKS mapping and reboot.

## Desktop services and theme

```bash
systemctl --user --failed
journalctl --user -b -u rice-theme-init -u rice-wallpaper -u waybar -u mako
hyprctl configerrors
rice-theme refresh
```

To return to the bundled wallpaper, apply `assets/default-wallpaper.png` from the checkout.
A stopped service is not started by `rice-theme`'s reload step (`try-restart`); use
`systemctl --user restart waybar mako rice-wallpaper` once the palette is valid.
