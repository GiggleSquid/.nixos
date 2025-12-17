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
  hostName = "search";
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
          Token = "static:::1:50";
        };
        address = [
          "10.3.1.50/23"
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
      "searxng_env_vars" = { };
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      SupplementaryGroups = [ "searx" ];
    };
    searx-init = {
      script = ''
        ln -sf /etc/searxng/favicons.toml /run/searx/
      '';
    };
  };

  services = {
    searx = {
      enable = true;
      redisCreateLocally = true;
      environmentFile = config.sops.secrets."searxng_env_vars".path;
      configureUwsgi = true;
      uwsgiConfig = {
        socket = "/run/searx/searx.sock";
        chmod-socket = "660";
      };
      settings = {
        search = {
          safe_search = 0;
          autocomplete = "duckduckgo";
          favicon_resolver = "duckduckgo";
          default_lang = "en-GB";
        };
        server = {
          base_url = "https://search.lan.gigglesquid.tech";
          secret_key = "$SEARX_SECRET_KEY";
          method = "GET";
          public_instance = false;
          limiter = false;
        };
        engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
          "nixos wiki".disabled = false;
          "codeberg".disabled = false;
          "gitea.com".disabled = false;
          "gitlab".disabled = false;
          "caddy.community".disabled = false;
          "npm".disabled = false;
          "crates.io".disabled = false;
          "annas archive".disabled = false;
          "reddit".disabled = false;
          "duckduckgo images".disabled = false;
          "duckduckgo videos".disabled = false;
        };
      };
      faviconsSettings = {
        favicons = {
          cfg_schema = 1;
          cache = {
            db_url = "/var/cache/searx/faviconcache.db";
            LIMIT_TOTAL_BYTES = 2147483648;
            HOLD_TIME = 2592000;
            BLOB_MAX_BYTES = 40960;
            MAINTENANCE_MODE = "auto";
            MAINTENANCE_PERIOD = 3600;
          };
        };
      };
    };

    caddy-squid = {
      enable = true;
      plugins = {
        extra = [
          "github.com/BadAimWeeb/caddy-uwsgi-transport@v0.0.0-20240317192154-74a1008b9763"
        ];
        hash = "sha256-SXmQSoZTrty1dMd7DVXQWjAd9lGlZdzoFIOAfrOdvqE=";
      };
    };
    caddy.virtualHosts = {
      "search.lan.gigglesquid.tech" =
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
              handle {
                reverse_proxy unix/${config.services.uwsgi.instance.vassals.searx.socket} {
                  transport uwsgi {
                    uwsgi_param HTTP_X_SCRIPT_NAME ""
                  }
                }
              }
              handle_path /static/ {
                root "${config.services.searx.package}/share/static/*"
                file_server
              }
            '';
        };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.servers ];
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
