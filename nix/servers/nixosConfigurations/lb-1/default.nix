{
  inputs,
  cell,
}:
let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "lb-1";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lb.lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [ 443 ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = lib.mkForce { };
      "10-enp6s18" = {
        matchConfig.Name = "enp6s18";
        vlan = [
          "enp6s18.100"
          "enp6s18.101"
        ];
        networkConfig.LinkLocalAddressing = "no";
        linkConfig.RequiredForOnline = "carrier";
      };
      "30-enp6s18.100" = {
        matchConfig.Name = "enp6s18.100";
        networkConfig.IPv6PrivacyExtensions = "no";
        networkConfig = {
          IPv6AcceptRA = false;
        };
        routes = [
          {
            Gateway = "10.100.0.1";
            Table = 4100;
          }
          {
            Gateway = "fe80::7a45:58ff:feca:6d5a";
            Table = 6100;
          }
        ];
        routingPolicyRules = [
          {
            From = "10.100.0.0/24";
            Table = 4100;
          }
          {
            From = "2a0b:9401:64:100::/64";
            Table = 6100;
          }
        ];
      };
      "31-enp6s18.101" = {
        matchConfig.Name = "enp6s18.101";
        networkConfig.IPv6PrivacyExtensions = "no";
        ipv6AcceptRAConfig = {
          Token = "static:::31";
        };
        address = [
          "10.101.0.31/24"
        ];
        routes = [
          { Gateway = "10.101.0.1"; }
          {
            Gateway = "10.101.0.1";
            Table = 4101;
          }
        ];
        routingPolicyRules = [
          {
            From = "10.101.0.0/24";
            Table = 4101;
          }
        ];
      };
    };
    netdevs = {
      "20-enp6s18.100" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "enp6s18.100";
          MACAddress = "bC:24:11:81:6e:b0";
        };
        vlanConfig.Id = 100;
      };
      "21-enp6s18.101" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "enp6s18.101";
          MACAddress = "bC:24:11:81:6e:b1";
        };
        vlanConfig.Id = 101;
      };
    };
  };

  services = {
    keepalived = {
      enable = true;
      openFirewall = true;
      enableScriptSecurity = true;
      extraGlobalDefs = ''
        vrrp_version 3
        script_user root
      '';
      vrrpInstances = {
        "loadbalancer_IPv4_1" = {
          virtualRouterId = 1;
          priority = 200;
          interface = "enp6s18.101";
          unicastSrcIp = "10.101.0.31";
          unicastPeers = [ "10.101.0.30" ];
          virtualIps = [
            {
              addr = "10.100.0.10";
              dev = "enp6s18.100";
            }
          ];
          extraConfig = ''
            advert_int 1
            check_unicast_src
          '';
        };
        "loadbalancer_IPv6_1" = {
          virtualRouterId = 1;
          priority = 200;
          interface = "enp6s18.101";
          unicastSrcIp = "2a0b:9401:64:101::31";
          unicastPeers = [ "2a0b:9401:64:101::30" ];
          virtualIps = [
            {
              addr = "2a0b:9401:64:100::10";
              dev = "enp6s18.100";
            }
          ];
          extraConfig = ''
            advert_int 1
            check_unicast_src
          '';
        };
        "loadbalancer_IPv4_2" = {
          virtualRouterId = 2;
          priority = 255;
          interface = "enp6s18.101";
          unicastSrcIp = "10.101.0.31";
          unicastPeers = [ "10.101.0.30" ];
          virtualIps = [
            {
              addr = "10.100.0.11";
              dev = "enp6s18.100";
            }
          ];
          extraConfig = ''
            advert_int 1
            check_unicast_src
          '';
        };
        "loadbalancer_IPv6_2" = {
          virtualRouterId = 2;
          priority = 255;
          interface = "enp6s18.101";
          unicastSrcIp = "2a0b:9401:64:101::31";
          unicastPeers = [ "2a0b:9401:64:101::30" ];
          virtualIps = [
            {
              addr = "2a0b:9401:64:100::11";
              dev = "enp6s18.100";
            }
          ];
          extraConfig = ''
            advert_int 1
            check_unicast_src
          '';
        };
      };
      extraConfig =
        let
          "vrrp_notify_script" = nixpkgs.writers.writeBash "vrrp_notify_script.sh" ''
            TYPE=$1
            NAME=$2
            ENDSTATE=$3
            IFACE=enp6s18.101

            case $ENDSTATE in
                "BACKUP") # Perform action for transition to BACKUP state
                   ${lib.getExe' nixpkgs.ipvsadm "ipvsadm"} --start-daemon backup --syncid 1 --mcast-interface=$IFACE
                          exit 0
                          ;;
                "FAULT")  # Perform action for transition to FAULT state
                          exit 0
                          ;;
                "STOP")  # Perform action for transition to STOP state
                   ${lib.getExe' nixpkgs.ipvsadm "ipvsadm"} --stop-daemon master
                   ipvsadm --stop-daemon backup
                          exit 0
                          ;;
                "MASTER") # Perform action for transition to MASTER state
                   ${lib.getExe' nixpkgs.ipvsadm "ipvsadm"} --start-daemon master --syncid 2 --mcast-interface=$IFACE
                          exit 0
                          ;;
                *)        echo "Unknown state $${ENDSTATE}"
                          exit 1
                          ;;
            esac
          '';
        in
        # keepalived
        ''
          vrrp_sync_group loadbalancer_1 {
            group {
              loadbalancer_IPv4_1
              loadbalancer_IPv6_1
            }
            notify ${vrrp_notify_script}
          }
          vrrp_sync_group loadbalancer_2 {
            group {
              loadbalancer_IPv4_2
              loadbalancer_IPv6_2
            }
            notify ${vrrp_notify_script}
          }
        ''
        + (lib.readFile ../lb-0/_ipvs-virtual-servers.conf);
    };

    alloy-squid = {
      enable = true;
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.vms ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base
        ];
    in
    lib.concatLists [
      profiles
      suites
    ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "hm-bak";
    users = {
      squid = {
        imports =
          let
            modules = [ ];
            profiles = [ ];
            suites = with homeSuites; squid;
          in
          lib.concatLists [
            modules
            profiles
            suites
          ];
        home.stateVersion = "25.11";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "25.11";
      };
    };
  };

  system.stateVersion = "25.11";
}
