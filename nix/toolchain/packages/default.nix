# Absoulutely could not figure this out on my own.
# https://github.com/Lord-Valen/configuration.nix/blob/master/comb/lord-valen/packages/default.nix
{ inputs, cell }@paisano:
let
  inherit (inputs.nixpkgs) lib;

  inherit (builtins) readDir;
  inherit (lib) callPackageWith filterAttrs mapAttrs;
  inherit (lib.path) append;
  inherit (lib.filesystem) packagesFromDirectoryRecursive;

  callPackage = callPackageWith (inputs.nixpkgs // { inherit paisano; });
  dirs = filterAttrs (_: type: type == "directory") (readDir ./.);
in
mapAttrs (
  name: _:
  packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = append ./. name;
  }
) dirs
