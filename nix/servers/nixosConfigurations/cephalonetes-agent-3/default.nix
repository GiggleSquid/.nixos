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
    hostName = "agent-3";
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
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
  };

  services = {
    openiscsi = {
      enable = true;
      name = "iqn.2023-01.tech.gigglesquid.lan.iscsi:agent-3";
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.cephalonetes ];
      suites =
        with rke2Suites;
        lib.concatLists [
          nixosSuites.server
          agent-suite
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
            suites = with homeSuites; squid;
          in
          lib.concatLists [ suites ];
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
