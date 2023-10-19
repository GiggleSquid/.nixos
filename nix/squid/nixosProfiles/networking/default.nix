{
  networking = {
    useNetworkd = true;
    wireguard.enable = true;
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "eno1";
        networkConfig = {
          DHCP = "ipv4";
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
