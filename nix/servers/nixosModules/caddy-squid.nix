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
in
{
  options.services.caddy-squid = {
    enable = lib.mkEnableOption (lib.mdDoc "caddy-squid");

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
        default = "sha256-c9IIAQjdBXHqLZIn/iwjMJHEuFZ7XMLJz7lRXcKjSzc=";
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
          "github.com/fvbommel/caddy-combine-ip-ranges@v0.0.2-0.20240127132546-5624d08f5f9e"
        ]
        ++ cfg.plugins.extra;
        hash = cfg.plugins.hash;
      };
      email = lib.mkDefault "jack.connors@protonmail.com";
      acmeCA = lib.mkDefault "https://acme-v02.api.letsencrypt.org/directory";
      logFormat = lib.mkDefault ''
        output file /var/log/caddy/access-global.log {
          mode 640
        }
        level INFO
      '';
      globalConfig = # caddyfile
      ''
        metrics
        servers {
          trusted_proxies combine {
            bunny {
              interval 6h
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
      + cfg.extraGlobalConfig;

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
        (trusted_ips) {
          not client_ip private_ranges {env.IPV4_STATIC} {env.IPV4_SUBNET} {env.IPV6_PREFIX}
        }
      ''
      + cfg.extraExtraConfig;
    };
  };
}
