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
  hostName = "thatferretshop";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [ 443 ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp6s18";
        ipv6AcceptRAConfig = {
          Token = "static:::1:102";
        };
        address = [
          "10.3.1.102/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      ipv6_prefix_env = {
        owner = "caddy";
      };
      ipv4_subnet_env = {
        owner = "caddy";
      };
      bunny_dns_api_key_caddy = { };
    };
  };

  systemd.services = {
    caddy = {
      serviceConfig = {
        ExecStartPre = ''${lib.getExe' nixpkgs.coreutils "sleep"} 5'';
        EnvironmentFile = [
          "${config.sops.secrets.ipv6_prefix_env.path}"
          "${config.sops.secrets.ipv4_subnet_env.path}"
          "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
        ];
      };
    };
    phpfpm.path = [ nixpkgs.imagemagick ];
    "wp-cron" = {
      script = # bash
        ''
          set -eu 

          ${lib.getExe nixpkgs.wget} --delete-after https://thatferret.shop/wp-cron.php
        '';
      serviceConfig = {
        Type = "oneshot";
      };
      startAt = "minutely";
    };
  };

  services = {
    mysql = {
      enable = true;
      package = nixpkgs.mariadb_118;
      ensureDatabases = [ "thatferretshop" ];
      ensureUsers = [
        {
          name = "thatferretshop";
          ensurePermissions = {
            "thatferretshop.*" = "ALL PRIVILEGES";
          };
        }
        {
          name = "backup";
          ensurePermissions = {
            "*.*" = "SELECT, LOCK TABLES";
          };
        }
      ];
    };

    redis.servers.thatferretshop = {
      enable = true;
      port = 6379;
      user = config.services.caddy.user;
      group = config.services.caddy.group;
    };

    phpfpm.pools.thatferretshop = {
      user = config.services.caddy.user;
      group = config.services.caddy.group;
      phpPackage = nixpkgs.php.withExtensions (
        { enabled, all }:
        with all;
        enabled
        ++ [
          redis
          imagick
        ]
      );
      phpOptions = ''
        auto_prepend_file = /srv/www/thatferretshop/wp-content/plugins/crowdsec/inc/standalone-bounce.php
        expose_php off
        max_input_vars 1000
        memory_limit 256M
        post_max_size 64M
        upload_max_filesize 32M
      '';
      settings = {
        "listen.owner" = config.services.caddy.user;
        "listen.group" = config.services.caddy.group;
        "pm" = "static";
        "pm.max_children" = 5;
        "pm.max_requests" = 500;
      };
    };

    caddy = {
      enable = true;
      package = nixpkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/bunny@v1.2.0"
          "github.com/fvbommel/caddy-combine-ip-ranges@v0.0.2-0.20240127132546-5624d08f5f9e"
          "github.com/fvbommel/caddy-dns-ip-range@v0.0.3-0.20230301183658-6facda90c1f7"
          "github.com/digilolnet/caddy-bunny-ip@v0.0.0-20250118080727-ef607b8e1644"
        ];
        hash = "sha256-PSm0DJ+sCb/PGuIqbJ0focJV5vLhdHSNtJiE33DQfqA=";
      };
      logFormat = ''
        output file /var/log/caddy/access.log {
          mode 640
        }
        level INFO
      '';
      email = "jack.connors@protonmail.com";
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
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
          (trusted_ips) {
            not client_ip private_ranges {env.IPV4_SUBNET} {env.IPV6_PREFIX}
          }
        '';
      virtualHosts = {
        "thatferret.shop.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local

              encode zstd gzip
              root /srv/www/thatferretshop
              php_fastcgi unix/${config.services.phpfpm.pools.thatferretshop.socket}
              file_server

              @dotfiles {
                not path /.well-known/*
                path_regexp /\.
              }
              error @dotfiles "403 - Forbidden" 403

              @forbidden {
                path /xmlrpc.php
                path *.sql
                path /wp-config.php
                path /wp-content/uploads/*.php
                path /wp-content/uploads/crowdsec/logs/*
                path /wp-content/uploads/crowdsec/cache/*
                path /wp-content/uploads/crowdsec/inc/standalone-settings.php
              }
              error @forbidden "403 - Forbidden" 403

              @blacklist {
                import trusted_ips
                path /wp-login.php
              }
              error @blacklist "403 - Forbidden" 403

              handle_errors 403 {
                respond "403 - Forbidden" 403 {
                  close
                }
              }
            '';
        };
      };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.vms ];
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
        home.stateVersion = "25.11";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "25.11";
      };
    };
  };

  system.stateVersion = "25.11";
}
