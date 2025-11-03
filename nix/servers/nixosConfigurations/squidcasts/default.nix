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
  hostName = "squidcasts";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
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
        matchConfig.Name = "enp6s18";
        ipv6AcceptRAConfig = {
          Token = "static:::1:32";
        };
        address = [
          "10.3.1.32/23"
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
    };
    caddy.virtualHosts = {
      "squidcasts.lan.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings
            import deny_non_local
            encode zstd gzip
            handle {
              reverse_proxy http://127.0.0.1:${toString config.services.audiobookshelf.port}
            }
          '';
      };
    };

    audiobookshelf = {
      enable = true;
      port = 8080;
      host = "127.0.0.1";
      group = "media";
    };
  };

  fileSystems = {
    "/mnt/media" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media";
      fsType = "nfs";
      noCheck = true;
      options = [
        "x-systemd.automount"
        "noauto"
      ];
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
