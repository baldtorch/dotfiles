# Fontconfig defaults apply system-wide; applications may explicitly choose another font.
{ pkgs, settings, ... }:
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          settings.font
          "Noto Serif"
        ];
        sansSerif = [
          settings.font
          "Noto Sans"
        ];
        monospace = [ settings.font ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
