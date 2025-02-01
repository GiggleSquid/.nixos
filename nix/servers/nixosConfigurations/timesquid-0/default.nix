{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) rpi nixpkgs self;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "timesquid-0";
in
{

  sops.secrets.wifi_env = {
    sopsFile = "${self}/sops/squid-rig.yaml";
  };

  inherit (rpi) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    # wireless = {
    #   enable = true;
    #   environmentFile = config.sops.secrets.wifi_env.path;
    #   networks = {
    #     "@WIFI_SSID@" = {
    #       psk = "@WIFI_PSK@";
    #     };
    #   };
    # };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        networkConfig = {
          Address = "10.3.0.5/23";
          Gateway = "10.3.0.1";
        };
      };
    };
  };

  environment.systemPackages = with nixpkgs; [
    raspberrypi-eeprom
    libraspberrypi
    pps-tools
    gpsd
  ];

  services.gpsd = {
    enable = true;
    nowait = true;
    devices = [
      "/dev/ttyAMA0"
      "/dev/pps0"
    ];
    extraArgs = [
      "-r"
      "-s"
      "115200"
    ];
  };

  users.users.chrony = {
    extraGroups = [ "gpsd" ];
  };

  systemd.services."serial-getty@ttyAMA0".enable = false;

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", KERNEL=="ttyAMA0", OWNER="root", GROUP="gpsd", MODE="0660"
    SUBSYSTEM=="pps", KERNEL=="pps0", OWNER="root", GROUP="gpsd", MODE="0660"
  '';

  imports =
    let
      profiles = [
        hardwareProfiles.servers-rpi
      ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          ntp-server
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
