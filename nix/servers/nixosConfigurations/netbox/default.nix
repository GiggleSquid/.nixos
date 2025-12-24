{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "netbox";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
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
      "10-lan" = {
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:90";
        };
        address = [
          "10.3.1.90/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      "netbox/secret-key" = {
        owner = "netbox";
      };
    };
  };

  systemd.tmpfiles.rules = [ "d /run/netbox 0750 netbox netbox -" ];

  services = {
    netbox = {
      enable = true;
      unixSocket = "/run/netbox/netbox.sock";
      secretKeyFile = config.sops.secrets."netbox/secret-key".path;
      plugins =
        python3Packages: with python3Packages; [
          netbox-dns
          netbox-topology-views
          netbox-contextmenus
          netbox-reorder-rack
        ];
      settings = {
        ALLOWED_HOSTS = [ "netbox.lan.gigglesquid.tech" ];
        PLUGINS = [
          "netbox_dns"
          "netbox_topology_views"
          "netbox_contextmenus"
          "netbox_reorder_rack"
        ];
      };
    };

    caddy-squid = {
      enable = true;
      supplementaryGroups = [ "netbox" ];
    };
    caddy.virtualHosts = {
      "netbox.lan.gigglesquid.tech" =
        { name, ... }:
        {
          logFormat = ''
            output file ${config.services.caddy.logDir}/access-${
              lib.replaceStrings [ "/" " " ] [ "_" "_" ] name
            }.log {
              mode 640
            }
            level INFO
            format json
          '';
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              encode zstd gzip
              handle {
                reverse_proxy unix/${config.services.netbox.unixSocket}
              }
              handle_path /static/* {
                root ${config.services.netbox.dataDir}/static
                file_server
              }
            '';
        };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.servers ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base
          caddy-server
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
