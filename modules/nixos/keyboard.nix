# QMK/VIA USB access uses upstream device rules, not world-writable hidraw nodes.
# Normal typing and the knob need no firmware flash. See docs/keyboard-r75.md.
{ pkgs, ... }:
{
  hardware.keyboard.qmk.enable = true;
  environment.systemPackages = with pkgs; [
    qmk
    via
    wev
  ];
}
