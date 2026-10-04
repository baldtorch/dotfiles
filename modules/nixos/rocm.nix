# RX 6600 XT is gfx1032; tools being installed does not establish framework support.
# Keep experimental GPU overrides local to a single program (see docs/gaming-rocm.md).
{
  lib,
  pkgs,
  settings,
  ...
}:
{
  environment.systemPackages = lib.optionals settings.enableRocm (
    with pkgs.rocmPackages;
    [
      rocminfo
      rocm-smi
      hipcc
    ]
  );
  # render/video access is declared in users.nix; do not chmod /dev/kfd globally.
}
