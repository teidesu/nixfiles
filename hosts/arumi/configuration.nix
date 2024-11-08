{ abs, modulesPath, ... }: 

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix

    ./services/sing-box.nix
    ./services/uptime-kuma.nix
    ./services/mumble.nix
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  age.identityPaths = [
    "/etc/ssh/agenix_key"
  ];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keyFiles = [
    (abs "ssh/teidesu.pub")
  ];

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  
  system.stateVersion = "23.11";
}