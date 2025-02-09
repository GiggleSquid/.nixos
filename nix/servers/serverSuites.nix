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

  ntp-server = base-rpi ++ [
    chrony
  ];

  rpi-server = base-rpi;

  dns-server = [ technitium ];

  caddy-server = base ++ [
    caddy
  ];

  squidbit = [ nixosModules.qbittorrent ];

  i2pd = [ nixosModules.i2pd ];

  minesquid = [ nixosModules.nix-minecraft ];

  crowdsec = [ nixosModules.crowdsec ];
}
