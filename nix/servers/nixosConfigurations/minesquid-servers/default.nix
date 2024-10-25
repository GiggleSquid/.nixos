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

  jvmCommonPaperOpts = " -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";

  jvmCommonFabricOpts = " -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:AllocatePrefetchStyle=3 -XX:+UseG1GC -XX:MaxGCPauseMillis=130 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=28 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=20 -XX:G1MixedGCCountTarget=3 -XX:InitiatingHeapOccupancyPercent=10 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5.0 -XX:G1ConcRefinementServiceIntervalMillis=150 -XX:G1ConcRSHotCardLimit=16 -XX:+UseTransparentHugePages";
in
{
  inherit (common) bee time;
  networking = {
    hostName = "servers";
    domain = "minesquid.lan.gigglesquid.tech";
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
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
        lobby = {
          enable = true;
          package = pkgs.paperServers.paper-1_21_1;

          serverProperties = {
            server-port = 25570;
            online-mode = false;
            gamemode = "adveture";
            allow-nether = false;
            difficulty = "peaceful";
            pvp = false;
            spawn-animals = false;
            spawn-monsters = false;
            spawn-npcs = false;
            spawn-protection = 256;
            simulation-distance = 8;
            view-distance = 20;
            enforce-whitelist = true;
            white-list = true;
          };
          whitelist = {
            GiggleSquid = "5e3aaa7c-65d4-4b59-8f79-48d97492e03d";
            Altxbunny = "3e354a65-5c84-4d44-8115-0155e9ebee6d";
            FrOggyqueenx = "755f626c-36d5-489d-bc4e-9e4aab9da6d7";
            # ".Altxbunny" = "00000000-0000-0000-0009-01FA22FAEC65";
          };
          jvmOpts = "-Xms4096M -Xmx4096M" + jvmCommonPaperOpts;

          symlinks = {
            "plugins/worldedit.jar" = pkgs.fetchurl {
              url = "https://hangarcdn.papermc.io/plugins/EngineHub/WorldEdit/versions/7.3.6/PAPER/worldedit-bukkit-7.3.6.jar";
              hash = "sha256-85MQWheIaM/9mdvjnykGHESwx1vqy11apZwIDNQjyXk=";
            };
            "plugins/chunky.jar" = pkgs.fetchurl {
              url = "https://hangarcdn.papermc.io/plugins/pop4959/Chunky/versions/1.4.10/PAPER/Chunky-1.4.10.jar";
              hash = "sha256-iOyPboWgHpRB5BO+G5fTh42e1cSGPDmBdvwhUCeyn3s=";
            };
            "plugins/viaversion.jar" = pkgs.fetchurl {
              url = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/5.0.4-SNAPSHOT%2B528/PAPER/ViaVersion-5.0.4-SNAPSHOT.jar";
              hash = "sha256-dcXO1dKdyVNAmLlZfDbnNO571KsSNfpQoyXP4oFnn6g=";
            };
            "plugins/viabackwards.jar" = pkgs.fetchurl {
              url = "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaBackwards/versions/5.0.4-SNAPSHOT%2B320/PAPER/ViaBackwards-5.0.4-SNAPSHOT.jar";
              hash = "sha256-O5gG6eq07OcVbuWHrEmVnGPoImaTYXHMQ0Ff2mWi/7k=";
            };
            "plugins/floodgate.jar" = pkgs.fetchurl {
              url = "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot";
              hash = "sha256-xHKOvGbnBFaaTWq+7KR35FVaBHrw+Lzk6oJhOrvD/ro=";
            };

            "plugins/stargate-rewitten.jar" = ././Stargate-1.0.0.16-ALPHA.jar;
          };

          files = {
            "ops.json".value = [
              {
                uuid = "5e3aaa7c-65d4-4b59-8f79-48d97492e03d";
                name = "GiggleSquid";
                level = 4;
                bypassesPlayerLimit = true;
              }
            ];
            "config/paper-global.yml".value = {
              proxies = {
                velocity = {
                  enabled = true;
                  online-mode = true;
                  secret = "@velocity_secret@";
                };
              };
            };
            "plugins/Stargate/gates/squid.gate" = pkgs.writeText "squid.gate" ''
              portal-open=END_GATEWAY
              portal-closed=AIR
              X=OBSIDIAN
              -=OBSIDIAN

              XXXXX
              X...X
              -...-
              X.*.X
              XXXXX
            '';
          };
        };
        survival = {
          enable = true;
          package = pkgs.paperServers.paper-1_21_1;

          serverProperties = {
            server-port = 25571;
            online-mode = false;
            gamemode = "survival";
            difficulty = "easy";
            spawn-protection = 16;
            view-distance = 20;
            enforce-whitelist = true;
            white-list = true;
          };
          whitelist = {
            GiggleSquid = "5e3aaa7c-65d4-4b59-8f79-48d97492e03d";
          };
          jvmOpts = "-Xms4096M -Xmx4096M" + jvmCommonPaperOpts;

          files = {
            "config/paper-global.yml".value = {
              proxies = {
                velocity = {
                  enabled = true;
                  online-mode = true;
                  secret = "@velocity_secret@";
                };
              };
            };
          };
        };
        survival-modded =
          let
            modpack = pkgs.fetchPackwizModpack {
              url = "https://github.com/GiggleSquid/MineSquid/raw/a9ebdde1c1e897c37f645c95a845e489b6d3fc93/pack.toml";
              packHash = "sha256-WqFZgflwPr+30LWGSk237i2PjWEfT1ZYBAC2spEYqrM=";
              manifestHash = "sha256-rdy/F44D/Sx86WGbyQIQI2+WYfW6F4KMHW2uLVTED/c=";
            };
            mcVersion = modpack.manifest.versions.minecraft;
            fabricVersion = modpack.manifest.versions.fabric;
            serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}";
          in
          {
            enable = true;
            package = pkgs.fabricServers.${serverVersion}.override { loaderVersion = fabricVersion; };

            serverProperties = {
              server-port = 25572;
              online-mode = false;
              gamemode = "survival";
              difficulty = "easy";
              spawn-protection = 16;
              view-distance = 20;
              enforce-whitelist = true;
              white-list = true;
            };
            whitelist = {
              GiggleSquid = "5e3aaa7c-65d4-4b59-8f79-48d97492e03d";
            };
            jvmOpts = "-Xms10240M -Xmx10240M" + jvmCommonFabricOpts;

            symlinks = {
              "mods" = "${modpack}/mods";
              "config/paxi/datapacks" = "${modpack}/config/paxi/datapacks";
            };

            files = {
              "config/FabricProxy-Lite.toml".value = {
                hackOnlineMode = true;
                hackEarlySend = false;
                hackMessageChain = true;
                secret = "@velocity_secret@";
              };
              "config/NoChatReports/NCR-Client.json" = "${modpack}/config/NoChatReports/NCR-Client.json";
              "config/badoptimizations.txt" = "${modpack}/config/badoptimizations.txt";
              "config/c2me.toml" = "${modpack}/config/c2me.toml";
              "config/entityculling.json" = "${modpack}/config/entityculling.json";
              "config/fabric_loader_dependencies.json" = "${modpack}/config/fabric_loader_dependencies.json";
              "config/ferritecore.mixin.properties" = "${modpack}/config/ferritecore.mixin.properties";
              "config/immediatelyfast.json" = "${modpack}/config/immediatelyfast.json";
              "config/modernfix-mixins.properties" = "${modpack}/config/modernfix-mixins.properties";
              "config/moreculling.toml" = "${modpack}/config/moreculling.toml";
              "config/sodium-options.json" = "${modpack}/config/sodium-options.json";
              "config/threadtweak.json" = "${modpack}/config/threadtweak.json";
              "config/vmp.properties" = "${modpack}/config/vmp.properties";
            };
          };
      };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.servers ];
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
