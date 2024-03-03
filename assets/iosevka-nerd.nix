let 
  pkgs = import <nixpkgs> {};
  nerdify = { font, args ? "--complete" }:
    pkgs.stdenvNoCC.mkDerivation {
      name = "${font.name}-nerd";
      src = pkgs.fetchzip {
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FontPatcher.zip";
        hash = "sha256-H2dPUs6HVKJcjxy5xtz9nL3SSPXKQF3w30/0l7A0PeY=";
        stripRoot = false;
      };
      buildInputs = with pkgs; [
        argparse
        fontforge
        (python3.withPackages (ps: with ps; [ setuptools fontforge ]))
      ];
      buildPhase = ''
        font_regexp='.*\.\(ttf\|ttc\|otf\|dfont\)'
        find -L ${font} -regex "$font_regexp" -type f -print0 | while IFS= read -rd "" f_; do
          f=$(basename "$f_")
          echo "nerdifying $f"
          mkdir -p $out/$f
          fontforge -script $src/font-patcher "$f_" ${args} -out $out/$f -q
        done
      '';
      installPhase = ''
        set -eaux
        # fontforge tends to spit out a lot of files with the same name
        # so we need to move them to a unique location
        for f in $out/*; do
          if [ -d "$f" ]; then
            for g in $f/*; do
              mv "$g" "$out/$(basename "$f")-$(basename "$g")"
            done
            rm -r "$f"
          fi
        done
      '';
    };
in nerdify {
  font = pkgs.fetchzip {
    url = "https://github.com/be5invis/Iosevka/releases/download/v28.1.0/PkgTTC-IosevkaSS05-28.1.0.zip";
    hash = "sha256-IOk0+Ha/FG29jIBr2+7Rx89TbnvK9ngx7gAFr5VfBpU=";
    stripRoot = false;
  };
}