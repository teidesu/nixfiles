{ pkgs, ... }:

# i want to be able to declaratively *provision* gui apps on macos,
# but have them manage themselves later on, not managed by nix-darwin,
# since most of them are auto-updating and managing them entirely through
# nix is a bit of a pain.
#
# homebrew sucks and i don't want to give it *any* recognition, so guess
# i'll just handle dmg's myself :D

let 
  repo = pkgs.callPackage ./productivity.nix {};
in appsFactory: {
  system.activationScripts.postUserActivation.text = ''
    set -eau
    ${builtins.concatStringsSep "\n" (appsFactory repo)}
  '';
}