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
  hostName = "thatferretblog";
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
      ];
      allowedUDPPorts = [
        443
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
        "github.com/mohammed90/caddy-git-fs@v0.0.0-20240805164056-529acecd1830"
      ];
      hash = "sha256-YVcwQKEF06JVHuYWmYFGjPvamZTIbnDRZAUE4PMjztw=";
    };
    logFormat = ''
      level DEBUG
    '';
    email = "jack.connors@protonmail.com";
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    globalConfig = # caddyfile
      ''
        filesystem thatferretblog git https://github.com/GiggleSquid/thatferretblog {
          ref 41feb541c4ee50953d742f3b24159c3758e27ca3
        }
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
        (deny_non_local) {
          @denied not remote_ip private_ranges
          handle @denied {
            abort
          }
        }
      '';
    virtualHosts = {
      "thatferret.blog.lan.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_gigglesquid_tech
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
            handle {
              root public_html
              file_server {
                fs thatferretblog
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
