{ 
  age, 
  writeShellScript, 
  system,
  stdenv,
  ...
}: 

{
  readUnsafe = name: let 
    isDarwin = stdenv.isDarwin;
    identityPath = if isDarwin then "/Users/Shared/agenix-key-unsafe" else "/etc/ssh/agenix-key-unsafe";

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