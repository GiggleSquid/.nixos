{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  networking = {
    useNetworkd = true;
    timeServers = [
      "10.10.3.5"
    ];
    firewall = {
      enable = false;
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
      fallbackDns = [
      ];
    };
    qemuGuest.enable = true;
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "ens18";
        networkConfig = {
          DHCP = "no";
        };
        dns = ["10.10.4.1"];
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
