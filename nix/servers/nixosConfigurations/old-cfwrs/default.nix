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
  hostName = "old-cfwrs";
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
      allowedUDPPorts = [
        443
      ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp6s18";
        ipv6AcceptRAConfig = {
          Token = "static:::1:106";
        };
        address = [
          "10.3.1.106/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  services = {
    odoo = {
      enable = true;
      autoInit = true;
      autoInitExtraFlags = [ "--without-demo=all" ];
      settings = {
        options = {
          proxy_mode = lib.mkForce true;
        };
      };
    };
    caddy-squid = {
      enable = true;
    };
    caddy.virtualHosts = {
      "old.cfwrs.org.uk.lan.gigglesquid.tech" =
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

              basic_auth {
                CFWRS $2a$14$fpigMZS1lDCsKWjutjcbO.z467obj2r1HEi8E0kwVMdvvCCe94Y1S
              }


              route /websocket {
                reverse_proxy localhost:8072 {
                  header_up Host {upstream_hostport}
                }
              }
              route {
                reverse_proxy localhost:8069 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
    };

    alloy-squid = {
      enable = true;
      export = {
        caddy = {
          metrics = true;
          logs = true;
        };
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.vms
      ];
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
        home.stateVersion = "25.05";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "25.05";
      };
    };
  };

  system.stateVersion = "25.05";
}
