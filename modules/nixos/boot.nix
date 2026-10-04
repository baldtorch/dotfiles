# Limine is the only installed bootloader. The guide assumes a UEFI installation.
{ ... }:
{
  boot.loader = {
    limine = {
      enable = true;
      efiSupport = true;
      maxGenerations = 10;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    timeout = 5;
  };
  # Intel CPU + AMD GPU: CPU microcode must match Intel, not the graphics vendor.
  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelModules = [ "kvm-intel" ];
  # Keep the stable release's default kernel. No speculative scheduler parameters.
}
