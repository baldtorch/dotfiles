# Install from the minimal NixOS USB

This guide installs the whole desktop directly from the **minimal installer ISO**; there
is no need to first install a minimal system and then reinstall it. A separate route for
an already installed NixOS system is at the end.

## Before wiping Arch

1. Back up your home directory, documents, SSH/GPG keys, browser data, game saves, VM images
   and any useful existing dotfiles onto another physical device. Verify you can read it.
2. Push the repository, including `flake.lock`, to
   `https://github.com/baldtorch/dotfiles`. Confirm the GitHub copy is readable.
3. Run the pre-install evaluation/theme checks in README. A full system build is strongly
   recommended before wiping. Hardware tests still require a NixOS boot.
4. Download the NixOS 26.05 **minimal x86_64 ISO** from [nixos.org/download](https://nixos.org/download/),
   verify it using the published checksums, and write it to a USB using your preferred tool.
5. Boot the USB in UEFI mode. This initial recipe does not enroll Secure Boot keys;
   disable Secure Boot for installation unless you have separately configured signing.

The inspected Arch system had a roughly **2 TB SATA disk** with an encrypted Arch root and
EFI partition, plus a separate **500 GB NVMe containing NTFS partitions**. Device names
can change in the installer. This recipe is intended to replace only the Arch disk and
preserve the NVMe. It does not repartition, mount or format the NVMe. Existing Windows can still be selected
through the firmware boot menu; a Limine Windows chainloader entry is not configured.

## 1. Network and tools

Ethernet usually works automatically. For Wi-Fi, use `sudo nmtui` if available or the
installer's documented `wpa_cli` workflow. Confirm networking before continuing.

```bash
sudo -i
# The remaining installer commands are in this root shell.
export NIX_CONFIG="experimental-features = nix-command flakes"
test -d /sys/firmware/efi || { echo 'Reboot the USB in UEFI mode'; exit 1; }
ping -c 3 nixos.org
nix shell nixpkgs#git nixpkgs#neovim nixpkgs#parted nixpkgs#cryptsetup \
  nixpkgs#dosfstools nixpkgs#e2fsprogs
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS
ls -l /dev/disk/by-id/
```

The temporary tools above use the installer's registry. The installed OS uses the
repository's committed lockfile, not that registry.

## 2. Choose and prepare the disk — destructive

**Only run this section after backups and after positively identifying the old Arch disk.**
The commands erase the selected disk. They are documentation, not an unattended install script.
Do not substitute the NVMe or the USB stick. Physically disconnecting a disk you want to
preserve is also an option.

Set a stable, actual disk ID (the example deliberately cannot work):

```bash
DISK=/dev/disk/by-id/REPLACE_WITH_THE_OLD_ARCH_DISK_ID
lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS "$DISK"
```

Check that its partitions are not mounted. Then create a 2 GiB EFI partition and root
partition. The larger ESP leaves room for retained Limine generations.

```bash
parted --script "$DISK" mklabel gpt
parted --script "$DISK" mkpart ESP fat32 1MiB 2049MiB
parted --script "$DISK" set 1 esp on
parted --script "$DISK" mkpart nixos-root 2049MiB 100%
udevadm settle
EFI="${DISK}-part1"
ROOT_PART="${DISK}-part2"
mkfs.fat -F 32 -n NIXOS_EFI "$EFI"
```

Selected layout: LUKS-encrypted ext4 root on the SATA disk, preserving the NVMe:

```bash
cryptsetup luksFormat "$ROOT_PART"
cryptsetup open "$ROOT_PART" cryptroot
mkfs.ext4 -L nixos-root /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
mount --mkdir "$EFI" /mnt/boot
```

There is no disk swap partition in this recipe. Zram is configured declaratively, and
hibernation is not configured. Encryption covers the root/home data, not the EFI partition.

## 3. Download the configuration and generate hardware

```bash
mkdir -p /mnt/etc
git clone https://github.com/baldtorch/dotfiles.git /mnt/etc/nixos
cd /mnt/etc/nixos
# For an exact reinstall, optionally check out your known-good commit/tag here.
# git checkout YOUR_KNOWN_GOOD_COMMIT
nixos-generate-config --root /mnt --dir /tmp/generated-nixos
cp /tmp/generated-nixos/hardware-configuration.nix \
  hosts/workstation/hardware-configuration.nix
nvim hosts/workstation/hardware-configuration.nix hosts/workstation/settings.nix
```

Review these details:

- `/` and `/boot` match the actual filesystems; for encrypted root, the generated
  `boot.initrd.luks.devices` references the actual LUKS UUID and correct mapping.
- Set `hardwareReady = true` **only after** reviewing this generated file.
- Set username, hostname, keyboard layout and timezone in `settings.nix`.
  Defaults are `venessa`, `workstation`, US layout and `Asia/Kolkata`.
- `home/desktop/monitors.nix` currently matches the old HDMI-A-1 1920×1080@60 configuration.
  An automatic fallback handles additional monitors.
- Do not import `/tmp/generated-nixos/configuration.nix`; `hosts/workstation/default.nix`
  already assembles this flake's system. Do not copy old Arch filesystem UUIDs.

Stage generated files because Git-backed flakes ignore files Git does not know about:

```bash
git add hosts/workstation
nix flake check
nix build .#nixosConfigurations.workstation.config.system.build.toplevel
```

The first build/download can be large, especially compilers, Steam and ROCm. If the
installer's RAM-backed overlay runs out of space, the final `nixos-install` command builds
against the target installation store. The full `nix build` above is optional in the live
USB when a pre-install full build has already passed; evaluation and hardware review are
still required. Do not update `flake.lock` during installation just to get a newer version.

## 4. Install and set passwords

```bash
nixos-install --flake /mnt/etc/nixos#workstation
# nixos-install prompts for the root password. Set your normal user's password too:
nixos-enter --root /mnt -c 'passwd venessa'
```

Replace `venessa` in the last command if you changed the username. There is no default
password and no autologin. Do not pass `--no-root-passwd` without another recovery plan.

After successful installation:

```bash
cd /
umount -R /mnt
# If using LUKS:
cryptsetup close cryptroot
reboot
```

Remove the USB. Limine should boot NixOS; enter the disk passphrase if encrypted, then log
in through the text greeter. UWSM starts Hyprland and the desktop services.

## 5. First login and Git maintenance

```bash
# Make your checkout editable without using sudo for every edit.
sudo chown -R "$USER:$(id -gn)" /etc/nixos
cd /etc/nixos
git status
# Configure your own commit identity if necessary.
git config user.name 'YOUR NAME'
git config user.email 'YOUR GIT EMAIL'
git add hosts/workstation
git commit -m 'Configure installed workstation hardware'
```

A public repository can be cloned over HTTPS without authentication. To push, provision
an SSH key in your GitHub account, then:

```bash
git remote set-url origin git@github.com:baldtorch/dotfiles.git
git push origin main
```

If you checked out a tag/commit, create or switch to an appropriate branch before pushing.
Never put a GitHub token in a remote URL, Nix file or shell history. Run `codex login`
locally when ready; its credentials are separate from this repository.

Follow [testing.md](testing.md) before deleting backups. Keep the installer USB available.

## Already installed minimal NixOS

Back up `/etc/nixos`, clone this repo to a separate directory you own, then copy the
existing `/etc/nixos/hardware-configuration.nix` into `hosts/workstation/`. Review mounts,
set `hardwareReady`, and stage the new file. For an older installation, preserve the
existing `system.stateVersion` (and Home Manager state version if it already existed).
Do not repartition or reformat anything.

```bash
nix --extra-experimental-features 'nix-command flakes' flake check
sudo nixos-rebuild build --flake .#workstation
sudo nixos-rebuild test --flake .#workstation
sudo nixos-rebuild switch --flake .#workstation
```

The first `test` can change the active session. Use a TTY and keep a recovery login open.
Limine/EFI changes require a reboot for verification; `test` alone does not test booting.
