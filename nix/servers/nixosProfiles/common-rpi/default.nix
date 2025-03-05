{ inputs }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib;
in
{
  networking = {
    useNetworkd = true;
    nameservers = lib.mkDefault [ "10.3.0.1" ];
    firewall = {
      enable = lib.mkDefault false;
    };
  };

  services = {
    chrony = {
      enable = true;
      initstepslew = lib.mkDefault {
        enabled = true;
        threshold = 120;
      };
      extraFlags = [ "-s" ];
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
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
