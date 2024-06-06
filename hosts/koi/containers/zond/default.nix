{ ... }:

{
  # todo - move this from an ad-hoc docker compose to a proper service
  services.nginx.virtualHosts."zond.tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";
    
    locations."/" = {
      proxyPass = "http://umami.umami.docker:3000/";
    };
  };
}