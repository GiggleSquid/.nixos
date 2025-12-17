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
  hostName = "dmz-0";
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
        # 25565
        # 25566
      ];
      allowedUDPPorts = [
        443
        # 25566
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
      crowdsec_bouncer_api_keys_env = { };
      "crowdsec_bouncer_api_keys/caddy_dmz_firewall" = { };
      "valkey/caddy-dmz/env" = { };
      "valkey/caddy-dmz/pass" = { };
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
        "${config.sops.secrets."valkey/caddy-dmz/env".path}"
      ];
    };
  };

  services = {
    redis = {
      package = nixpkgs.valkey;
      servers = {
        dmz-0-a = {
          enable = true;
          port = 6380;
          appendOnly = true;
          requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          settings = {
            cluster-enabled = true;
            cluster-databases = 1;
            cluster-announce-hostname = "valkey-a.dmz-0.caddy.lan.gigglesquid.tech";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
        dmz-0-b = {
          enable = true;
          port = 6381;
          appendOnly = true;
          requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          settings = {
            cluster-enabled = true;
            cluster-databases = 1;
            cluster-announce-hostname = "valkey-b.dmz-0.caddy.lan.gigglesquid.tech";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
        dmz-0-c = {
          port = 6382;
          enable = true;
          appendOnly = true;
          requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          settings = {
            cluster-enabled = true;
            cluster-databases = 1;
            cluster-announce-hostname = "valkey-c.dmz-0.caddy.lan.gigglesquid.tech";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
      };
    };
    caddy-squid = {
      enable = true;
      plugins = {
        extra = [
          "github.com/pberkel/caddy-storage-redis@v1.5.0"
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.9.2"
          "github.com/mholt/caddy-l4@v0.0.0-20251001194302-2e3e6cf60b25"
          "github.com/tuzzmaniandevil/caddy-dynamic-clientip@v1.0.5"
        ];
        hash = "sha256-aOcRv3eQBxIUpA6YrPLK3vVb7CzltAe/yh3++9mncsU=";
      };
      extraGlobalConfig = # caddyfile
        ''
          # storage redis cluster {
          #   address {
          #     valkey-a.dmz-0.caddy.lan.gigglesquid.tech:6380
          #     valkey-b.dmz-0.caddy.lan.gigglesquid.tech:6381
          #     valkey-c.dmz-0.caddy.lan.gigglesquid.tech:6382
          #     valkey-a.dmz-1.caddy.lan.gigglesquid.tech:6380
          #     valkey-b.dmz-1.caddy.lan.gigglesquid.tech:6381
          #     valkey-c.dmz-1.caddy.lan.gigglesquid.tech:6382
          #     valkey-a.dmz-2.caddy.lan.gigglesquid.tech:6380
          #     valkey-b.dmz-2.caddy.lan.gigglesquid.tech:6381
          #     valkey-c.dmz-2.caddy.lan.gigglesquid.tech:6382
          #   }
          #   username {env.CADDY_DMZ_VALKEY_USER}
          #   password {env.CADDY_DMZ_VALKEY_PASS}
          #   db 0
          #   timeout 5
          #   key_prefix "caddy"
          #   encryption_key ""
          #   compression true
          #   tls_enabled true
          #   tls_insecure false
          # }

          crowdsec {
            api_url https://crowdsec.lan.gigglesquid.tech:8443
            # appsec_url https://crowdsec.lan.gigglesquid.tech:7422
            api_key {env.CROWDSEC_CADDY_DMZ_CADDY_API_KEY}
            ticker_interval 15s
          }
        '';
      extraExtraConfig = # caddyfile
        ''
          (deny_not_bunny_edge) {
            @denied {
              not dynamic_client_ip bunny {
                interval 1h
                timeout 25s
              }
              import not_trusted_ips
            }
            handle @denied {
              abort
            }
          }
        '';
    };
    caddy.virtualHosts = {
      "squidjelly.gigglesquid.tech" =
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
                reverse_proxy https://squidjelly.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "squidseerr.gigglesquid.tech" =
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
                reverse_proxy https://squidseerr.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "squidcasts.gigglesquid.tech" =
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
                reverse_proxy https://squidcasts.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "old.cfwrs.gigglesquid.tech" =
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
                reverse_proxy https://old.cfwrs.org.uk.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "cfwrs.gigglesquid.tech" =
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
                reverse_proxy https://cfwrs.org.uk.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "origin.thatferret.blog" =
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
              import common_well-known
              # import deny_not_bunny_edge
              route {
                crowdsec
                reverse_proxy https://thatferret.blog.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "thatferret.shop" =
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
              import common_well-known
              route {
                crowdsec
                reverse_proxy https://thatferret.shop.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "origin.gigglesquid.tech" =
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
              import common_well-known
              # import deny_not_bunny_edge
              route {
                crowdsec
                reverse_proxy https://gigglesquid.tech.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "umami.gigglesquid.tech" =
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
                reverse_proxy https://umami.internal.caddy.lan.gigglesquid.tech {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "idm.gigglesquid.tech" =
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
                reverse_proxy https://idm.internal.caddy.lan.gigglesquid.tech {
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

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_url = "https://crowdsec.lan.gigglesquid.tech:8443";
      };
      secrets = {
        apiKeyPath = "${config.sops.secrets."crowdsec_bouncer_api_keys/caddy_dmz_firewall".path}";
      };
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
