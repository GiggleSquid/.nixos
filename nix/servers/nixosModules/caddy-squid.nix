{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) self nixpkgs;
  lib = nixpkgs.lib;
in
let
  cfg = config.services.caddy-squid;
  mkIfElse =
    p: yes: no:
    lib.mkMerge [
      (lib.mkIf p yes)
      (lib.mkIf (!p) no)
    ];
in
{
  options.services.caddy-squid = {
    enable = lib.mkEnableOption (lib.mdDoc "caddy-squid");

    externalService = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    extraGlobalConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    # I hate this name too
    extraExtraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    plugins = {
      hash = lib.mkOption {
        type = lib.types.str;
        default = "sha256-nPum0sNaoWWlrroZlvJ4cUVNC4zWFac/t78QFpp+06Y=";
      };
      extra = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = lib.mkDefault "${self}/sops/squid-rig.yaml";
      secrets = {
        bunny_dns_api_key_caddy = { };
        ipv6_prefix_env = { };
        ipv4_subnet_env = { };
        ipv4_static_env = { };
      };
    };

    systemd.services = {
      caddy.serviceConfig = {
        ExecStartPre = ''${lib.getExe' nixpkgs.coreutils "sleep"} 10'';
        EnvironmentFile = [
          "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
          "${config.sops.secrets.ipv6_prefix_env.path}"
          "${config.sops.secrets.ipv4_subnet_env.path}"
          "${config.sops.secrets.ipv4_static_env.path}"
        ];
      };
    };

    services.caddy = {
      enable = true;
      package = nixpkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/bunny@v1.2.0"
          "github.com/digilolnet/caddy-bunny-ip@v0.0.0-20250118080727-ef607b8e1644"
          "github.com/fvbommel/caddy-dns-ip-range@v0.0.3-0.20250824174532-f6ba728e351a"
        ]
        ++ (lib.lists.optionals (!cfg.externalService) [
          "github.com/fvbommel/caddy-combine-ip-ranges@v0.0.2-0.20240127132546-5624d08f5f9e"
        ])
        ++ cfg.plugins.extra;
        hash = cfg.plugins.hash;
      };
      email = lib.mkDefault "jack.connors@protonmail.com";
      acmeCA = lib.mkDefault "https://acme-v02.api.letsencrypt.org/directory";
      logFormat = lib.mkDefault ''
        output file /var/log/caddy/global.log {
          mode 640
        }
        level INFO
        format json
      '';
      globalConfig =
        mkIfElse cfg.externalService
          (
            ''
              metrics {
                per_host
              }
              servers {
                trusted_proxies bunny {
                  interval 3h
                  timeout 25s
                }
              }
            ''
            + cfg.extraGlobalConfig
          )
          (
            ''
              metrics
              servers {
                trusted_proxies combine {
                  bunny {
                    interval 3h
                    timeout 25s
                  }
                  dns {
                    interval 15m
                    host dmz.caddy.lan.gigglesquid.tech
                    host internal.caddy.lan.gigglesquid.tech
                  }
                }
              }
            ''
            + cfg.extraGlobalConfig
          );

      extraConfig = # caddyfile
      ''
        (bunny_acme_settings) {
          tls {
            dns bunny {env.BUNNY_API_KEY}
            resolvers 9.9.9.9 149.112.112.112
          }
        }
        (not_trusted_ips) {
          not client_ip private_ranges {env.IPV4_STATIC} {env.IPV4_SUBNET} {env.IPV6_PREFIX} 167.235.72.13 2a01:4f8:1c1a:25f0::10
        }
        (deny_non_local) {
          @denied not remote_ip private_ranges {env.IPV4_STATIC} {env.IPV4_SUBNET} {env.IPV6_PREFIX}
          handle @denied {
            abort
          }
        }
        (common_well-known) {
          handle /.well-known/traffic-advice {
            header Content-Type application/trafficadvice+json
            respond `[{"user_agent":"prefetch-proxy","google_prefetch_proxy_eap":{"fraction":1}}]`
          }
        }
      ''
      + cfg.extraExtraConfig;

      virtualHosts = {
        ":80, :443" =
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
            extraConfig = ''
              respond "Forbidden" 403 {
               close
              }
            '';
          };
      };
    };
  };
}
