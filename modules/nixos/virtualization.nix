# vm-curator manages QEMU directly; a permanent libvirtd daemon is unnecessary.
{
  lib,
  pkgs,
  settings,
  ...
}:
{
  environment.systemPackages = lib.optionals settings.enableVirtualization [ pkgs.qemu ];
  # KVM CPU module and group membership live in boot.nix and users.nix.
}
