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

  crowdsec = [ nixosModules.crowdsec ];

  dns-server = [ technitium ];

  caddy-server = [
    caddy
    nixosModules.crowdsec
  ];

  squidbit = [
    nixosModules.unpackerr
    nixosModules.nix-pia-vpn
  ];

  i2pd = [
    nixosModules.i2pd
    nixosModules.crowdsec
  ];

  minesquid = [ nixosModules.nix-minecraft ];

  arion = [ nixosModules.arion ];

}
