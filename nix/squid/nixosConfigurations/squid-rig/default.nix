{
  inputs,
  cell,
}: let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles nixosProfiles nixosSuites homeProfiles homeSuites homeModules;
  lib = nixpkgs.lib // builtins;
  hostName = "squid-rig";
in {
  inherit (common) bee time;
  networking = {inherit hostName;};

  imports = let
    profiles = with nixosProfiles; [
      hardwareProfiles."${hostName}"
    ];
    suites = with nixosSuites; desktop;
  in
    lib.concatLists [profiles suites];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      squid = {
        imports = let
          modules = with homeModules; [
            anyrun
          ];
          profiles = with homeProfiles; [
            {
              wayland.windowManager.hyprland.settings.monitor = lib.mkForce [
                "HDMI-A-1,1920x1080@60,0x0,1"
                "HDMI-A-2,1920x1080@60,1920x0,1"
                "DP-2,3440x1440@120,200x1080,1"
                ",preferred,auto,1"
              ];
            }
          ];
          suites = with homeSuites;
            lib.concatLists [
              squid
              hyprland
            ];
        in
          lib.concatLists [modules profiles suites];
        home.stateVersion = "23.05";
      };
    };
  };

  system.stateVersion = "23.05";
}
