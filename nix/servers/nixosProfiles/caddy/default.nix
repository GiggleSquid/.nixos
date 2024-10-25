{ inputs, config }:
let
  inherit (inputs) nixpkgs self;
  inherit (inputs.cells.toolchain) pkgs;
in
{

  sops.secrets = {
    bunny_dns_api_key_caddy = {
      sopsFile = "${self}/sops/squid-rig.yaml";
      owner = "caddy";
    };
  };

  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = [
      "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
    ];
  };

  environment.etc = {
    "caddy/marciandfriends.co.uk/http/errors/503.html" = {
      source = ././503.html;
      mode = "0650";
      user = "caddy";
      group = "caddy";
    };
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      caddyModules = [
        {
          name = "dns-providers-bunny";
          repo = "lab.zugriff.eu/caddy/bunny";
          version = "5f07933028e209571f85e833a5b18e49d79fd600";
        }
        {
          name = "dynamic-dns";
          repo = "github.com/mholt/caddy-dynamicdns";
          version = "d8dab1bbf3fc592032f71dacc14510475b4e3e9a";
        }
        {
          name = "caddy-l4";
          repo = "github.com/mholt/caddy-l4";
          version = "3d22d6da412883875f573ee4ecca3dbb3fdf0fd0";
        }
      ];
      vendorHash = "sha256-/OR+paTwlc87NcBPMP8ddtO+ZWN1sgcE5UI6igkv+mQ=";
    };
    logFormat = ''
      level DEBUG
    '';
    email = "jack.connors@protonmail.com";
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    globalConfig = # caddyfile
      ''
        dynamic_dns {
          provider bunny {
            access_key {env.BUNNY_API_KEY}
          }
          domains {
            gigglesquid.tech ddns
            marciandfriends.co.uk @
          }
          ip_source simple_http https://icanhazip.com
          ip_source simple_http https://api64.ipify.org
          check_interval 5m
          versions ipv4
          ttl 5m
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
            import bunny_acme_settings_gigglesquid_tech
            import deny_non_local
            handle {
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
            import deny_non_local
            handle {
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
            handle {
              reverse_proxy http://squidcasts.lan.gigglesquid.tech:8000 {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "www.marciandfriends.co.uk" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_marciandfriends_co_uk
            redir https://marciandfriends.co.uk{uri} permanent
          '';
      };
      "http://www.marciandfriends.co.uk" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_marciandfriends_co_uk
            redir https://marciandfriends.co.uk{uri} permanent
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
            handle @websocket {
              reverse_proxy marciandfriends.lan.gigglesquid.tech:8072
            }
            handle {
              reverse_proxy marciandfriends.lan.gigglesquid.tech:8069 {
                header_up Host {upstream_hostport}
              }
            }
            handle_errors 502 503 504 {
              root * /etc/caddy/marciandfriends.co.uk/http/errors
              rewrite * /503.html
              respond * 503
              file_server
            }
          '';
      };
    };
  };
}
