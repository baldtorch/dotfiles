# RX 6600 XT: kernel AMDGPU + Mesa/RADV accelerate Hyprland and Vulkan games.
# ROCm is NOT the compositor driver. Never set software rendering or NVIDIA variables.
{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = with pkgs; [
    mesa-demos
    vulkan-tools
    libva-utils
  ];
  # This CPU has no iGPU; Hyprland automatically selects the Radeon DRM device.
  # Avoid unstable /dev/dri/card0 overrides.
}
