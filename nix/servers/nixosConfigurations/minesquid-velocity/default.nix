{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  inherit (inputs.cells.toolchain) pkgs;
  lib = nixpkgs.lib // builtins;
  hostName = "velocity";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "minesquid.lan.gigglesquid.tech";
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };

  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp6s18";
        ipv6AcceptRAConfig = {
          Token = "static:::1:40";
        };
        address = [
          "10.3.1.40/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets."minesquid_env_vars" = { };
  };

  services = {
    minecraft-servers = {
      enable = true;
      eula = true;
      environmentFile = config.sops.secrets."minesquid_env_vars".path;
      servers = {
        velocity = {
          enable = true;
          package = pkgs.velocityServers.velocity;

          jvmOpts = "-Xms1G -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15";

          symlinks = {
            # "plugins/geyser.jar" = pkgs.fetchurl {
            #   url = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/velocity";
            #   hash = "sha256-lJMX+/wkDk1KXYUvvy5uh10hwNCFvjyHf0wArfxSHSQ=";
            # };
            # "plugins/floodgate.jar" = pkgs.fetchurl {
            #   url = "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/velocity";
            #   hash = "sha256-4EkLZEbAEK5yv15KncAMoYTEl7lkVBez3kj2ZssT1u0=";
            # };
          };

          files = {
            "forwarding.secret" = pkgs.writeTextFile {
              name = "velocity-forwarding-secret";
              text = "@velocity_secret@";
            };

            "velocity.toml".value = {
              config-version = "2.7";
              bind = "0.0.0.0:25565";
              motd = "<#ff6600>MineSquid";
              show-max-players = 50;
              online-mode = true;
              force-key-authentication = true;
              prevent-client-proxy-connections = false;
              player-info-forwarding-mode = "modern";
              forwarding-secret-file = "forwarding.secret";
              announce-forge = false;
              kick-existing-players = false;
              ping-passthrough = "DISABLED";
              enable-player-address-logging = true;
              servers = {
                lobby = "servers.minesquid.lan.gigglesquid.tech:25570";
                survival = "servers.minesquid.lan.gigglesquid.tech:25571";
                survival-modded = "servers.minesquid.lan.gigglesquid.tech:25572";
                try = [
                  "lobby"
                ];
              };
              forced-hosts = {
                "lobby.minesquid.gigglesquid.tech" = [
                  "lobby"
                ];
                "survival.minesquid.gigglesquid.tech" = [
                  "survival"
                ];
                "survival-modded.minesquid.gigglesquid.tech" = [
                  "survival-modded"
                ];
              };
              advanced = {
                compression-threshold = 256;
                compression-level = -1;
                login-ratelimit = 3000;
                connection-timeout = 5000;
                read-timeout = 30000;
                haproxy-protocol = true;
                tcp-fast-open = true;
                bungee-plugin-message-channel = true;
                show-ping-requests = false;
                failover-on-unexpected-server-disconnect = true;
                announce-proxy-commands = true;
                log-command-executions = false;
                log-player-connections = true;
                accepts-transfers = false;
              };
              query = {
                enabled = false;
                port = 25565;
                map = "Velocity";
                show-plugins = false;
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
          minesquid
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
