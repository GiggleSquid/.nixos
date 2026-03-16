{ config }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  sops.secrets = {
    nix_conf = { };
  };

  xdg.configFile = {
    "nix/nix.conf".source = mkOutOfStoreSymlink config.sops.secrets.nix_conf.path;
  };
}
