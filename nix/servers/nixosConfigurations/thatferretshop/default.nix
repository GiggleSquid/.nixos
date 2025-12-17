{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs;
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

  systemd.services = {
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

    caddy-squid = {
      enable = true;
    };
    caddy.virtualHosts = {
      "thatferret.shop.lan.gigglesquid.tech" =
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

              encode zstd gzip
              root /srv/www/thatferretshop
              php_fastcgi unix/${config.services.phpfpm.pools.thatferretshop.socket} {
                header_up Host thatferret.shop
              }
              file_server

              header {
                # Remove headers
                -X-Powered-By

                # Add headers
                # Content-Security-Policy-Report-Only "default-src 'self' https://cdn.thatferret.shop; upgrade-insecure-requests; frame-ancestors 'self'; style-src 'self' 'unsafe-inline' https://cdn.thatferret.shop; "
                Cross-Origin-Embedder-Policy "require-corp"
                Cross-Origin-Opener-Policy "same-origin"
                Cross-Origin-Resource-Policy "same-site"
                Permissions-Policy "interest-cohort=(), camera=(), microphone=(), geolocation=()"
                Referrer-Policy "strict-origin-when-cross-origin"
                Strict-Transport-Security "max-age=2592000; includeSubDomains"
                X-Content-Type-Options "nosniff"
                X-Frame-Options "SAMEORIGIN"
              }

              header /wp-admin/* {
                >Cross-Origin-Embedder-Policy "unsafe-none"
              }

              @static-assets {
                file
                path *.js *.css
              }
              header @static-assets {
                Cache-Control "max-age=86400"
                Vary "Accept-Encoding"
              }

              @static-fonts {
                file
                path *.ttf *.otf *.woff *.woff2
              }
              header @static-fonts {
                Cache-Control "max-age=86400"
                Vary "Accept-Encoding"
              }

              @static-images {
                file
                path *.jpg *.jpeg *.png *.gif *.webp *.avif *.ico *.svg
              }
              header @static-images {
                Cache-Control "max-age=86400"
                Vary "Accept-Encoding"
              }

              @wp-cache {
                not header_regexp Cookie "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_logged_in|woocommerce_items_in_cart|wp_woocommerce_session|woocommerce_cart_hash|woocommerce_recently_viewed"
                not path_regexp "(/wp-admin/|/xmlrpc.php|/wp-(app|cron|login|register|mail).php|wp-.*.php|/feed/|index.php|wp-comments-popup.php|wp-links-opml.php|wp-locations.php|sitemap(index)?.xml|[a-z0-9-]+-sitemap([0-9]+)?.xml|/basket/|/checkout/|/my-account/)"
                not method POST
                not expression {query} != '''
              }
              # route @wp-cache {
              #   try_files /wp-content/cache/cache-enabler/{host}{uri}/https-index.html /wp-content/cache/cache-enabler/{host}{uri}/index.html {path} {path}/index.php?{query}
              # }

              @dotfiles {
                not path /.well-known/*
                path_regexp /\.
              }
              error @dotfiles "403 - Forbidden" 403

              @forbidden {
                path /.user.ini
                path /xmlrpc.php
                path *.sql
                path *.sqllite

                path /wp-config.php
                path /wp-admin/includes/*.php
                path /wp-includes/*.php

                path /wp-content/debug.log
                path /wp-content/uploads/*.php
                path /wp-content/uploads/crowdsec/logs/*
                path /wp-content/uploads/crowdsec/cache/*
                path /wp-content/uploads/crowdsec/inc/standalone-settings.php
              }
              error @forbidden "403 - Forbidden" 403

              @blacklist {
                import not_trusted_ips
                path /wp-login.php
              }
              error @blacklist "403 - Forbidden" 403

              handle_errors 403 {
                rewrite * /403.html
                file_server
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
