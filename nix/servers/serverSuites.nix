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

  crowdsec = [ nixosModules.crowdsec ];

  ntp-server = base-rpi ++ [
    chrony
  ];

  rpi-server = base-rpi;

  dns-server = [ technitium ];

  caddy-server = base ++ [
    caddy
    nixosModules.crowdsec
  ];

  searxng = [ nixosModules.searx ];

  squidbit = [ nixosModules.qbittorrent ];

  i2pd = base ++ [
    nixosModules.i2pd
    nixosModules.crowdsec
  ];

  minesquid = [ nixosModules.nix-minecraft ];

}
