{ config, lib, pkgs, ... }:

{
  # todo: ideally we should support multiple encrypted directories
  options.services.ecryptfs = with lib; {
    enable = mkEnableOption "ecryptfs";
    package = mkOption {
      type = types.package;
      default = pkgs.ecryptfs;
      defaultText = "pkgs.ecryptfs";
      description = "ecryptfs package";
    };
    serviceName = mkOption {
      type = types.str;
      default = "ecryptfs";
      description = "ecryptfs service name";
    };

    cipherDir = mkOption {
      type = types.str;
      description = "path to the directory used as the underlying encrypted storage";
    };

    passphrasePath = mkOption {
      type = types.str;
      description = "path to the file containing the passphrase (this can be rotated down the line without needing to re-encrypt the data)";
    };

    masterKeyPath = mkOption {
      type = types.str;
      description = "path to the master key (i.e. the wrapped passphrase file)";
    };

    mountPoint = mkOption {
      type = types.str;
      description = "ecryptfs mount point";
    };

    encryptFilenames = mkOption {
      type = types.bool;
      default = true;
      description = "whether to encrypt filenames";
    };

    encryptionKeySize = mkOption {
      type = types.int;
      default = 32;
      description = "size of the encryption key in bytes";
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "additional options to pass to ecryptfs";
    };
  };

  config = let 
    cfg = config.services.ecryptfs;

    mountOptions = 
      [ 
        "ecryptfs_sig=$sig"
        "ecryptfs_key_bytes=${toString cfg.encryptionKeySize}"
        "ecryptfs_cipher=aes"
        "ecryptfs_unlink_sigs"
        "no_sig_cache"
      ] ++
      (lib.optional cfg.encryptFilenames "ecryptfs_fnek_sig=$sig") ++
      cfg.extraOptions;
  in {
    systemd.services.${cfg.serviceName} = {
      description = "${cfg.serviceName} setup";
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package pkgs.keyutils ];
      serviceConfig = {
        User = "root";
        Group = "root";
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${pkgs.utillinux}/bin/umount ${lib.escapeShellArg cfg.mountPoint}";
      };
      script = ''
        set -euo pipefail
        if [ ! -f ${lib.escapeShellArg cfg.masterKeyPath} ]; then
          echo "master key file ${cfg.masterKeyPath} does not exist, generating..."
          passphrase=$(${pkgs.coreutils}/bin/head -c 48 /dev/random | base64)
          wrapping_passphrase=$(cat ${lib.escapeShellArg cfg.passphrasePath})
          printf "%s\n%s" "$passphrase" "$wrapping_passphrase" | ecryptfs-wrap-passphrase ${lib.escapeShellArg cfg.masterKeyPath} -
        fi

        if [ ! -d ${lib.escapeShellArg cfg.cipherDir} ]; then
          echo "ecryptfs: directory ${lib.escapeShellArg cfg.cipherDir} does not exist"
          exit 1
        fi

        if [ ! -d ${lib.escapeShellArg cfg.mountPoint} ]; then
          mkdir -p ${lib.escapeShellArg cfg.mountPoint}
        fi

        result=$(cat ${lib.escapeShellArg cfg.passphrasePath} | ecryptfs-insert-wrapped-passphrase-into-keyring ${lib.escapeShellArg cfg.masterKeyPath} -)
        sig=$(echo "$result" | sed -r 's/^.*sig \[(.*)\] into.*$/\1/')

        if [ -z "$sig" ]; then
          echo "failed to extract signature"
          echo "$result"
          exit 1
        fi

        echo "Keyring signature: $sig"

        if ! keyctl show | grep -q "_uid.0"; then
          # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=870126
          # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=870335
          keyctl link @u @s
        fi

        ${pkgs.utillinux}/bin/mount -i -t ecryptfs ${lib.escapeShellArg cfg.cipherDir} ${lib.escapeShellArg cfg.mountPoint} -o "${lib.concatStringsSep "," mountOptions}"
      '';
    };
  };
}