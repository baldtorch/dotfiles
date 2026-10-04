# Maintenance, removal and cleanup

## Safe update cycle

Keep a clean Git commit before updating. From your checkout:

```bash
git status
git pull --ff-only
nix flake update
nix fmt
nix flake check
nixos-rebuild build --flake .#workstation
nix store diff-closures /run/current-system ./result
sudo nixos-rebuild dry-activate --flake .#workstation
sudo nixos-rebuild test --flake .#workstation
# Check applications and desktop before making it the boot default.
sudo nixos-rebuild switch --flake .#workstation
git add flake.lock
git commit -m 'Update pinned system dependencies'
git push
```

Commit other edited source files too. Reboot to verify kernel, initrd and Limine changes.
`test` can restart services and affect the current session; it is not an isolated preview.
Neither `test` nor `switch` replaces the running kernel until reboot.

`system.stateVersion` and `home.stateVersion` record compatibility defaults for the first
installation. **Do not bump them during ordinary updates.** To move to a later NixOS
release, read that release's notes, change Nixpkgs and Home Manager to matching release
branches, update the lockfile, build/test, and only migrate state defaults deliberately.

The flake's unfree allowlist includes Steam, Microsoft VS Code and VIA. Add another entry
only when you intentionally install another unfree package. Do not enable all unfree or
insecure packages merely to suppress an evaluation error.

## Remove packages and old configuration

1. Delete the package declaration, module import or feature switch from this repo.
2. Run `nixos-rebuild build`, then `test` and `switch`.
3. Check that the replacement works before removing personal application data.

Home Manager removes its managed links when declarations are removed. An app can leave
mutable databases, caches, profiles and downloads behind. Review those individually;
removing an app does not mean its data should be erased.

For pre-existing dotfiles that conflict with initial activation, first inspect the error,
then move only the affected file/directory to a backup. Example **on the new NixOS user
account before adopting its old configuration**:

```bash
mkdir -p ~/dotfiles-backup
# Run only for the specific existing directory that conflicts:
mv ~/.config/hypr ~/dotfiles-backup/hypr-before-nix
sudo nixos-rebuild switch --flake .#workstation
```

Choose a unique backup name if one already exists. Do not run broad `rm -rf ~/.config`
commands, and do not run the example against your active Arch session while preparing
this repository. `~/.config/omarchy` is not needed by this rice; archive it if you copied
it across and want to keep it for reference.

The flake is the source of truth. An old `/etc/nixos/configuration.nix` is ignored when
using `--flake .#workstation` unless a module explicitly imports it. Archive it and retain
its useful hardware settings before deleting it. Do not remove the current flake or
`hosts/workstation/hardware-configuration.nix`.

## Generations and garbage collection

```bash
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
# Only after you have a confirmed good boot and recovery media:
sudo nix-collect-garbage --delete-older-than 30d
# Remove old entries from the boot menu using the current declaration:
sudo nixos-rebuild boot --flake .#workstation
```

Garbage collection removes store paths only if nothing still references them. User
profiles, `result` links and development-shell roots can keep paths alive. Delete an
unneeded `result` symlink with `rm result` (only that symlink), and inspect other roots
before removing them. User profile generations require separate review/cleanup under
your own account. There is no automatic generation deletion configured.

Limine's `maxGenerations = 10` limits visible boot entries; it does not by itself delete
Nix profiles/store data. Garbage-collected generations are no longer available for
rollback. Keep at least one known-good bootable generation until the next is proven.

Nix generations do not snapshot your home directory, browser profile, databases or game
saves. Keep separate backups. A rollback also does not necessarily undo a data-format
migration performed by an application or service.

## Keep secrets private

Use SSH or GitHub's credential tooling to authenticate; never put tokens in Git remote
URLs. Codex login state lives outside this repository. Do not declare secret values in
ordinary Nix strings because the resulting Nix store paths are readable by local users.
If a credential has been exposed in chat or Git, revoke it and create a replacement.
