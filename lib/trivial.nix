{ pkgs, ... }@inputs:

{
  storeDirectory = dir:
    let
      dirName = builtins.baseNameOf dir;
      drv = derivation {
        name = dirName;
        src = dir;
        builder = pkgs.writeShellScript "builder.sh" ''
          ${pkgs.coreutils}/bin/mkdir -p $out/${dirName}
          for i in $(${pkgs.coreutils}/bin/ls -A $src); do
            ${pkgs.coreutils}/bin/cp -rf $src/$i $out/${dirName}
          done
        '';
        system = pkgs.system;
      };
    in
    "${drv}/${dirName}";
  
  yaml2json = file: pkgs.runCommand "yaml2json" { buildInputs = [ pkgs.yq ]; } ''
    yq -j < ${file} > $out
  '';
}
