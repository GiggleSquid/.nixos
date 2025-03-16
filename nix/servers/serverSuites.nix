{ inputs, cell }:
let
  inherit (cell) nixosProfiles nixosModules;
in
with nixosProfiles;
rec {
  base = [
    common
    nixosModules.alloy-squid
  ];

  base-rpi = [
    common-rpi
    nixosModules.alloy-squid
  ];

  rpi-server = base-rpi;

  crowdsec = [ nixosModules.crowdsec ];

  ntp-server = base-rpi ++ [
    chrony
  ];

  caddy-server-rpi = rpi-server ++ [
    caddy
    nixosModules.crowdsec
  ];

  dns-server = [ technitium ];

  caddy-server = base ++ [
    caddy
    nixosModules.crowdsec
  ];

  squidbit = [
    nixosModules.qbittorrent
    nixosModules.nix-pia-vpn
  ];

  i2pd = base ++ [
    nixosModules.i2pd
    nixosModules.crowdsec
  ];

  minesquid = [ nixosModules.nix-minecraft ];

  arion = [ nixosModules.arion ];

}
