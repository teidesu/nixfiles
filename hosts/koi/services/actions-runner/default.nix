{ config, pkgs, ... }: 

{
  desu.secrets.forgejo-runners-token = {};

  systemd.services.actions-runner-build-dind = {
    description = "dind image builder for actions runner";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker build -t local/actions-runner-dind -f ${./Dockerfile.dind} .";
    };
  };

  systemd.services.gitea-runner-koi.requires = [ "actions-runner-build-dind.service" ];

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.koi = {
      name = "koi";
      enable = true;
      url = "https://codeberg.org";
      tokenFile = config.desu.secrets.forgejo-runners-token.path;
      labels = [
        "node18:docker://node:18-bullseye"
        "node20:docker://node:20-bullseye"
        "node22:docker://node:22-bullseye"
        "docker:docker://local/actions-runner-dind"
      ];
      settings = {
        runner.capacity = 8;
      };
    };
  };
}