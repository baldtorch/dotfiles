# Enter with `nix develop .#go`. Tool versions come from flake.lock.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    go
    gopls
  ];
}
