{ abs, pkgs, config, ... }@inputs:

let
  coredns = pkgs.callPackage (abs "packages/coredns.nix") {};

  hosts = pkgs.writeText "hosts" ''
    10.42.0.1 keenetic.stupid.fish
    10.42.0.2 torrent.stupid.fish
    10.42.0.2 koi.stupid.fish
    10.42.0.2 hass.stupid.fish
    10.42.0.8 bnuuy.stupid.fish
    10.42.0.2 puffer.stupid.fish
    10.42.0.2 puffer-webdav.stupid.fish
    10.42.0.2 lore.stupid.fish
    10.42.0.2 id.stupid.fish
    10.42.0.2 pds.stupid.fish
    10.42.0.2 waka.stupid.fish
    10.42.0.2 siyuan.tei.su
  '';

  package = coredns.override {
    externalPlugins = [{
      name = "docker";
      repo = "github.com/kevinjqiu/coredns-dockerdiscovery";
      version = "06643b6edfed621b4153b5b2ab783ec5d4a6e697";
    }];
    vendorHash = "sha256-URLiZXTj8Z/wDNI8gxVFthjitVxL9rugySDXYzDxNJg=";
  };
in
{
  services.coredns = {
    enable = true;
    config = ''
      (local_only) {
        acl {
          allow net 127.0.0.0/8 # localhost
          allow net 172.16.0.0/12 # docker
          allow net 10.42.0.0/24 # nixos containers
          block
        }
      }

      .:53 {
        cache
        header {
          response set ra # https://github.com/coredns/coredns/issues/3690#issuecomment-1573865953
        }
        hosts ${hosts} {
          reload 0
          fallthrough
        }
        forward . tls://1.1.1.1 tls://1.0.0.1 tls://2606:4700:4700::1111 tls://2606:4700:4700::1001 {
          tls_servername one.one.one.one
          health_check 5s
        }
      }

      docker:53 {
        header {
          response set ra # https://github.com/coredns/coredns/issues/3690#issuecomment-1573865953
        }
        template ANY AAAA {
          rcode NOERROR
        }
        import local_only
        docker {
          domain docker
          compose_domain docker
        }
      }

      # nixos puts ip addresses of the containers into /etc/hosts with `.containers` suffix
      # let's just re-use that as is
      containers:53 {
        import local_only
        hosts
      }
    '';
    package = package;
  };

  systemd.services.coredns = {
    after = [ "docker.service" "docker.socket" ];
    serviceConfig = {
      DynamicUser = pkgs.lib.mkForce false;
      User = "coredns";
    };
  };

  users.users.coredns = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
    createHome = false;
    shell = pkgs.shadow;
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
