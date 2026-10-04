# Firefox remains the default browser. Website fonts are intentionally not forced.
{ settings, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "font.name.monospace.x-western" = settings.font;
        "browser.shell.checkDefaultBrowser" = false;
      };
    };
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}
