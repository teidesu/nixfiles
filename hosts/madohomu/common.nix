{ abs, modulesPath, ... }: 

{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix

    ./services/sing-box.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  age.identityPaths = [
    "/etc/ssh/agenix_key"
  ];

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keyFiles = [
    (abs "ssh/teidesu.pub")
  ];
  
  system.stateVersion = "23.11";
}