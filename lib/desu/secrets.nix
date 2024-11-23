{ config, pkgs, lib, ... }:

{
  options = with lib; {
    desu.readUnsafeSecret = mkOption { type = types.anything; };
    desu.secrets = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          path = mkOption {
            type = types.str;
            default = config.age.secrets.${name}.path;
          };

          unsafe = mkOption {
            type = types.bool;
            default = false;
          };

          mode = mkOption {
            type = types.str;
            default = "0400";
          };
          owner = mkOption {
            type = types.str;
            default = "0";
          };
          group = mkOption {
            type = types.str;
            default = "0";
          };
        };
      }));
    };
  };

  config = {
    desu.readUnsafeSecret = name: let 
      identityPath = ../../secrets/unsafe.key;

      path = ../../secrets + "/UNSAFE.${name}.age";
      drv = builtins.derivation { 
        system = pkgs.system;
        name = name;
        src = path;
        builder = pkgs.writeShellScript "read-${name}.sh" ''
          ${pkgs.age}/bin/age --decrypt --identity ${identityPath} $src > $out
        '';
      };
    in builtins.readFile drv;

    age.secrets = builtins.listToAttrs (
      map (name: let 
        cfg = config.desu.secrets.${name};
      in {
        # unsafe secrets are handled at build-time
        name = if cfg.unsafe then null else name;
        value = {
          file = ../../secrets + "/${name}.age";
          owner = cfg.owner;
          group = cfg.group;
          mode = cfg.mode;
        };
      }) (builtins.attrNames config.desu.secrets)
    );
  };
}