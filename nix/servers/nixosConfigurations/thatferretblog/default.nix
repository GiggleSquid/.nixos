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
  hostName = "thatferretblog";
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
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:101";
        };
        address = [
          "10.3.1.101/23"
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
      ipv6_prefix_env = {
        owner = "caddy";
      };
      bunny_dns_api_key_caddy = {
        owner = "caddy";
      };
    };
  };

  systemd.services.caddy.serviceConfig = {
    ExecStartPre = ''${lib.getExe' nixpkgs.coreutils "sleep"} 5'';
    EnvironmentFile = [
      "${config.sops.secrets.ipv6_prefix_env.path}"
      "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
    ];
  };

  services = {
    caddy = {
      enable = true;
      package = nixpkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/bunny@v1.2.0"
          "github.com/mohammed90/caddy-git-fs@v0.0.0-20240805164056-529acecd1830"
        ];
        hash = "sha256-OinmgDw9g+ZaFfbyBESr+o3bwi9B2CfQS7+ZBVnD1yY=";
      };
      logFormat = ''
        output file /var/log/caddy/access.log {
          mode 640
        }
        level INFO
      '';
      email = "jack.connors@protonmail.com";
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      globalConfig = # caddyfile
        ''
          metrics
          filesystem thatferretblog git https://github.com/GiggleSquid/thatferretblog {
            refresh_period 60s
          }
        '';
      extraConfig = # caddyfile
        ''
          (bunny_acme_settings) {
            tls {
              dns bunny {env.BUNNY_API_KEY}
              resolvers 9.9.9.9 149.112.112.112
            }
          }
          (deny_non_local) {
            @denied not remote_ip private_ranges {env.IPV6_PREFIX}
            handle @denied {
              abort
            }
          }
        '';
      virtualHosts = {
        "thatferret.blog.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              encode zstd gzip

              @static-assets {
                file
                path *.js *.css
              }
              header @static-assets {
                Cache-Control "max-age=15768000"
                Vary "Accept-Encoding"
              }

              @static-fonts {
                file
                path *.ttf *.otf *.woff *.woff2
              }
              header @static-fonts {
                Cache-Control "max-age=15768000"
                Vary "Accept-Encoding"
              }

              @static-images {
                file
                path *.jpg *.jpeg *.png *.gif *.webp *.avif *.ico *.svg
              }
              header @static-images {
                Cache-Control "max-age=31536000"
                Vary "Accept-Encoding"
              }
              handle {
                root public_html
                file_server {
                  fs thatferretblog
                }
              }
              handle_errors {
                rewrite * /{err.status_code}.html
                file_server {
                  fs thatferretblog
                }
              }
            '';
        };
      };
    };

    alloy-squid = {
      enable = true;
      listenAddr = "10.3.1.101";
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
              {"__path__" = "/var/log/caddy/access.log"},
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
                logger = "",
                host = "request.host",
                method = "request.method",
                proto = "request.proto",
                ts = "",
              }
            }

            stage.labels {
              values = {
                level = "",
                logger = "",
                host = "",
                method = "",
                proto = "",
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
