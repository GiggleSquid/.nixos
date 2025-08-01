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
    firewall = {
      allowedTCPPorts = [
        80
        443
        25565
        25566
        12345
      ];
      allowedUDPPorts = [
        443
        25566
      ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:10";
        };
        address = [
          "10.3.1.10/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
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
      ipv6_prefix_env = {
        owner = "caddy";
      };
      bunny_dns_api_key_caddy = {
        owner = "caddy";
      };
      crowdsec_caddy-internal_caddy_api_key_env = {
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
        "${config.sops.secrets.ipv6_prefix_env.path}"
        "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
        "${config.sops.secrets.crowdsec_caddy-internal_caddy_api_key_env.path}"
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
          "github.com/caddy-dns/bunny@v1.2.0"
          "github.com/digilolnet/caddy-bunny-ip@v0.0.0-20250118080727-ef607b8e1644"
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.8.1"
        ];
        hash = "sha256-SsRD1SfCFOW3q4/ZmJMcbmqxw1/C2w/JPm3CtLYyLw8=";
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
            api_url https://crowdsec.lan.gigglesquid.tech:8443
            api_key {env.CROWDSEC_CADDY_INTERNAL_CADDY_API_KEY}
            ticker_interval 15s
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
        "search.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://searx.lan.gigglesquid.tech:8080 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
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
        "squidcasts.internal.caddy.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy https://squidcasts.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "qbittorrent.squidbit.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:8080 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "nzbget.squidbit.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:6791 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "radarr.squidbit.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:7777 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "sonarr.squidbit.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:8888 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "prowlarr.squidbit.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:9595 {
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
        "warrior-1.archiveteam.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8001 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "warrior-2.archiveteam.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8002 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "warrior-3.archiveteam.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8003 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "warrior-4.archiveteam.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8004 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "warrior-5.archiveteam.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8005 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        # "marciandfriends.co.uk.internal.caddy.lan.gigglesquid.tech" = {
        #   extraConfig = # caddyfile
        #     ''
        #       import bunny_acme_settings
        #       # odoochat
        #       @websocket {
        #         header Connection *Upgrade*
        #         header Upgrade websocket
        #       }
        #       route @websocket {
        #         crowdsec
        #         reverse_proxy marciandfriends.lan.gigglesquid.tech:8072 {
        #           header_up Host {upstream_hostport}
        #         }
        #       }
        #       route {
        #         crowdsec
        #         reverse_proxy marciandfriends.lan.gigglesquid.tech:8069 {
        #           header_up Host {upstream_hostport}
        #         }
        #       }
        #     '';
        # };
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
        "gigglesquid.tech.internal.caddy.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://gigglesquid.tech.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      };
    };

    alloy-squid = {
      enable = true;
      listenAddr = "10.3.1.10";
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
