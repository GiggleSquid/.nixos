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
  hostName = "vaultwarden";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "vaultwarden.lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp6s18";
        ipv6AcceptRAConfig = {
          Token = "static:::1:80";
        };
        address = [
          "10.3.1.80/23"
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
      "vaultwarden/secret_env" = {
        owner = "vaultwarden";
      };
    };
  };

  services = {
    vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      configurePostgres = true;
      environmentFile = [ "${config.sops.secrets."vaultwarden/secret_env".path}" ];
      config = {
        DOMAIN = "https://pm.lan.gigglesquid.tech";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "::1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";
        SHOW_PASSWORD_HINT = false;
      };
    };

    caddy-squid = {
      enable = true;
    };
    caddy.virtualHosts = {
      "vaultwarden.lan.gigglesquid.tech" =
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
              route {
                reverse_proxy localhost:${toString config.services.vaultwarden.config.ROCKET_PORT} {
                  header_up X-Real-IP {remote_host}
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
