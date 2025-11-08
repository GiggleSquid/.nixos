{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell)
    machineProfiles
    hardwareProfiles
    nixosSuites
    homeSuites
    ;
  lib = nixpkgs.lib // builtins;
in
{
  inherit (common) bee time;
  networking = {
    hostName = "squid-rig";
    firewall = {
      allowedTCPPorts = [
        1313 # hugo
      ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "eno1";
        networkConfig = {
          IPv6PrivacyExtensions = "yes";
        };
        ipv6AcceptRAConfig = {
          Token = "static:::10";
        };
        address = [
          "10.10.0.10/24"
        ];
        gateway = [
          "10.10.0.1"
        ];
      };
    };
  };

  services = {
    xserver.xkb = lib.mkForce {
      layout = "us";
      variant = "colemak_dh_wide_iso";
    };
  };

  programs.ladybird.enable = true;

  imports =
    let
      profiles = [
        hardwareProfiles.squid-rig
        machineProfiles.squid-rig
      ];
      suites =
        with nixosSuites;
        lib.concatLists [
          desktop
          plasma6
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
            suites =
              with homeSuites;
              lib.concatLists [
                squid
                plasma6
              ];
          in
          lib.concatLists [
            modules
            profiles
            suites
          ];
        home.stateVersion = "25.05";
      };
    };
  };

  system.stateVersion = "25.05";
}
