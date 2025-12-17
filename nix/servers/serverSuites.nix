{ inputs, cell }:
let
  inherit (cell) nixosProfiles nixosModules;
in
with nixosProfiles;
{
  base = [
    nixosModules.alloy-squid
  ];

  base-rpi = [
    nixosModules.alloy-squid
  ];

  dns-server = [ technitium ];

  caddy-server = [
    caddy
    nixosModules.caddy-squid
  ];

  squidbit = [
    nixosModules.unpackerr
    nixosModules.nix-pia-vpn
  ];

  i2pd = [
    nixosModules.i2pd
    nixosModules.crowdsec
  ];

  snm = [ nixosModules.simple-nixos-mailserver ];

  minesquid = [ nixosModules.nix-minecraft ];

  arion = [ nixosModules.arion ];
}
