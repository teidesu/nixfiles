{ ... }:

{
  # todo - move this from an ad-hoc docker compose to a proper service
  # todo 2: update UMAMI_HOST in teisu-env
  services.nginx.virtualHosts."zond.tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";
    
    locations."/" = {
      proxyPass = "http://umami.umami.docker:3000/";
    };
  };
}