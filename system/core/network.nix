{...}: {
  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "eno1";
        networkConfig = {
          DHCP = "ipv4";
        };
        gateway = ["_dhcp4"];
        routes = [
          # add routes for vlans. Mullvad compatability
          {routeConfig = {Destination = "10.10.1.0/24";};}
          {routeConfig = {Destination = "10.10.2.0/24";};}
          {routeConfig = {Destination = "10.10.3.0/24";};}
          {routeConfig = {Destination = "10.10.4.0/24";};}
          {routeConfig = {Destination = "10.10.5.0/24";};}
          {routeConfig = {Destination = "10.10.50.0/24";};}
        ];
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
      "20-wlan" = {
        matchConfig.Name = "wlp0s20u10u3";
        networkConfig = {
          DHCP = "ipv4";
        };
        routes = [
          # add routes for vlans. Mullvad compatability
          {routeConfig = {Destination = "10.10.1.0/24";};}
          {routeConfig = {Destination = "10.10.2.0/24";};}
          {routeConfig = {Destination = "10.10.3.0/24";};}
          {routeConfig = {Destination = "10.10.4.0/24";};}
          {routeConfig = {Destination = "10.10.5.0/24";};}
          {routeConfig = {Destination = "10.10.50.0/24";};}
        ];
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  networking = {
    useNetworkd = true;

    wireguard.enable = true;
    firewall.allowedTCPPorts = [];
    firewall.allowedUDPPorts = [];
  };
}
