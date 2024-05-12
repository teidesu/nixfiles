{ 
  age, 
  writeShellScript, 
  system,
  ...
}: 

{
  readUnsafe = name: let 
    identityPath = ../secrets/unsafe.key;

    path = ../secrets + "/UNSAFE.${name}.age";
    drv = builtins.derivation { 
      system = system;
      name = name;
      src = path;
      builder = writeShellScript "read-${name}.sh" ''
        ${age}/bin/age --decrypt --identity ${identityPath} $src > $out
      '';
    };
  in builtins.readFile drv;
}