# Nix and OS defaults. stateVersion is the FIRST installation release, not an update knob.
{ pkgs, settings, ... }:
{
  system.stateVersion = "26.05";
  networking.hostName = settings.hostname;
  time.timeZone = settings.timezone;
  i18n.defaultLocale = settings.locale;
  console.keyMap = "us";
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    # Bound parallel builds for this 16 GB desktop. Raise only if RAM allows.
    max-jobs = 2;
    cores = 8;
  };
  # Keep rollback generations until you intentionally clean them up.
  nix.gc.automatic = false;
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    neovim
    pciutils
    usbutils
    jq
  ];
  programs.nix-ld.enable = true; # Compatibility loader for occasional downloaded binaries.
  services.fstrim.enable = true;
}
