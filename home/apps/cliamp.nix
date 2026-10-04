# Terminal music player; run `cliamp` or open a music directory in it.
# Authentication and library state remain private mutable application data.
{ pkgs, ... }: { home.packages = [ pkgs.cliamp ]; }
