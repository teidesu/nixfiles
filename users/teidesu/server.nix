{ abs, pkgs, lib, inputs, ... }:

{
  users.users.teidesu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "kvm" "docker" "pipewire" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keyFiles = [
      (abs "ssh/teidesu.pub")
    ];
  };

  home-manager.users.teidesu = { pkgs, ... }: {
    imports = [
      ./common.nix
      inputs.vscode-server.homeModules.default
    ];

    services.vscode-server.enable = true;
  };
}
