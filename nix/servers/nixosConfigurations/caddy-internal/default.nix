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
  hostName = "internal";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "caddy.lan.gigglesquid.tech";
    nameservers = [ "10.3.0.1" ];
    firewall = {
      allowedTCPPorts = [
        80
        443
        25565
        25566
        28967
        12345
      ];
      allowedUDPPorts = [
        443
        25566
        28967
      ];
    };
  };

  users = {
    users.alloy = {
      group = "alloy";
      isSystemUser = true;
    };
    groups.alloy = { };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key_caddy = {
        owner = "caddy";
      };
      crowdsec_caddy-internal_api_key_env = {
        owner = "caddy";
      };
      prometheus_basic_auth = {
        mode = "0440";
        owner = "alloy";
      };
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
        "${config.sops.secrets.crowdsec_caddy-internal_api_key_env.path}"
      ];
    };
    alloy.serviceConfig = {
      SupplementaryGroups = [
        "alloy"
        "caddy"
      ];
    };
  };

  services = {
    caddy = {
      enable = true;
      package = nixpkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/bunny@v1.1.3-0.20250204130652-0099cab6eaad"
          "github.com/digilolnet/caddy-bunny-ip@v0.0.0-20250118080727-ef607b8e1644"
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.8.1"
        ];
        hash = "sha256-+aLgsiIUbrXuFvKD2Z3jGBBiuHKV0OWNunDqkujhihs=";
      };
      email = "jack.connors@protonmail.com";
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      logFormat = ''
        output file /var/log/caddy/access.log {
          mode 640
        }
        level INFO
      '';
      globalConfig = # caddyfile
        ''
          metrics
          servers {
            trusted_proxies bunny {
              interval 6h
              timeout 25s
            }
          }
          crowdsec {
            api_url http://crowdsec.lan.gigglesquid.tech:8080
            api_key {env.CROWDSEC_CADDY_INTERNAL_API_KEY}
            ticker_interval 15s
          }
        '';
      extraConfig = # caddyfile
        ''
          (bunny_acme_settings) {
            tls {
              dns bunny {env.BUNNY_API_KEY}
            }
          }
          (deny_non_local) {
            @denied not remote_ip private_ranges
            handle @denied {
              abort
            }
          }
        '';
      virtualHosts = {
        "squidjelly.internal.caddy.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://squidjelly.lan.gigglesquid.tech:8920 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "squidseerr.internal.caddy.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy http://squidjelly.lan.gigglesquid.tech:5055 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "squidcasts.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://squidcasts.lan.gigglesquid.tech:8000 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "storj-node.cephalonas.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://10.3.0.25:20909 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "search.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://search.lan.gigglesquid.tech:8080 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "marciandfriends.co.uk.internal.caddy.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              # odoochat
              @websocket {
                header Connection *Upgrade*
                header Upgrade websocket
              }
              route @websocket {
                crowdsec
                reverse_proxy marciandfriends.lan.gigglesquid.tech:8072 {
                  header_up Host {upstream_hostport}
                }
              }
              route {
                crowdsec
                reverse_proxy marciandfriends.lan.gigglesquid.tech:8069 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "thatferret.blog.internal.caddy.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://thatferret.blog.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "http://thatferret.local.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import deny_non_local
              route {
                reverse_proxy http://10.10.0.10:1313 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      };
    };

    alloy = {
      enable = true;
      extraFlags = [
        "--disable-reporting"
        "--server.http.listen-addr=10.3.0.10:12345"
      ];
    };
  };

  # environment.etc."alloy/config.alloy".text = ''
  #   prometheus.exporter.unix "local_system" { }

  #   prometheus.scrape "scrape_metrics" {
  #     targets         = prometheus.exporter.unix.local_system.targets
  #     forward_to      = [prometheus.relabel.filter_metrics.receiver]
  #     scrape_interval = "15s"
  #   }

  #   prometheus.relabel "filter_metrics" {
  #     forward_to = [prometheus.remote_write.metrics_service.receiver]
  #   }

  #   prometheus.remote_write "metrics_service" {
  #     endpoint {
  #       url = "https://prometheus.otel.lan.gigglesquid.tech/api/v1/write"
  #       basic_auth {
  #         username = "admin"
  #         password_file = "${config.sops.secrets.prometheus_basic_auth.path}"
  #       }
  #     }
  #   }

  #   loki.source.journal "journal" {
  #     forward_to = [loki.process.filter_journal.receiver]
  #   }

  #   loki.process "filter_journal" {
  #     forward_to = [loki.write.grafana_loki.receiver]
  #   }

  #   local.file_match "caddy_access_log" {
  #     path_targets = [
  #       {"__path__" = "/var/log/caddy/access.log"},
  #     ]
  #     sync_period = "15s"
  #   }

  #   loki.source.file "caddy_scrape" {
  #     targets    = local.file_match.caddy_access_log.targets
  #     forward_to = [loki.process.caddy_add_labels.receiver]
  #     tail_from_end = true
  #   }

  #   loki.process "caddy_add_labels" {
  #     stage.json {
  #       expressions = {
  #         level = "",
  #         logger = "",
  #         host = "request.host",
  #         method = "request.method",
  #         proto = "request.proto",
  #         ts = "",
  #       }
  #     }

  #     stage.labels {
  #       values = {
  #         level = "",
  #         logger = "",
  #         host = "",
  #         method = "",
  #         proto = "",
  #       }
  #     }

  #     stage.static_labels {
  #       values = {
  #         job = "caddy_access_log",
  #         service_name = "caddy-internal",
  #       }
  #     }

  #     stage.timestamp {
  #       source = "ts"
  #       format = "unix"
  #     }

  #     forward_to = [loki.write.grafana_loki.receiver]
  #   }

  #   loki.write "grafana_loki" {
  #     endpoint {
  #       url = "https://loki.otel.lan.gigglesquid.tech/loki/api/v1/push"
  #       //basic_auth {
  #       //  username = "admin"
  #       //  password_file = ""
  #       //}
  #     }
  #   }
  # '';

  imports =
    let
      profiles = [
        hardwareProfiles.servers
      ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
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
