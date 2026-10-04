# Add ordinary user applications here; services belong in their own modules.
{
  lib,
  pkgs,
  settings,
  vmCurator,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      ripgrep
      fd
      fzf
      tree
      btop
      unzip
      zip
      p7zip
      jq
      file
      wl-clipboard
      grim
      slurp
      playerctl
      pavucontrol
      libnotify
      thunar
      networkmanagerapplet
      # Everyday compilers; per-project pinned environments are also in devshells/.
      jdk
      gcc
      gnumake
      cmake
      pkg-config
      clang-tools
      go
      gopls
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      nodejs
      bun
    ]
    ++ lib.optional settings.enableVirtualization vmCurator;
}
