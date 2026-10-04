# Passwords are set interactively during installation; never commit a password/hash.
{ lib, settings, ... }:
{
  users.users.${settings.username} = {
    isNormalUser = true;
    description = settings.username;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "render"
    ]
    ++ lib.optional settings.enableVirtualization "kvm";
  };
}
