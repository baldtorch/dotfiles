# Enter with `nix develop .#java`. Tool versions come from flake.lock.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    jdk
    maven
    gradle
  ];
}
