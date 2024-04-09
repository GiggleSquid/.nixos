{ inputs, cell }:
let
  inherit (cell) nixosProfiles;
in
with nixosProfiles;
rec {
  base = [ common ];

  ntp-server = base ++ [ chrony ];

  dns-server = [ technitium ];

  caddy-server = [ caddy ];
}
