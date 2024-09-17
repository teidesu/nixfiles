{ abs, lib, config, pkgs, ... }@inputs:

let
  containers = import (abs "lib/containers.nix") inputs;
in
{
  imports = [
    (containers.mkNixosContainer {
      name = "puffer";
      ip = "10.42.0.5";
      private = false;

      config = { ... }: {
        users.users.smb-guest.isNormalUser = true;
        
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
          publish = {
            enable = true;
            userServices = true;
          };

          extraServiceFiles.puffer = ''
            <?xml version="1.0" standalone='no'?>
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name>puffer</name>
              <service>
                <port>445</port>
                <type>_smb._tcp</type>
              </service>
              <service>
                <port>9</port>
                <type>_adisk._tcp</type>
                <txt-record>sys=waMa=0,adVF=0x100</txt-record>
                <txt-record>dk0=adVN=Puffer TimeMachine,adVF=0x82</txt-record>
              </service>
              <service>
                <port>0</port>
                <type>_device-info._tcp</type>
                <txt-record>model=TimeCapsule8,119</txt-record>
              </service>
            </service-group>
          '';
        };

        services.samba = {
          enable = true;
          openFirewall = true;

          securityType = "user";
          extraConfig = ''
            workgroup = WORKGROUP
            server string = puffer
            netbios name = puffer
            security = user
            guest account = smb-guest
            map to guest = bad user
            hosts allow = 10.0.0.0/8
            hosts deny = 0.0.0.0/0
            inherit permissions = yes

            # Performance
            socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
            read raw = yes
            write raw = yes
            server signing = no
            strict locking = no
            min receivefile size = 16384
            use sendfile = Yes
            aio read size = 16384
            aio write size = 16384

            # Fruit global config
            fruit:aapl = yes
            fruit:nfs_aces = no
            fruit:copyfile = no
            fruit:model = MacSamba
          '';

          shares =
            let
              common = {
                browseable = "yes";
                "read only" = "yes";
                "guest ok" = "yes";
              };
            in
            {
              Downloads = common // {
                path = "/mnt/puffer/Downloads";
              };

              Public = common // {
                path = "/mnt/puffer/Public";
              };
            };
        };
      };

      mounts = {
        "/mnt/puffer/Downloads" = {
          hostPath = "/mnt/puffer/Downloads";
          isReadOnly = true;
        };
        "/mnt/puffer/Public" = {
          hostPath = "/mnt/puffer/Public";
          isReadOnly = true;
        };
      };
    })
  ];

}
