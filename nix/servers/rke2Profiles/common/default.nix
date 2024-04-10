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
        9345
        2379
        2380
        2381
        9099
        10250
      ];
      allowedUDPPorts = [
        8472
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

  # Longhorn uses nsenter for entering host namesoace,
  # and nsenter uses the path of the namespaces that called it
  # see: https://github.com/longhorn/longhorn/issues/2166
  systemd.tmpfiles.rules = [ "L+ /usr/local/bin - - - - /run/current-system/sw/bin/" ];

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp6s18";
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
    rke2
    kubectl
    ipvsadm
    nfs-utils
  ];
}
