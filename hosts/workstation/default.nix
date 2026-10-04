# This host combines hardware, system modules and the user configuration.
{ settings, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/graphics-amd.nix
    ../../modules/nixos/rocm.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/keyboard.nix
    ../../modules/nixos/virtualization.nix
    ../../modules/nixos/performance.nix
  ];
  assertions = [
    {
      assertion = settings.hardwareReady;
      message = "Generate hosts/workstation/hardware-configuration.nix on the mounted target and set hardwareReady = true. See docs/installation.md. Use the check host only for validation.";
    }
  ];
}
