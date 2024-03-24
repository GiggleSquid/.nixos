{ inputs, cell }:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) hardwareProfiles rke2Suites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
in
{
  inherit (common) bee time;
  networking = {
    hostName = "server-3";
    domain = "cephalonetes.lan.gigglesquid.tech";
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        networkConfig = {
          Address = "10.10.4.43/24";
          Gateway = "10.10.4.1";
        };
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/cephalonetes.yaml";
  };

  services = {
    openiscsi = {
      enable = true;
      name = "iqn.2023-01.tech.gigglesquid.lan.iscsi:server3";
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.cephalonetes ];
      suites =
        with rke2Suites;
        lib.concatLists [
          nixosSuites.server
          server
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
        home.stateVersion = "23.05";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "23.05";
      };
    };
  };

  system.stateVersion = "23.05";
}
