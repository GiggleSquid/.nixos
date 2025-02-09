{ inputs }:
let
  lib = inputs.nixpkgs.lib;
in
{
  networking = {
    nameservers = lib.mkDefault [ "10.3.0.1" ];
    firewall = {
      enable = lib.mkDefault false;
    };
  };
}
