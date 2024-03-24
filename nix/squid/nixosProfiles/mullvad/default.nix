{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  services.mullvad-vpn = {
    enable = true;
    package = nixpkgs.mullvad-vpn;
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        routes = [
          # add routes for vlans. Mullvad compatability
          {
            routeConfig = {
              Destination = "10.10.1.0/24";
              Gateway = "_dhcp4";
            };
          }
          {
            routeConfig = {
              Destination = "10.10.2.0/24";
              Gateway = "_dhcp4";
            };
          }
          {
            routeConfig = {
              Destination = "10.10.3.0/24";
              Gateway = "_dhcp4";
            };
          }
          {
            routeConfig = {
              Destination = "10.10.4.0/24";
              Gateway = "_dhcp4";
            };
          }
          {
            routeConfig = {
              Destination = "10.10.5.0/24";
              Gateway = "_dhcp4";
            };
          }
          {
            routeConfig = {
              Destination = "10.10.50.0/24";
              Gateway = "_dhcp4";
            };
          }
        ];
      };
    };
  };
}
