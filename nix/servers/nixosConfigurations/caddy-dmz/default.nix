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
  hostName = "dmz";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "caddy.lan.gigglesquid.tech";
    nameservers = [ "10.100.0.1" ];
    firewall = {
      enable = true;
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
          "github.com/caddy-dns/bunny@v1.1.3-0.20250204130652-0099cab6eaad"
          "github.com/mholt/caddy-dynamicdns@v0.0.0-20241025234131-7c818ab3fc34"
          "github.com/mholt/caddy-l4@v0.0.0-20250124234235-87e3e5e2c7f9"
          "github.com/digilolnet/caddy-bunny-ip@v0.0.0-20250118080727-ef607b8e1644"
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.8.1"
        ];
        hash = "sha256-16KM+WrhriThYE+wbs1Qcl+0MNnGyf0pOXVO3LLWNiI=";
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
          dynamic_dns {
            provider bunny {env.BUNNY_API_KEY}
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
          (deny_non_local) {
            @denied not remote_ip private_ranges
            handle @denied {
              abort
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
        "www.marciandfriends.co.uk" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                redir https://marciandfriends.co.uk{uri} permanent
              }
            '';
        };
        "marciandfriends.co.uk" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                reverse_proxy https://marciandfriends.co.uk.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
        "www.thatferret.blog" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              route {
                crowdsec
                redir https://thatferret.blog{uri} permanent
              }
            '';
        };
        "thatferret.blog" = {
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
      };
    };

    alloy-squid = {
      enable = true;
      listenAddr = "10.100.0.10";
      supplementaryGroups = [ "caddy" ];
      alloyConfig = # river
        ''
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
        api_url = "http://crowdsec.lan.gigglesquid.tech:8080";
      };
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
