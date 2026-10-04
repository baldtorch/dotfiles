# PLACEHOLDER: replace with nixos-generate-config output AFTER mounting the target.
# Do not copy Arch UUIDs. Formatting creates new filesystem UUIDs.
# See docs/installation.md. No real filesystem or encryption key is declared here.
{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
  ];
}
