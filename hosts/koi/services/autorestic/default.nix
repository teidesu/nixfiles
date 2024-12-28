{ pkgs, config, lib, ... }:


let 
  autoresticWrapped = pkgs.writeShellScriptBin "autorestic" ''
    set -euo pipefail

    set -o allexport
    source ${config.desu.secrets.autorestic-env.path}
    set +o allexport
    export PATH="${lib.makeBinPath [ pkgs.restic pkgs.rclone pkgs.sqlite ]}:$PATH"

    # crutch: autorestic requires a lockfile to be beside the config file
    mkdir -p /etc/autorestic
    chmod -R 700 /etc/autorestic
    cp ${./config.yaml} /etc/autorestic/config.yaml

    exec ${pkgs.autorestic}/bin/autorestic -c /etc/autorestic/config.yaml $@
  '';
in {
  desu.secrets.autorestic-env.owner = "root";

  systemd.services.autorestic = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "${autoresticWrapped}/bin/autorestic --ci cron";
    };
    startAt = "*:0/5";
  };

  environment.systemPackages = [ autoresticWrapped ];
}