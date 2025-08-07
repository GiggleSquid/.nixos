{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) rpi nixpkgs self;
  inherit (cell) serverSuites hardwareProfiles;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "dmz";
in
{
  inherit (rpi) bee time;
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
        matchConfig.Name = "end0";
        ipv6AcceptRAConfig = {
          Token = "static:::10";
        };
        address = [
          "10.100.0.10/24"
        ];
        gateway = [
          "10.100.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key_caddy = {
        owner = "caddy";
      };
      crowdsec_caddy-dmz_caddy_api_key_env = {
        owner = "caddy";
      };
      crowdsec_caddy-dmz_firewall_api_key_env = { };
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
        "${config.sops.secrets.crowdsec_caddy-dmz_caddy_api_key_env.path}"
      ];
    };
    crowdsec-firewall-bouncer.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_caddy-dmz_firewall_api_key_env.path}"
      ];
    };
  };

  services = {
    caddy = {
      enable = true;
      package = nixpkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/bunny@v1.2.0"
          "github.com/fvbommel/caddy-combine-ip-ranges@v0.0.2-0.20240127132546-5624d08f5f9e"
          "github.com/mholt/caddy-l4@v0.0.0-20250124234235-87e3e5e2c7f9"
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
            trusted_proxies_strict
          }
          crowdsec {
            api_url https://crowdsec.lan.gigglesquid.tech:8443
            api_key {env.CROWDSEC_CADDY_DMZ_CADDY_API_KEY}
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
          (bunny_acme_settings) {
            tls {
              dns bunny {env.BUNNY_API_KEY}
              resolvers 9.9.9.9 149.112.112.112
            }
          }
        '';
      virtualHosts = {
        "squidjelly.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://squidjelly.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "squidseerr.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://squidseerr.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "squidcasts.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://squidcasts.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        # "marciandfriends.co.uk" = {
        #   extraConfig = # caddyfile
        #     ''
        #       import bunny_acme_settings
        #       route {
        #         crowdsec
        #         reverse_proxy https://marciandfriends.co.uk.internal.caddy.lan.gigglesquid.tech {
        #           header_up Host {upstream_hostport}
        #         }
        #       }
        #     '';
        # };
        "origin.thatferret.blog" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://thatferret.blog.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://gigglesquid.tech.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "umami.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://umami.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      };
    };

    alloy-squid = {
      enable = true;
      listenAddr = "10.100.0.10";
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

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_key = ''''${CROWDSEC_CADDY_DMZ_FIREWALL_API_KEY}'';
        api_url = "https://crowdsec.lan.gigglesquid.tech:8443";

      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.rpi4 ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base-rpi
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
