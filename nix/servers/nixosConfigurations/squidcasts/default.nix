{ inputs, cell }:
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
          Address = "10.3.1.32/23";
          Gateway = "10.3.0.1";
        };
        dns = [ "10.3.0.1" ];
      };
    };
  };

  services = {
    chrony = {
      enable = true;
      initstepslew = lib.mkDefault {
        enabled = true;
        threshold = 120;
      };
    };
    timesyncd.enable = false;
    resolved = {
      fallbackDns = [ ];
    };
    audiobookshelf = {
      enable = true;
      port = 8000;
      host = "10.3.1.32";
      openFirewall = true;
    };
  };

  fileSystems = {
    "/mnt/media" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media";
      fsType = "nfs";
      noCheck = true;
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.vms ];
      suites = with serverSuites; lib.concatLists [ nixosSuites.server ];
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
