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
      ];
      allowedUDPPorts = [
        25566
        28967
      ];
    };
  };

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

  services.caddy = {
    enable = true;
    package = nixpkgs.caddy.withPlugins {
      plugins = [
        "github.com/GiggleSquid/caddy-bunny-mirror@v1.5.2-mirror"
        "github.com/mholt/caddy-dynamicdns@v0.0.0-20241025234131-7c818ab3fc34"
        "github.com/mholt/caddy-l4@v0.0.0-20241111225910-3c6cc2c0ee08"
      ];
      hash = "sha256-P+Tt55yGIcuqHft8UBK+J9sD1I0u3kgzAENKrVkaOkQ=";
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
            thatferret.blog @
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
            redir https://squidjelly.gigglesquid.tech{uri} permanent
          '';
      };
      "squidjelly.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_gigglesquid_tech
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
      "storj-node.cephalonas.lan.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_gigglesquid_tech
            import deny_non_local
            handle {
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
            handle {
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
      "http://www.thatferret.blog" = {
        extraConfig = # caddyfile
          ''
            redir https://thatferret.blog{uri} permanent
          '';
      };
      "www.thatferret.blog" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_thatferret_blog
            redir https://thatferret.blog{uri} permanent
          '';
      };
      "http://thatferret.blog" = {
        extraConfig = # caddyfile
          ''
            redir https://thatferret.blog{uri} permanent
          '';
      };
      "thatferret.blog" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_thatferret_blog
            reverse_proxy https://thatferret.blog.lan.gigglesquid.tech {
              header_up Host {upstream_hostport}
            }
          '';
      };
      "http://thatferret.local.lan.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            import deny_non_local
            handle {
              reverse_proxy http://10.10.0.10:1313 {
                header_up Host {upstream_hostport}
              }
            }
          '';
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
