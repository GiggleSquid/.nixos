{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  networking = {
    useNetworkd = true;
    timeServers = [ "10.10.3.5" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        6443
        2379
        2380
        10250
        80
        443
        53
      ];
      allowedUDPPorts = [
        53
        51820
      ];
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
    qemuGuest.enable = true;
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "en*";
        networkConfig = {
          DHCP = "no";
        };
        dns = [ "10.10.4.1" ];
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  environment.systemPackages = with nixpkgs; [
    kubectl
    ipvsadm
    nfs-utils
  ];
}
