# Low-overhead defaults for a 16 GB desktop; no always-on performance governor.
{ ... }:
{
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };
  services.journald.extraConfig = "SystemMaxUse=512M";
  # Do not disable security mitigations. GameMode can tune individual game sessions.
}
