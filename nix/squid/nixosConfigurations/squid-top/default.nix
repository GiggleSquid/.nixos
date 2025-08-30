{ inputs, cell }:
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
    hostName = "squid-top";
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  #
  # Needs work because wlan and such
  # This is all placeholder
  #
  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp1s0";
        DHCP = "yes";
        networkConfig = {
          IPv6PrivacyExtensions = "yes";
        };
        # ipv6AcceptRAConfig = {
        #   Token = "static:::11";
        # };
        # address = [
        #   "10.10.0.11/24"
        # ];
        # gateway = [
        #   "10.10.0.1"
        # ];
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.squid-top
        machineProfiles.squid-top
      ];
      suites =
        with nixosSuites;
        lib.concatLists [
          laptop
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

        home.stateVersion = "23.11";
      };
    };
  };
  system.stateVersion = "23.11";
}
