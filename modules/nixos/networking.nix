# nmcli/nmtui handle both wired and wireless connections. No incoming ports by default.
{ ... }:
{
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  services.openssh.enable = false; # Opt in when remote login is actually needed.
}
