{ inputs, cell }:
let
  inherit (cell) nixosProfiles;
in
with nixosProfiles;
rec {
  base = [ common ];

  ntp-server = [
    common-rpi
    chrony
  ];

  dns-server = [ technitium ];

  caddy-server = [ caddy ];
}
