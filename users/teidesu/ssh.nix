{ abs, pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  secrets = pkgs.callPackage (abs "lib/secrets-unsafe.nix") {};
in {
  home.file.".ssh/ssh.pub".source = abs "ssh/teidesu.pub";
  home.file.".ssh/git.pub".source = abs "ssh/teidesu-git.pub";
  home.file.".ssh/base_known_hosts".source = ./assets/base_known_hosts;

  programs.ssh = {
    enable = true;

    hashKnownHosts = true;

    extraOptionOverrides = {
      GlobalKnownHostsFile = "~/.ssh/base_known_hosts";
      ControlPath = "~/.ssh/master-%C";
    };

    matchBlocks = {
      madoka.hostname = secrets.readUnsafe "madoka-ip";
      homura.hostname = secrets.readUnsafe "homura-ip";

      koi = {
        hostname = "10.42.0.2";
        forwardAgent = true;
      };

      "github.com" = {
        identityFile = "~/.ssh/ssh.pub";
      };
    } // (lib.optionalAttrs isDarwin {
      # 1password ssh agent
      "*" = {
        extraOptions = {
          IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
          HostkeyAlgorithms = "+ssh-rsa";
          PubkeyAcceptedAlgorithms = "+ssh-rsa";
        };
      };
    });
  };
}