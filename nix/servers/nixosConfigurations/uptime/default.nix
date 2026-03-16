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
  hostName = "uptime";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "gigglesquid.tech";
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
        matchConfig.Name = "enp1s0";
        address = [
          "2a01:4f8:1c1a:25f0::10/64"
          "167.235.72.13/32"
        ];
        routes = [
          { Gateway = "fe80::1"; }
          {
            Gateway = "172.31.1.1";
            GatewayOnLink = true;
          }
        ];
        dns = [
          "2620:fe::fe"
          "2620:fe::9"
          "9.9.9.9"
          "149.112.112.112"
        ];
      };
    };
  };

  zramSwap = {
    memoryPercent = 25;
  };

  # Disable 'local' substituters as this machine is not local
  nix = {
    settings = {
      substituters = lib.mkForce [ "https://cache.nixos.org/" ];
      trusted-public-keys = lib.mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  sops.secrets = {
    crowdsec_bouncer_api_keys_env = { };
    "crowdsec_bouncer_api_keys/uptime_firewall" = { };
  };

  systemd.services = {
    caddy.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
      ];
    };
  };

  services = {
    uptime-kuma = {
      enable = true;
      settings = {
        UPTIME_KUMA_HOST = "::1";
        UPTIME_KUMA_PORT = "3001";
        # UPTIME_KUMA_DB_TYPE = "mariadb";
        # UPTIME_KUMA_DB_SOCKET = "";
        # UPTIME_KUMA_DB_NAME = "uptime-kuma";
        # UPTIME_KUMA_DB_USERNAME_FILE = "";
        # UPTIME_KUMA_DB_PASSWORD_FILE = "";
      };
    };
    caddy-squid = {
      enable = true;
      externalService = true;
      plugins = {
        extra = [
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.10.0"
        ];
        hash = "sha256-iiltx/txuK4rHECJRdHbNwXm6il/o+RgsgrRo00a7nM=";
      };
      extraGlobalConfig = # caddyfile
        ''
          crowdsec {
            api_url https://crowdsec.gigglesquid.tech:8443
            # appsec_url https://crowdsec.gigglesquid.tech:7422
            api_key {env.CROWDSEC_UPTIME_CADDY_API_KEY}
            ticker_interval 15s
          }
        '';
    };
    caddy.virtualHosts = {
      "uptime.gigglesquid.tech" =
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
              encode zstd gzip
              route {
                reverse_proxy localhost:3001
              }
            '';
        };
      "status.thatferret.blog" =
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
              encode zstd gzip
              route {
                reverse_proxy localhost:3001
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

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_url = "https://crowdsec.gigglesquid.tech:8443";
      };
      secrets = {
        apiKeyPath = "${config.sops.secrets."crowdsec_bouncer_api_keys/uptime_firewall".path}";
      };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.hetzner ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server-non-local
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
