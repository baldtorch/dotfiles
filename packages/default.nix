# Local tooling is built and checked with the same pinned packages as the desktop.
{ pkgs }:
let
  rice-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "rice-theme";
    version = "1.0.0";
    # Documentation edits should not rebuild the desktop tool.
    src = pkgs.lib.fileset.toSource {
      root = ../.;
      fileset = pkgs.lib.fileset.unions [
        ../scripts/rice-theme.py
        ../assets
        ../tests/test_theme.py
      ];
    };
    nativeBuildInputs = [ pkgs.makeWrapper ];
    nativeCheckInputs = [
      pkgs.python3
      pkgs.matugen
    ];
    dontBuild = true;
    doCheck = true;
    checkPhase = ''
      export RICE_THEME_ASSETS="$PWD/assets"
      python3 -m unittest discover -s tests -p 'test_*.py' -v
    '';
    installPhase = ''
      mkdir -p "$out/bin" "$out/share/rice-theme"
      cp scripts/rice-theme.py "$out/share/rice-theme/"
      cp -r assets "$out/share/rice-theme/"
      makeWrapper ${pkgs.python3}/bin/python3 "$out/bin/rice-theme" \
        --add-flags "$out/share/rice-theme/rice-theme.py" \
        --set RICE_THEME_ASSETS "$out/share/rice-theme/assets" \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.matugen ]}
    '';
  };
in
{
  inherit rice-theme;
  default = rice-theme;
}
