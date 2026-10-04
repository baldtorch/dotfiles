# Enter with `nix develop .#c-cpp`. Tool versions come from flake.lock.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    gcc
    gnumake
    cmake
    ninja
    pkg-config
    clang-tools
    gdb
  ];
}
