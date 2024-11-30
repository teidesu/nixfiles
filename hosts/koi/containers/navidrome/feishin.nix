{ buildNpmPackage, fetchFromGitHub, fetchNpmDeps }: 

buildNpmPackage rec {
  pname = "feishin";
  version = "0.12.1";
  src = fetchFromGitHub {
    owner = "jeffvli";
    repo = "feishin";
    rev = "v${version}";
    hash = "sha256-UpNtRZhAqRq/sRVkgg/RbLUWNXvHkAyGhu29zWE6Lk0=";
  };

  npmFlags = [ "--legacy-peer-deps" "--ignore-scripts" ];
  npmBuildScript = "build:web";
  makeCacheWritable = true;

  # i have NO idea why this doesnt work but calling it manually works
  # npmDepsHash = "sha256-0YfydhQZgxjMvZYosuS+rGA+9qzSYTLilQqMqlnR1oQ=";
  npmDeps = fetchNpmDeps {
    inherit src;
    name = "feishin-deps";
    hash = "sha256-0YfydhQZgxjMvZYosuS+rGA+9qzSYTLilQqMqlnR1oQ=";
    buildPhase = ''
      prefetch-npm-deps package-lock.json $out
    '';
  };

  installPhase = ''
    mkdir -p $out
    cp -r ./release/app/dist/web/* $out
  '';
}