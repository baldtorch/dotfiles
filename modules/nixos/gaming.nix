# Enable Steam's NixOS runtime. Choose Proton per game in Steam > Compatibility.
{
  lib,
  pkgs,
  settings,
  ...
}:
{
  programs.steam = lib.mkIf settings.enableGaming {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    # Remote Play/LAN hosting firewall openings remain opt-in.
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };
  programs.gamemode.enable = settings.enableGaming;
  environment.systemPackages = lib.optionals settings.enableGaming [ pkgs.mangohud ];
}
