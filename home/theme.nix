# Immutable app configuration imports colors from mutable ~/.local/state/rice/current.
# `rice-theme apply PATH` changes the wallpaper and palette; `rice-theme refresh` re-renders.
{
  config,
  pkgs,
  settings,
  ...
}:
let
  theme = (import ../packages { inherit pkgs; }).rice-theme;
  colors = "${config.xdg.stateHome}/rice/current";
in
{
  home.packages = [
    theme
    pkgs.swaybg
    pkgs.qt6Packages.qt6ct
    pkgs.libsForQt5.qt5ct
  ];
  xdg.configFile."rice/settings.json".text = builtins.toJSON {
    inherit (settings) font fontSize;
  };
  gtk = {
    enable = true;
    font = {
      name = settings.font;
      size = settings.fontSize;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraCss = ''@import url("${colors}/gtk.css");'';
    gtk4.extraCss = ''@import url("${colors}/gtk.css");'';
  };
  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };
  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    # Qt apps read this palette on startup. Change theme.nix to customize it.
    [Appearance]
    color_scheme_path=${colors}/qt.colors
    custom_palette=true
    icon_theme=Papirus-Dark
    style=Fusion
    [Fonts]
    fixed="${settings.font},${toString settings.fontSize},-1,5,50,0,0,0,0,0"
    general="${settings.font},${toString settings.fontSize},-1,5,50,0,0,0,0,0"
  '';
  xdg.configFile."qt5ct/qt5ct.conf".text = config.xdg.configFile."qt6ct/qt6ct.conf".text;
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    font-name = "${settings.font} ${toString settings.fontSize}";
    monospace-font-name = "${settings.font} ${toString settings.fontSize}";
  };
  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };
  # Initialize colors before any service tries to import its generated configuration.
  systemd.user.services.rice-theme-init = {
    Unit = {
      Description = "Initialize wallpaper-derived colors";
      Before = [
        "waybar.service"
        "mako.service"
        "rice-wallpaper.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${theme}/bin/rice-theme init --no-reload";
      RemainAfterExit = true;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  systemd.user.services.rice-wallpaper = {
    Unit = {
      Description = "Static wallpaper (no animation loop)";
      After = [
        "graphical-session.target"
        "rice-theme-init.service"
      ];
      Requires = [ "rice-theme-init.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${colors}/wallpaper -m fill";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  # Reload border colors after the first palette is generated in a new session.
  systemd.user.services.rice-colors = {
    Unit = {
      Description = "Load wallpaper colors into Hyprland";
      After = [
        "graphical-session.target"
        "rice-theme-init.service"
      ];
      Requires = [ "rice-theme-init.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.hyprland}/bin/hyprctl reload";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
