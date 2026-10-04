# Main personal settings. Modules receive these through specialArgs.
{
  username = "venessa";
  hostname = "workstation";
  timezone = "Asia/Kolkata";
  locale = "en_US.UTF-8";
  keyboardLayout = "us";
  # Required after generating hardware-configuration.nix in the installer.
  # This guard prevents accidentally installing the example disk configuration.
  hardwareReady = false;
  enableGaming = true;
  enableRocm = true; # Tools only: RX 6600 XT compute support is experimental.
  enableVirtualization = true;
  font = "JetBrainsMono Nerd Font";
  fontSize = 11;
}
