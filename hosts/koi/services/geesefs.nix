{ config, abs, ... }:

{
  imports = [
    (abs "services/geesefs.nix")
    (abs "services/rclone-mount.nix")
    (abs "services/gocryptfs.nix")
  ];

  desu.secrets.geesefs-credentials = {};
  desu.secrets.desu-priv-passphrase = {};

  users.users.geesefs = {
    isNormalUser = true;
    uid = 1117;
  };
  users.groups.geesefs = {
    gid = 1117;
  };

  services.geesefs = {
    enable = true;
    args = [
      "--endpoint" "https://storage.yandexcloud.net"
      "--region" "ru-central1"
      "--shared-config" config.desu.secrets.geesefs-credentials.path
      "-o" "allow_other"
      "-o" "rootmode=040771"
      "--dir-mode" "0770"
      "--file-mode" "0660"
      "--uid" "1117"
      "--gid" "1117"
      # performance tuning
      "--memory-limit" "4000"
      "--max-flushers" "32"
      "--max-parallel-parts" "32"
      "--part-sizes" "25"
      "--large-read-cutoff" "40960"
    ];
    bucket = "desu-priv";
    mountPoint = "/mnt/s3-desu-priv";
  };

  systemd.services.geesefs.after = [ "coredns.service" ];

  services.gocryptfs = {
    enable = true;
    cipherDir = "/mnt/s3-desu-priv/encrypted-go";
    mountPoint = "/mnt/s3-desu-priv-encrypted";
    passwordFile = config.desu.secrets.desu-priv-passphrase.path;
    extraOptions = [ "-allow_other" ];
  };
  systemd.services.gocryptfs.requires = [ "geesefs.service" ];
}