# Enter with `nix develop .#javascript`. Tool versions come from flake.lock.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    nodejs
    bun
    nodePackages.typescript-language-server
  ];
}
