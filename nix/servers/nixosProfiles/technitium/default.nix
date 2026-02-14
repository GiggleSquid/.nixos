{
  services = {
    technitium-dns-server = {
      enable = true;
      openFirewall = true;
      firewallUDPPorts = [ 53 ];
      firewallTCPPorts = [
        53
        80
        443
        5380
        53443
      ];
    };
    alloy-squid = {
      enable = true;
    };
  };
}
