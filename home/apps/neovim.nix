# Plugins are pinned with nixpkgs rather than downloaded on editor startup.
{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [ nvim-lspconfig ];
    initLua = builtins.readFile ./nvim/init.lua;
  };
}
