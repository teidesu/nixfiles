{ config, abs, ... }:

{
  imports = [
    (abs "services/geesefs.nix")
    (abs "services/ecryptfs.nix")
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
      "--enable-patch"
    ];
    bucket = "desu-priv";
    mountPoint = "/mnt/s3-desu-priv";
  };

  services.ecryptfs = {
    enable = true;
    cipherDir = "/mnt/s3-desu-priv/encrypted";
    passphrasePath = config.desu.secrets.desu-priv-passphrase.path;
    masterKeyPath = "/mnt/s3-desu-priv/encrypted.key";
    mountPoint = "/mnt/s3-desu-priv-encrypted";
  };
  systemd.services.ecryptfs-setup.requires = [ "geesefs.service" ];
}