{
  inputs,
  cell,
}:
let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "warrior";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "archiveteam.lan.gigglesquid.tech";
    nameservers = [ "10.3.0.1" ];
    useNetworkd = true;
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = lib.mkForce "en*18";
        networkConfig = {
          Address = "10.3.1.60/23";
          Gateway = "10.3.0.1";
        };
      };
    };
  };

  virtualisation.arion = {
    backend = "podman-socket";
    projects.warrior-archiveteam = {
      settings = {
        services = {
          warrior-1 = {
            service = {
              image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
              ports = [ "8001:8001" ];
              labels = {
                "io.containers.autoupdate" = "registry";
              };
              environment = {
                DOWNLOADER = "GiggleSquid";
                CONCURRENT_ITEMS = 6;
                SHARED_RSYNC_THREADS = 40;
                SELECTED_PROJECT = "auto";
              };
            };
          };
          warrior-2 = {
            service = {
              image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
              ports = [ "8002:8001" ];
              labels = {
                "io.containers.autoupdate" = "registry";
              };
              environment = {
                DOWNLOADER = "GiggleSquid";
                CONCURRENT_ITEMS = 6;
                SHARED_RSYNC_THREADS = 40;
                SELECTED_PROJECT = "urlteam2";
              };
            };
          };
          warrior-3 = {
            service = {
              image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
              ports = [ "8003:8001" ];
              labels = {
                "io.containers.autoupdate" = "registry";
              };
              environment = {
                DOWNLOADER = "GiggleSquid";
                CONCURRENT_ITEMS = 6;
                SHARED_RSYNC_THREADS = 40;
                SELECTED_PROJECT = "goo-gl";
              };
            };
          };
          warrior-4 = {
            service = {
              image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
              ports = [ "8004:8001" ];
              labels = {
                "io.containers.autoupdate" = "registry";
              };
              environment = {
                DOWNLOADER = "GiggleSquid";
                CONCURRENT_ITEMS = 6;
                SHARED_RSYNC_THREADS = 40;
                SELECTED_PROJECT = "pastebin";
              };
            };
          };
          warrior-5 = {
            service = {
              image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
              ports = [ "8005:8001" ];
              labels = {
                "io.containers.autoupdate" = "registry";
              };
              environment = {
                DOWNLOADER = "GiggleSquid";
                CONCURRENT_ITEMS = 6;
                SHARED_RSYNC_THREADS = 40;
                SELECTED_PROJECT = "githubtest2";
              };
            };
          };
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
          arion
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
