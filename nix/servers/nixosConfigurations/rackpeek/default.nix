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
  hostName = "rackpeek";
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
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:90";
        };
        address = [
          "10.3.1.90/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  users = {
    users.rackpeek = {
      uid = 1654;
      isSystemUser = true;
      group = "rackpeek";
    };
    groups.rackpeek = {
      gid = 1654;
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/rackpeek/config 0775 rackpeek rackpeek" ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      rackpeek = {
        image = "aptacode/rackpeek:v1.1.0";
        autoStart = true;
        ports = [ "127.0.0.1:8080:8080" ];
        volumes = [
          "/var/lib/rackpeek/config:/app/config"
        ];
        user = "1654:1654";
      };
    };
  };

  services = {
    caddy-squid = {
      enable = true;
    };
    caddy.virtualHosts = {
      "rackpeek.lan.gigglesquid.tech" =
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
                reverse_proxy localhost:8080
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
