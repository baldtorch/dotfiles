# Evaluation-only disk fixture; never install this host. It replaces real mounts in CI.
{ lib, ... }:
{
  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-label/EVALUATION-ONLY";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/EVALUATION-ESP";
      fsType = "vfat";
    };
  };
  boot.initrd.luks.devices = lib.mkForce { };
  swapDevices = lib.mkForce [ ];
}
