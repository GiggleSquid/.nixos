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
  hostName = "attic";
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
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:40";
        };
        address = [
          "10.3.1.40/23"
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
      "attic/env" = { };
    };
  };

  systemd.services.atticd = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  services = {
    atticd = {
      enable = true;
      environmentFile = "${config.sops.secrets."attic/env".path}";
      settings = {
        listen = "[::1]:8080";
        allowed-hosts = [ "local.nix-cache.lan.gigglesquid.tech" ];
        api-endpoint = "https://local.nix-cache.lan.gigglesquid.tech/";
        database.url = "postgresql:///atticd?host=/run/postgresql&user=atticd";
        storage = {
          type = "s3";
          region = "us-east-1";
          bucket = "attic";
          endpoint = "https://api.rustfs.cephalonas.lan.gigglesquid.tech";
        };
        chunking = {
          nar-size-threshold = 64 * 1024;
          min-size = 32 * 1024;
          avg-size = 64 * 1024;
          max-size = 128 * 1024;
        };
        garbage-collection = {
          interval = "12 hours";
          default-retention-period = "1 month";
        };
      };
    };
    postgresql = {
      enable = true;
      ensureDatabases = [ "atticd" ];
      ensureUsers = [
        {
          name = "atticd";
          ensureDBOwnership = true;
        }
      ];
    };
    caddy-squid = {
      enable = true;
    };
    caddy.virtualHosts = {
      "attic.lan.gigglesquid.tech" =
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
              route {
                reverse_proxy localhost:8080
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
