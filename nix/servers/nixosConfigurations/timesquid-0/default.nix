{
  inputs,
  cell,
}:
let
  inherit (inputs) rpi nixpkgs self;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "timesquid-0";
in
{
  inherit (rpi) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ 123 ];
    };
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
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::5";
        };
        address = [
          "10.3.0.5/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  sops.secrets.wifi_env = {
    sopsFile = "${self}/sops/squid-rig.yaml";
  };

  environment.systemPackages = with nixpkgs; [
    raspberrypi-eeprom
    libraspberrypi
    i2c-tools
    pps-tools
    gpsd
  ];

  services = {
    gpsd = {
      enable = true;
      nowait = true;
      readonly = false;
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
    chrony = {
      enable = true;
      servers = [ ];
      enableRTCTrimming = false;
      extraConfig = ''
        pool uk.pool.ntp.org iburst minpoll 5 maxpoll 5 polltarget 16 maxdelay 0.030 maxdelaydevratio 2 maxsources 5
        makestep 1 3
        refclock SOCK /run/chrony.clk.ttyAMA0.sock refid GNSS poll 8 precision 1e-1 offset 0.055 delay 0.2 trust noselect
        refclock SOCK /run/chrony.pps0.sock refid kPPS lock GNSS maxlockage 2 poll 4 precision 1e-7 trust prefer
        ## This was using transcrypt, need to use env variables or something instaed
        # allow ''${ipv6Prefix}
        ##
        allow 10.0.0.0/8
        driftfile /var/lib/chrony/chrony.drift
        rtcsync
        logdir /var/log/chrony
        log rawmeasurements measurements statistics tracking refclocks tempcomp
        lock_all
      '';
    };
  };

  users.users.chrony = {
    extraGroups = [ "gpsd" ];
  };

  systemd.services = {
    "serial-getty@ttyAMA0".enable = false;
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", KERNEL=="ttyAMA0", OWNER="root", GROUP="gpsd", MODE="0666"
    SUBSYSTEM=="pps", KERNEL=="pps0", OWNER="root", GROUP="gpsd", MODE="0666"
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
          base-rpi
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
