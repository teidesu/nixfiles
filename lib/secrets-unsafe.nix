{ pkgs, config, ... }: 

{
  readUnsafe = name: let 
    path = ../secrets + "/${name}.UNSAFE.age";
    identityPath = builtins.elemAt (
      builtins.filter (
        x: (builtins.match ".*-unsafe$" x) != null
      ) config.age.identityPaths
    ) 0;
    drv = builtins.derivation { 
      system = pkgs.system;
      name = name;
      src = path;
      builder = pkgs.writeShellScript "read-${name}.sh" ''
        ${pkgs.age}/bin/age --decrypt --identity ${identityPath} $src > $out
      '';
    };
  in builtins.readFile drv;
}