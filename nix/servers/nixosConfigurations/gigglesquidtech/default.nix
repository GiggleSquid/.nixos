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
  hostName = "gigglesquid";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "tech.lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [
        443
      ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:100";
        };
        address = [
          "10.3.1.100/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  services = {
    caddy-squid = {
      enable = true;
      plugins = {
        extra = [
          "github.com/mohammed90/caddy-git-fs@v0.0.0-20240805164056-529acecd1830"
        ];
        hash = "sha256-MJZhhtmZ9R4QLotOUC0kqBDjkbvfGjhTPuRrU9z0ECE=";
      };
      extraGlobalConfig = # caddyfile
        ''
          filesystem gigglesquidtech git https://github.com/GiggleSquid/gigglesquidtech {
            refresh_period 60s
          }
        '';
    };
    caddy.virtualHosts = {
      "gigglesquid.tech.lan.gigglesquid.tech" =
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
              @cache-default path_regexp \/.*$
              @cache-images path_regexp \/.*\.(jpg|jpeg|png|gif|webp|ico|svg)$
              @cache-assets path_regexp \/assets\/(js\/.*\.js|css\/.*\.css)$
              @cache-fonts path_regexp \/fonts\/.*\.(ttf|otf|woff|woff2)$
              header @cache-default Cache-Control no-cache
              header @cache-images Cache-Control max-age=2628000
              header @cache-assets Cache-Control max-age=2628000
              header @cache-fonts Cache-Control max-age=15768000

              header {
                Cross-Origin-Embedder-Policy "unsafe-none"
                Cross-Origin-Opener-Policy "same-origin"
                Cross-Origin-Resource-Policy "same-site"
                Permissions-Policy "interest-cohort=(), camera=(), microphone=(), geolocation=()"
                Referrer-Policy "strict-origin-when-cross-origin"
                Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
                X-Content-Type-Options "nosniff"
                X-Frame-Options "DENY"
              }

              handle {
                root public_html
                file_server {
                  fs gigglesquidtech
                }
              }
              handle /umami_analytics.js {
                rewrite * /script.js
                reverse_proxy https://cloud.umami.is {
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
