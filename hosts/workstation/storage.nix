# Keep detected filesystem/UUID/LUKS declarations in hardware-configuration.nix.
# Put deliberate mount customizations here after installation, e.g.:
# fileSystems."/".options = [ "noatime" ];
# The installation guide uses encrypted ext4 with a separate EFI partition.
{ ... }: { }
