# The CLI version is pinned by flake.lock. Run `codex login` after installation.
# Do not manage ~/.codex/auth.json in Nix: Nix store contents are not secret.
{ pkgs, ... }: { home.packages = [ pkgs.codex ]; }
