# Home Manager owns user configuration; edit this repository, not generated symlinks.
{ settings, ... }:
{
  imports = [
    ./packages.nix
    ./shell.nix
    ./theme.nix
    ./desktop/hyprland.nix
    ./desktop/keybindings.nix
    ./desktop/monitors.nix
    ./desktop/waybar.nix
    ./desktop/launcher.nix
    ./desktop/notifications.nix
    ./desktop/lock-idle.nix
    ./apps/terminal.nix
    ./apps/firefox.nix
    ./apps/emacs.nix
    ./apps/neovim.nix
    ./apps/vscode.nix
    ./apps/codex.nix
    ./apps/cliamp.nix
  ];
  home = {
    username = settings.username;
    homeDirectory = "/home/${settings.username}";
    stateVersion = "26.05"; # Leave unchanged during routine upgrades.
  };
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
