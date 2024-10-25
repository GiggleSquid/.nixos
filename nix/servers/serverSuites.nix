{ inputs, cell }:
let
  inherit (cell) nixosProfiles nixosModules;
in
with nixosProfiles;
rec {
  base = [ common ];

  ntp-server = [
    common-rpi
    chrony
  ];

  rpi-server = [ common-rpi ];

  dns-server = [ technitium ];

  caddy-server = [ caddy ];

  squidbit = [ nixosModules.qbittorrent ];

  i2pd = [ nixosModules.i2pd ];

  minesquid = [ nixosModules.nix-minecraft ];
}
