{
  inputs,
  cell,
}:
let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "gigglesquid";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "tech.lan.gigglesquid.tech";
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
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:100";
        };
        address = [
          "10.3.1.100/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  services = {
    caddy-squid = {
      enable = true;
      plugins = {
        extra = [
          "github.com/mohammed90/caddy-git-fs@v0.0.0-20240805164056-529acecd1830"
        ];
        hash = "sha256-MJZhhtmZ9R4QLotOUC0kqBDjkbvfGjhTPuRrU9z0ECE=";
      };
      extraGlobalConfig = # caddyfile
        ''
          filesystem gigglesquidtech git https://github.com/GiggleSquid/gigglesquidtech {
            refresh_period 60s
          }
        '';
    };
    caddy.virtualHosts = {
      "gigglesquid.tech.lan.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            import logging gigglesquid.tech.lan.gigglesquid.tech
            import bunny_acme_settings
            import deny_non_local
            encode zstd gzip
            @cache-default path_regexp \/.*$
            @cache-images path_regexp \/.*\.(jpg|jpeg|png|gif|webp|ico|svg)$
            @cache-assets path_regexp \/assets\/(js\/.*\.js|css\/.*\.css)$
            @cache-fonts path_regexp \/fonts\/.*\.(ttf|otf|woff|woff2)$
            header @cache-default Cache-Control no-cache
            header @cache-images Cache-Control max-age=2628000
            header @cache-assets Cache-Control max-age=2628000
            header @cache-fonts Cache-Control max-age=15768000

            header {
              Cross-Origin-Embedder-Policy "unsafe-none"
              Cross-Origin-Opener-Policy "same-origin"
              Cross-Origin-Resource-Policy "same-site"
              Permissions-Policy "interest-cohort=(), camera=(), microphone=(), geolocation=()"
              Referrer-Policy "strict-origin-when-cross-origin"
              Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
              X-Content-Type-Options "nosniff"
              X-Frame-Options "DENY"
            }

            handle {
              root public_html
              file_server {
                fs gigglesquidtech
              }
            }
            handle /umami_analytics.js {
              rewrite * /script.js
              reverse_proxy https://cloud.umami.is {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
    };

    alloy-squid = {
      enable = true;
      supplementaryGroups = [ "caddy" ];
      alloyConfig = # river
        ''
          discovery.relabel "caddy" {
            targets = [{
              __address__ = "localhost:2019",
            }]
            rule {
              target_label = "instance"
              replacement  = constants.hostname
            }
          }

          prometheus.scrape "caddy" {
            targets         = discovery.relabel.caddy.output
            forward_to      = [prometheus.remote_write.metrics_service.receiver]
            scrape_interval = "15s"
            job_name   = "caddy.metrics.scrape"
          }

          local.file_match "caddy_access_log" {
            path_targets = [
              {"__path__" = "/var/log/caddy/*.log"},
            ]
            sync_period = "15s"
          }

          loki.source.file "caddy_access_log" {
            targets    = local.file_match.caddy_access_log.targets
            forward_to = [loki.process.caddy_add_labels.receiver]
            tail_from_end = true
          }

          loki.process "caddy_add_labels" {
            stage.json {
              expressions = {
                level = "",
                ts = "",
                logger = "",
                host = "request.host",
                method = "request.method",
                proto = "request.proto",
                duration = "",
                status = "",
              }
            }

            stage.labels {
              values = {
                level = "",
                logger = "",
                host = "",
                method = "",
                proto = "",
                duration = "",
                status = "",
              }
            }

            stage.static_labels {
              values = {
                job = "loki.source.file.caddy_access_log",
              }
            }

            stage.timestamp {
              source = "ts"
              format = "unix"
            }
           
            forward_to = [loki.write.grafana_loki.receiver]
          }
        '';
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.servers
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
