{ pkgs, config, lib, ... }: 

let 
  cfg = config.desu.openid-proxy;
in {
  options.desu.openid-proxy = with lib; {
    services = mkOption {
      type = types.attrsOf (types.submodule ({ ... }: {
        options = {
          clientId = mkOption {
            type = types.str;
            description = "oauth2 client id";
          };
          domain = mkOption {
            type = types.str;
            description = "domain that the service will be hosted on";
          };
          upstream = mkOption {
            type = types.str;
            description = "upstream address";
          };
          envSecret = mkOption {
            type = types.str;
            description = "name of the secret that contains the env vars (OAUTH2_PROXY_COOKIE_SECRET, OAUTH2_PROXY_CLIENT_SECRET)";
          };
          extra = mkOption {
            type = types.listOf types.str;
            description = "extra arguments that will be passed to the service";
            default = [];
          };
          uid = mkOption {
            type = types.nullOr types.int;
            description = "uid of the user that will run the service";
            default = null;
          };
        };
      }));
      default = {};
    };
  };

  config = lib.mkIf (cfg.services != {}) {
    virtualisation.oci-containers.containers = builtins.listToAttrs (
      map (name: let 
        service = cfg.services.${name};
      in {
        name = "${name}-oidc";
        value = {
          image = "quay.io/oauth2-proxy/oauth2-proxy:v7.7.1-amd64";
          ${if service.uid != null then "user" else null} = "${builtins.toString service.uid}";
          environmentFiles = [
            config.age.secrets.${service.envSecret}.path
          ];

          cmd = [ 
            "--reverse-proxy=true"
            "--http-address=0.0.0.0:80"
            "--skip-provider-button=true"
            "--provider=oidc"
            "--email-domain=*"
            "--client-id=${service.clientId}"
            "--upstream=${service.upstream}"
            "--redirect-url=https://${service.domain}/oauth2/callback"
            "--oidc-issuer-url=https://id.stupid.fish/oauth2/openid/${service.clientId}"
          ] ++ service.extra;
        };
      }) (builtins.attrNames cfg.services)
    );
  };
}