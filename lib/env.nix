{ pkgs, lib, ... }:

rec {
  fillJsonWithEnv = template: target: ''
    SECRETS=$(jq -c '(paths(scalars | true) | select (.[-1] == "_secret")) as $p | getpath($p) as $v | [$p, $v]' ${lib.escapeShellArg template})
    cp ${lib.escapeShellArg template} ${lib.escapeShellArg target}
    echo "$SECRETS" | while read -r secret; do
      jq --argjson secret "$secret" 'setpath($secret[0][:-1]; $ENV[$secret[1]])' ${lib.escapeShellArg target} > ${lib.escapeShellArg target}.tmp
      mv ${lib.escapeShellArg target}.tmp ${lib.escapeShellArg target}
    done
  '';

  mkJsonEnvEntrypoint = { template, target, entrypoint, extraScript ? "" }: pkgs.writeScript "entrypoint.sh" ''
    #!/bin/sh
    if [ ! -f ${lib.escapeShellArg template} ]; then
      echo "Missing secrets file: ${lib.escapeShellArg template}"
      exit 1
    fi
    if ! command -v jq &> /dev/null; then
      echo "jq not found, please make it available"
      exit 1
    fi

    ${fillJsonWithEnv template target}
    ${extraScript}
    exec ${entrypoint}
  '';
}