{ wget, lib }:

rec {
  download = { 
    url, 
    params ? "",
    var ? "DOWNLOADED_FILE"
  }: ''
    echo "Downloading" ${lib.escapeShellArg url}"..."
    ${var}=$(mktemp)
    ${wget}/bin/wget ${lib.escapeShellArg url} ${params} -q --show-progress -O ${"$" + var}
  '';

  withMountedDmg = path: shell: ''
    _result=$(hdiutil mount ${path} | tail -n1)
    DMG_DEVICE=$(echo "$_result" | awk '{print $1}')
    DMG_MOUNTPOINT=$(echo "$_result" | awk '{print $3}')
    unset _result

    function _unmount {
      hdiutil unmount $DMG_DEVICE > /dev/null
    }
    trap _unmount ERR exit
    
    ${shell}

    _unmount
    trap - ERR exit
    unset DMG_DEVICE
    unset DMG_MOUNTPOINT
  '';

  installAppFromDmg = { dmg, filename }: withMountedDmg dmg ''
    if [ ! -d "$DMG_MOUNTPOINT/"${lib.escapeShellArg filename} ]; then
      echo "Error: file not found:" ${lib.escapeShellArg filename}
      exit 1
    fi

    cp -r "$DMG_MOUNTPOINT/"${lib.escapeShellArg filename} /Applications
  '';

  downloadAndInstallDmgApp = { 
    url,
    filename,
    params ? "",
  }: ''
    if [ ! -d "/Applications/"${lib.escapeShellArg (builtins.baseNameOf filename)} ]; then
      ${download { inherit url params; }}
      ${installAppFromDmg { dmg = "$DOWNLOADED_FILE"; inherit filename; }}
      rm -rf $DOWNLOADED_FILE
    fi
  '';

  downloadAndInstallDmgPkg = { 
    url,
    filename,
    condition,
    params ? "",
  }: ''
    if [ ${condition} ]; then
      ${download { inherit url params; }}
      ${withMountedDmg "$DOWNLOADED_FILE" ''
        installer -pkg "$DMG_MOUNTPOINT/"${lib.escapeShellArg filename} -target /
      ''}
      rm -rf $DOWNLOADED_FILE
    fi
  '';
}