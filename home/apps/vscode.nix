# Microsoft Visual Studio Code (unfree allowance is narrowly scoped in flake.nix).
{ pkgs, settings, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        golang.go
      ];
      userSettings = {
        "editor.fontFamily" = settings.font;
        "editor.fontSize" = 14;
        "terminal.integrated.fontFamily" = settings.font;
        "workbench.colorTheme" = "Default Dark Modern";
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
      };
    };
  };
}
