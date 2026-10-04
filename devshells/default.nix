# `nix develop .#rust` selects a project toolchain without changing the OS.
{ pkgs }:
{
  default = pkgs.mkShell {
    packages = with pkgs; [
      git
      nixfmt
      nil
      lua
    ];
  };
  java = import ./java.nix { inherit pkgs; };
  c-cpp = import ./c-cpp.nix { inherit pkgs; };
  go = import ./go.nix { inherit pkgs; };
  rust = import ./rust.nix { inherit pkgs; };
  javascript = import ./javascript.nix { inherit pkgs; };
}
