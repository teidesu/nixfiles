{ ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    # docker for whatever reason decides not to use system resolver if we have 127.0.0.1 in resolv.conf
    # and fallbacks to google dns (src: https://github.com/moby/moby/issues/6388#issuecomment-46343580)
    # but we want it to use it. so pin the cidr used by docker and force the gateway as the default dns :D
    fixed-cidr = "172.17.0.1/16";
    default-gateway = "172.17.0.1";
    dns = ["172.17.0.1"];
  };
  virtualisation.oci-containers.backend = "docker";
}