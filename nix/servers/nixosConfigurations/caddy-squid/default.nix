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
  hostName = "caddy-squid";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
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
      crowdsec_caddy-squid_api_key = { };
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
        "${config.sops.secrets.crowdsec_caddy-squid_api_key.path}"
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
          "github.com/GiggleSquid/caddy-bunny-mirror@v1.5.2-mirror"
          "github.com/mholt/caddy-dynamicdns@v0.0.0-20241025234131-7c818ab3fc34"
          "github.com/mholt/caddy-l4@v0.0.0-20241111225910-3c6cc2c0ee08"
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.8.1"
        ];
        hash = "sha256-ZIKxEGAz2KU/N1TUOVdyyxnFfVMlMEL/ZDw4J1U2PUA=";
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
          servers {
            metrics
          }
          dynamic_dns {
            provider bunny {
              access_key {env.BUNNY_API_KEY}
            }
            domains {
              gigglesquid.tech ddns
              marciandfriends.co.uk @
              thatferret.blog @
            }
            ip_source simple_http https://icanhazip.com
            ip_source simple_http https://api64.ipify.org
            check_interval 5m
            versions ipv4
            ttl 5m
          }
          crowdsec {
            api_url http://crowdsec.lan.gigglesquid.tech:8080
            api_key {env.CROWDSEC_API_KEY}
            ticker_interval 15s
          }
          # layer4 {
          #   0.0.0.0:28967 {
          #     route {
          #       proxy {
          #         upstream 	10.3.0.25:28967
          #       }
          #     }
          #   }
          # }
        '';
      extraConfig = # caddyfile
        ''
          (bunny_acme_settings_gigglesquid_tech) {
            tls {
              dns bunny {
                access_key {env.BUNNY_API_KEY}
                zone gigglesquid.tech
              }
              propagation_timeout -1
            }
          }
          (bunny_acme_settings_marciandfriends_co_uk) {
            tls {
              dns bunny {
                access_key {env.BUNNY_API_KEY}
                zone marciandfriends.co.uk
              }
              propagation_timeout -1
            }
          }
          (bunny_acme_settings_thatferret_blog) {
            tls {
              dns bunny {
                access_key {env.BUNNY_API_KEY}
                zone thatferret.blog
              }
              propagation_timeout -1
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
        "http://squidjelly.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings_gigglesquid_tech
              route {
                crowdsec
                redir https://squidjelly.gigglesquid.tech{uri} permanent
              }
            '';
        };
        "squidjelly.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings_gigglesquid_tech
              route {
                crowdsec
                reverse_proxy https://squidjelly.lan.gigglesquid.tech:8920 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "squidseerr.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings_gigglesquid_tech
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
              import bunny_acme_settings_gigglesquid_tech
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
              import bunny_acme_settings_gigglesquid_tech
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
              import bunny_acme_settings_gigglesquid_tech
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://search.lan.gigglesquid.tech:8080 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "www.marciandfriends.co.uk" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings_marciandfriends_co_uk
              route {
                crowdsec
               redir https://marciandfriends.co.uk{uri} permanent
              }
            '';
        };
        "http://www.marciandfriends.co.uk" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings_marciandfriends_co_uk
              route {
                crowdsec
                redir https://marciandfriends.co.uk{uri} permanent
              }
            '';
        };
        "marciandfriends.co.uk" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings_marciandfriends_co_uk
              handle_path /errors* {
                root * /etc/caddy/marciandfriends.co.uk/http/errors
                file_server
              }
              # odoochat
              @websocket {
                header Connection *Upgrade*
                header Upgrade websocket
              }
              route @websocket {
                crowdsec
                reverse_proxy marciandfriends.lan.gigglesquid.tech:8072
              }
              route {
                crowdsec
                reverse_proxy marciandfriends.lan.gigglesquid.tech:8069 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "http://www.thatferret.blog" = {
          extraConfig = # caddyfile
            ''
              route {
                crowdsec
                redir https://thatferret.blog{uri} permanent
              }
            '';
        };
        "www.thatferret.blog" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings_thatferret_blog
              route {
                crowdsec
                redir https://thatferret.blog{uri} permanent
              }
            '';
        };
        "http://thatferret.blog" = {
          extraConfig = # caddyfile
            ''
              route {
                crowdsec
                redir https://thatferret.blog{uri} permanent
              }
            '';
        };
        "thatferret.blog" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings_thatferret_blog
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
        "--server.http.listen-addr=10.3.1.10:12345"
      ];
    };
  };

  environment.etc."alloy/config.alloy".text = ''
    prometheus.exporter.unix "local_system" { }

    prometheus.scrape "scrape_metrics" {
      targets         = prometheus.exporter.unix.local_system.targets
      forward_to      = [prometheus.relabel.filter_metrics.receiver]
      scrape_interval = "15s"
    }

    prometheus.relabel "filter_metrics" {
      forward_to = [prometheus.remote_write.metrics_service.receiver]
    }

    prometheus.remote_write "metrics_service" {
      endpoint {
        url = "https://prometheus.otel.lan.gigglesquid.tech/api/v1/write"
        basic_auth {
          username = "admin"
          password_file = "${config.sops.secrets.prometheus_basic_auth.path}"
        }
      }
    }

    loki.source.journal "journal" {
      forward_to = [loki.process.filter_journal.receiver]
    }
     
    loki.process "filter_journal" {
      forward_to = [loki.write.grafana_loki.receiver]
    }

    local.file_match "caddy_access_log" {
      path_targets = [
        {"__path__" = "/var/log/caddy/access.log"},
      ]
      sync_period = "15s"
    }
     
    loki.source.file "caddy_scrape" {
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
          job = "caddy_access_log",
          service_name = "caddy-squid",
        }
      }

      stage.timestamp {
        source = "ts"
        format = "unix"
      }
     
      forward_to = [loki.write.grafana_loki.receiver]
    }

    loki.write "grafana_loki" {
      endpoint {
        url = "https://loki.otel.lan.gigglesquid.tech/loki/api/v1/push"
        //basic_auth {
        //  username = "admin"
        //  password_file = ""
        //}
      }
    }
  '';

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
        home.stateVersion = "24.05";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "24.05";
      };
    };
  };

  system.stateVersion = "24.05";
}
