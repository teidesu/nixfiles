{
  declare = defs: {
    age.secrets = builtins.listToAttrs (
      map
        (def:
          let obj = if builtins.isString def then { name = def; } else def;
          in {
            name = obj.name;
            value = builtins.removeAttrs
              (obj // {
                file = ../secrets + "/${obj.name}.age";
              }) [ "name" ];
          }
        )
        defs
    );
  };


  file = config: name: config.age.secrets.${name}.path;

  mount = config: name:
    let
      path = config.age.secrets.${name}.path;
      localPath = "/mnt/secrets/${name}";
    in
    {
      path = localPath;
      mounts = {
        ${localPath} = {
          hostPath = path;
          isReadOnly = true;
        };
      };
    };
}
