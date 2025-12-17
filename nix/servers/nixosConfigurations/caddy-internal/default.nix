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
      crowdsec_bouncer_api_keys_env = { };
      prometheus_basic_auth = {
        mode = "0440";
        owner = "alloy";
      };
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
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
    caddy-squid = {
      enable = true;
      plugins = {
        extra = [
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.9.2"
        ];
        hash = "sha256-HFvhKGVg0kBSnxt1NmI0slmXZjMcLLXphFPtxjjDYFs=";
      };
      extraGlobalConfig = # caddyfile
        ''
          crowdsec {
            api_url https://crowdsec.lan.gigglesquid.tech:8443
            api_key {env.CROWDSEC_CADDY_INTERNAL_CADDY_API_KEY}
            ticker_interval 15s
          }
        '';
    };
    caddy.virtualHosts = {
      "search.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://searx.lan.gigglesquid.tech:8080 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "squidjelly.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://squidjelly.lan.gigglesquid.tech:8096
              }
            '';
        };
      "squidseerr.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://squidjelly.lan.gigglesquid.tech:5055 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "squidcasts.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://squidcasts.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "qbittorrent.squidbit.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:8080 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "nzbget.squidbit.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:6791 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "radarr.squidbit.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:7777 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "sonarr.squidbit.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:8888 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "prowlarr.squidbit.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://squidbit.lan.gigglesquid.tech:9595 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "storj-node.cephalonas.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://10.3.0.25:20909 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "scrutiny.cephalonas.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://10.3.0.25:31054 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "api.rustfs.cephalonas.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://cephalonas.lan.gigglesquid.tech:30292
              }
            '';
        };
      "rustfs.cephalonas.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://cephalonas.lan.gigglesquid.tech:30293
              }
            '';
        };
      "warrior-1.archiveteam.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8001 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "warrior-2.archiveteam.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8002 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "warrior-3.archiveteam.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8003 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "warrior-4.archiveteam.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8004 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "warrior-5.archiveteam.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy http://10.3.1.60:8005 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "thatferret.blog.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://thatferret.blog.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "thatferret.shop.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://thatferret.shop.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "http://thatferret.local.lan.gigglesquid.tech" =
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
              import deny_non_local
              route {
                reverse_proxy http://10.10.0.10:1313 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "gigglesquid.tech.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://gigglesquid.tech.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "old.cfwrs.org.uk.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://old.cfwrs.org.uk.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "cfwrs.org.uk.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://cfwrs.org.uk.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "umami.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://umami.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "idm.internal.caddy.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://idm.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "dash.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://homepage.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "nix-cache.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://ncps.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "local.nix-cache.lan.gigglesquid.tech" =
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
              route {
                crowdsec
                reverse_proxy https://attic.lan.gigglesquid.tech {
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
