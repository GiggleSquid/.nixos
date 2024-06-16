{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  networking = {
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  services = {
    chrony = {
      enable = true;
    };
    timesyncd.enable = false;
    resolved = {
      fallbackDns = [ ];
    };
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "no";
        };
        dns = [ "10.10.3.1" ];
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
