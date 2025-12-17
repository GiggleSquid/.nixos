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
  hostName = "thatferretblog";
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
          Token = "static:::1:101";
        };
        address = [
          "10.3.1.101/23"
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
          filesystem thatferretblog git https://github.com/GiggleSquid/thatferretblog {
            refresh_period 60s
          }
        '';
    };
    caddy.virtualHosts = {
      "thatferret.blog.lan.gigglesquid.tech" =
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

              @static-assets {
                file
                path *.js *.css
              }
              header @static-assets {
                Cache-Control "max-age=15768000"
                Vary "Accept-Encoding"
              }

              @static-fonts {
                file
                path *.ttf *.otf *.woff *.woff2
              }
              header @static-fonts {
                Cache-Control "max-age=15768000"
                Vary "Accept-Encoding"
              }

              @static-images {
                file
                path *.jpg *.jpeg *.png *.gif *.webp *.avif *.ico *.svg
              }
              header @static-images {
                Cache-Control "max-age=31536000"
                Vary "Accept-Encoding"
              }

              header {
                Content-Security-Policy "default-src 'self' https://thatferret.blog https://origin.thatferret.blog; upgrade-insecure-requests; connect-src 'self' https://thatferret.blog https://origin.thatferret.blog https://umami.gigglesquid.tech https://app.termly.io https://*.api.termly.io; font-src 'self' https://thatferret.blog https://origin.thatferret.blog https://bunnycdn-video-assets.b-cdn.net https://fonts.bunny.net; frame-ancestors 'none'; frame-src https://www.youtube-nocookie.com https://iframe.mediadelivery.net https://ko-fi.com; img-src 'self' https://thatferret.blog https://origin.thatferret.blog https://i.ytimg.com https://storage.ko-fi.com https://mirrors.creativecommons.org; media-src 'self' https://thatferret.blog https://origin.thatferret.blog; style-src 'self' https://thatferret.blog https://origin.thatferret.blog 'unsafe-inline' https://assets.mediadelivery.net https://storage.ko-fi.com https://www.youtube-nocookie.com; script-src 'self' https://thatferret.blog https://origin.thatferret.blog https://umami.gigglesquid.tech https://assets.mediadelivery.net https://app.termly.io https://storage.ko-fi.com 'sha256-Go5RcnylJvBHl0p1MdUOAmiLdIF8QWWhdG4PAs/W6Zo=' 'sha256-wtdPHL8EXHPrs4Mvw2dHBkZsZHCn/HWGuCyLrUtieZc=' 'sha256-YkA1+5qDdgnbLSNRrGbqiRYlWykVOsYmNbysUgkelEM=' 'sha256-2Gc6YhAP0Q8uJJUGqFbu2pJMmDLUP9mTGFFY+cSYT30=' 'sha256-zTiqK3ktmY8JJ2Nh/ue7C9FI3Z0hPldm5U+ejpa7lyY=' 'sha256-b4GhLn2cCogcmsXLxMskA47qNO1kvWKJ7fiaA9U2CCU=' 'sha256-NAZMPWTDAJmyJdoZ1FA7khIy2wTCCvksIAxJ2ey9Lhk=' 'sha256-PNLbuRl0tU+Roxg5MupPATYwV6fOfptb9L/3rSXvOMc=' 'sha256-urJl8yN1NrQRG6FrY6uJQINBxmz/bQ3p+AhlEu+52jU=' 'sha256-qdzpwz0NgvASybV2JzmWCDaIa1CFT7Uld55leDS1yo0=';"
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
                  fs thatferretblog
                }
              }

              handle_errors {
                rewrite * /{err.status_code}.html
                file_server {
                  fs thatferretblog
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
