{
  networking = {
    useNetworkd = true;
    wireguard.enable = true;
    timeServers = [ "10.3.0.5" ];
    firewall = {
      allowedTCPPorts = [
        1313 # hugo
      ];
      allowedUDPPorts = [ ];
    };
  };

  services = {
    chrony.enable = true;
    timesyncd.enable = false;
    resolved.fallbackDns = [ ];
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "eno1";
        networkConfig = {
          DHCP = "no";
        };
        gateway = [ "10.10.0.1" ];
        dns = [ "10.10.0.1" ];
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
