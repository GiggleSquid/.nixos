{ inputs }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib;
in
{
  networking = {
    useNetworkd = true;
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  services = {
    chrony = {
      enable = true;
      initstepslew = lib.mkDefault {
        enabled = true;
        threshold = 120;
      };
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
        dns = [ "10.3.0.1" ];
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
