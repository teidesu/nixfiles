{ config, lib, pkgs, ... }:

{
  # todo: ideally we should support multiple encrypted directories
  options.services.gocryptfs = with lib; {
    enable = mkEnableOption "gocryptfs";
    package = mkOption {
      type = types.package;
      default = pkgs.gocryptfs;
      defaultText = "pkgs.gocryptfs";
      description = "gocryptfs package";
    };
    serviceName = mkOption {
      type = types.str;
      default = "gocryptfs";
      description = "gocryptfs service name";
    };

    passwordFile = mkOption {
      type = types.str;
      description = "path to the file containing the password";
    };

    cipherDir = mkOption {
      type = types.str;
      description = "path to the directory used as the underlying encrypted storage";
    };

    mountPoint = mkOption {
      type = types.str;
      description = "gocryptfs mount point";
    };

    extraInitOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "additional options to pass to gocryptfs -init";
    };
    
    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "additional options to pass to gocryptfs mount";
    };
  };

  config = let 
    cfg = config.services.gocryptfs;
  in lib.mkIf cfg.enable {
    systemd.services.${cfg.serviceName} = {
      description = "${cfg.serviceName} daemon";
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package ];
      serviceConfig = {
        User = "root";
        Group = "root";
      };
      script = ''
        set -euo pipefail

        if [ ! -d ${lib.escapeShellArg cfg.cipherDir} ]; then
          echo "gocryptfs: directory ${lib.escapeShellArg cfg.cipherDir} does not exist"
          exit 1
        fi

        if [ ! -f ${lib.escapeShellArg cfg.cipherDir}/gocryptfs.conf ]; then
          echo "gocryptfs: running gocryptfs -init"
          gocryptfs -init \
            -passfile ${lib.escapeShellArg cfg.passwordFile} \
            ${builtins.concatStringsSep " " (map lib.escapeShellArg cfg.extraInitOptions)} \
            ${lib.escapeShellArg cfg.cipherDir}
        fi

        if [ ! -d ${lib.escapeShellArg cfg.mountPoint} ]; then
          mkdir -p ${lib.escapeShellArg cfg.mountPoint}
        fi

        gocryptfs -fg -passfile ${lib.escapeShellArg cfg.passwordFile} \
          ${builtins.concatStringsSep " " (map lib.escapeShellArg cfg.extraOptions)} \
          ${lib.escapeShellArg cfg.cipherDir} ${lib.escapeShellArg cfg.mountPoint}
      '';
    };
  };
}