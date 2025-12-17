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
  hostName = "squidsurvey";
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
      "limesurvey/nonce" = { };
      "limesurvey/key" = { };
      "limesurvey/db_pass" = { };
    };
  };

  services = {
    limesurvey = {
      enable = true;
      poolConfig = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.max_requests" = 500;
        "pm.max_spare_servers" = 4;
        "pm.min_spare_servers" = 2;
        "pm.start_servers" = 2;
      };
      virtualHost = {
        hostName = null;
      };
      encryptionNonceFile = "${config.sops.secrets."limesurvey/nonce".path}";
      encryptionKeyFile = "${config.sops.secrets."limesurvey/key".path}";
    };

    # We're using caddy instead of the module's built in httpd..
    # Disable httpd, and set httpd user/group to caddy as the
    # limesurvey module uses that as the php-fpm listen group/user.
    httpd = {
      enable = lib.mkForce false;
      user = "caddy";
      group = "caddy";
    };

    caddy-squid = {
      enable = true;
    };
    caddy.virtualHosts = {
      "squidsurvey.lan.gigglesquid.tech" =
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
                root "${config.services.limesurvey.package}/share/limesurvey"
                php_fastcgi unix/${config.services.phpfpm.pools.limesurvey.socket}
                file_server
              }

              handle_path /tmp/* {
                root /var/lib/limesurvey/tmp
                file_server
              }

              handle_path /upload/* {
                root /var/lib/limesurvey/upload
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
