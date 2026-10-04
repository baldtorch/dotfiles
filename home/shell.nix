# Bash stays familiar; direnv automatically enters trusted project Nix environments.
{ ... }:
{
  programs.bash.enable = true;
  programs.git.enable = true; # Set user.name/email locally; do not publish credentials.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.starship = {
    enable = true;
    settings.add_newline = false;
  };
  programs.fzf.enable = true;
}
