{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) nixpkgs;
  inherit (cell) serverSuites;
  lib = nixpkgs.lib;
in
{
  imports = lib.concatLists [ serverSuites.caddy-server ];

  services = {
    caddy-squid = {
      enable = true;
      plugins = {
        extra = [
          "github.com/pberkel/caddy-storage-redis@v1.5.0"
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.9.2"
          "github.com/mholt/caddy-l4@v0.0.0-20260104223739-97fa8c1b6618"
          "github.com/tuzzmaniandevil/caddy-dynamic-clientip@v1.0.5"
        ];
        hash = "sha256-0W5I2d9BUwALRFULbpWgyGRZNiX4iwITGI/znk98UgM=";
      };
      extraGlobalConfig = # caddyfile
        ''
          storage redis cluster {
            address {
              valkey-a.dmz-0.caddy.lan.gigglesquid.tech:6380
              valkey-b.dmz-0.caddy.lan.gigglesquid.tech:6381
              valkey-c.dmz-0.caddy.lan.gigglesquid.tech:6382
              valkey-a.dmz-1.caddy.lan.gigglesquid.tech:6380
              valkey-b.dmz-1.caddy.lan.gigglesquid.tech:6381
              valkey-c.dmz-1.caddy.lan.gigglesquid.tech:6382
              valkey-a.dmz-2.caddy.lan.gigglesquid.tech:6380
              valkey-b.dmz-2.caddy.lan.gigglesquid.tech:6381
              valkey-c.dmz-2.caddy.lan.gigglesquid.tech:6382
            }
            username {$CADDY_DMZ_VALKEY_USER}
            password {$CADDY_DMZ_VALKEY_PASS}
            db 0
            timeout 5
            key_prefix "caddy"
            encryption_key {$CADDY_DMZ_VALKEY_CRYPT_KEY}
            compression true
            route_by_latency true
            # tls_enabled true
            # tls_insecure false
          }

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
      # "cfwrs.gigglesquid.tech" =
      #   { name, ... }:
      #   {
      #     logFormat = ''
      #       output file ${config.services.caddy.logDir}/access-${
      #         lib.replaceStrings [ "/" " " ] [ "_" "_" ] name
      #       }.log {
      #         mode 640
      #       }
      #       level INFO
      #       format json
      #     '';
      #     extraConfig = # caddyfile
      #       ''
      #         import bunny_acme_settings
      #         route {
      #           crowdsec
      #           reverse_proxy https://cfwrs.org.uk.internal.caddy.lan.gigglesquid.tech {
      #             header_up Host {upstream_hostport}
      #           }
      #         }
      #       '';
      #   };
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
  };
}
