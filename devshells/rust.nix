# Enter with `nix develop .#rust`. Tool versions come from flake.lock.
{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    pkg-config
    openssl
  ];
}
