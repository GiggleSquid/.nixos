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
  hostName = "ncps";
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
      "ncps/s3-access-key-id" = { };
      "ncps/s3-secret-access-key" = { };
      "ncps/cache-secret-key" = { };
    };
  };

  systemd.services = {
    ncps.after = [ "postgresql.service" ];
  };

  services = {
    ncps = {
      enable = true;
      server.addr = "[::1]:8080";
      analytics.reporting.enable = false;
      prometheus.enable = true;
      cache = {
        upstream = {
          urls = [
            "https://cache.nixos.org"
            "https://colmena.cachix.org"
            "https://helix.cachix.org"
            "https://nix-community.cachix.org"
            #local harmonia caches
            "https://harmonia.ns1.dns.lan.gigglesquid.tech"
            "https://harmonia.ns2.dns.lan.gigglesquid.tech"
            "https://harmonia.dmz-0.caddy.lan.gigglesquid.tech"
            "https://harmonia.dmz-1.caddy.lan.gigglesquid.tech"
            "https://harmonia.dmz-2.caddy.lan.gigglesquid.tech"
          ];
          publicKeys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            #local harmonia caches
            "harmonia.ns1.dns.lan.gigglesquid.tech-1:hmVj0YvaTUyDJUWr7yjqkWw3E2yyG46ho1J4WdnlxPs="
            "harmonia.ns2.dns.lan.gigglesquid.tech-1:EIyM/rV/jVoBaj9Z49ZuWo9lW1MgKlXYb0mVqEH8m1M="
            "harmonia.dmz-0.caddy.lan.gigglesquid.tech-1:DpbrdJm/2o/4f6gKxiRve6uNMdGep6KBLjSckUhOst8="
            "harmonia.dmz-1.caddy.lan.gigglesquid.tech-1:WGKlHeb8Ek7h6bDby/XeBTbsCG47BjKGITBUSdyWP+M="
            "harmonia.dmz-2.caddy.lan.gigglesquid.tech-1:di68rXtuqcKy3z6RzH1FRTwZ3uGClhjg8PShfLCH6HQ="
          ];
        };
        lru.schedule = "0 2 * * *";
        maxSize = "64G";
        hostName = "nix-cache.lan.gigglesquid.tech";
        databaseURL = "postgresql:///ncps?host=/run/postgresql&user=ncps";
        secretKeyPath = "${config.sops.secrets."ncps/cache-secret-key".path}";
        storage = {
          s3 = {
            bucket = "ncps";
            endpoint = "https://api.rustfs.cephalonas.lan.gigglesquid.tech";
            region = "us-east-1";
            accessKeyIdPath = "${config.sops.secrets."ncps/s3-access-key-id".path}";
            secretAccessKeyPath = "${config.sops.secrets."ncps/s3-secret-access-key".path}";
          };
        };
        cdc = {
          enabled = true;
          min = 16 * 1024;
          avg = 64 * 1024;
          max = 256 * 1024;
        };
      };
    };
    postgresql = {
      enable = true;
      settings = {
        max_connections = 100;
        shared_buffers = "256MB";
        effective_cache_size = "1GB";
        work_mem = "4MB";
        maintenance_work_mem = "64MB";
      };
      ensureDatabases = [ "ncps" ];
      ensureUsers = [
        {
          name = "ncps";
          ensureDBOwnership = true;
        }
      ];
    };
    caddy-squid = {
      enable = true;
    };
    caddy.virtualHosts = {
      "ncps.lan.gigglesquid.tech" =
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
              handle {
                reverse_proxy ${config.services.ncps.server.addr}
              }
              handle /metrics {
                respond "Forbidden" 403 {
                  close
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
      alloyConfig = # alloy
        ''
          prometheus.scrape "scrape_metrics_ncps" {
            targets         = [
              {
                __address__      = "localhost:8080",
                __scheme__ = "http",
                __metrics_path__ = "metrics",
              },
            ]
            forward_to      = [prometheus.remote_write.prometheus_service.receiver]
            scrape_interval = "15s"
          }
        '';
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
