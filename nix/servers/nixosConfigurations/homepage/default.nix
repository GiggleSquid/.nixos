{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "homepage";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [ 443 ];
      allowedUDPPorts = [ 443 ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:15";
        };
        address = [
          "10.3.1.15/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  sops.secrets = {
    homepage_env = { };
  };

  services = {
    homepage-dashboard = {
      enable = true;
      environmentFile = "${config.sops.secrets.homepage_env.path}";
      listenPort = 8082;
      allowedHosts = "homepage.lan.gigglesquid.tech:443";
      settings = {
        base = "https://dash.lan.gigglesquid.tech";
        theme = "dark";
        headerStyle = "clean";
        language = "en-GB";
        target = "_blank";
        hideVersion = true;
        statusStyle = "basic";
        layout = {
          Infra = {
            technitium = {
              style = "row";
              columns = 2;
              header = false;
            };
            truenas = {
              style = "row";
              columns = 2;
              header = false;
            };
            proxmox = {
              pbs = {
                pbs-datastores = {
                  style = "row";
                  columns = 2;
                  header = false;
                };
              };
              kraken = { };
            };
          };
          Media = { };
        };
      };
      widgets = [
        {
          search = {
            provider = "custom";
            url = "https://search.lan.gigglesquid.tech/search?q=";
            suggestionUrl = "https://search.lan.gigglesquid.tech/autocompleter?q=";
            showSearchSuggestions = true;
            focus = false;
            target = "_blank";
          };
        }
        {
          datetime = {
            text_size = "x1";
            format = {
              dateStyle = "long";
              timeStyle = "short";
              hour12 = false;
            };
          };
        }
        {
          unifi_console = {
            url = "https://waffle-iron.lan.gigglesquid.tech";
            username = "{{HOMEPAGE_VAR_UNIFI_CONSOLE_USERNAME}}";
            password = "{{HOMEPAGE_VAR_UNIFI_CONSOLE_PASSWORD}}";
          };
        }
      ];
      services = [
        {
          Infra = [
            {
              technitium = [
                {
                  ns1 =
                    let
                      url = "https://ns1.dns.lan.gigglesquid.tech:53443";
                    in
                    {
                      icon = "technitium";
                      href = url;
                      siteMonitor = url;
                      widget = {
                        type = "technitium";
                        url = url;
                        key = "{{HOMEPAGE_VAR_TECHNITIUM_NS_KEY}}";
                        range = "LastDay";
                      };
                    };
                }
                {
                  ns2 =
                    let
                      url = "https://ns2.dns.lan.gigglesquid.tech:53443";
                    in
                    {
                      icon = "technitium";
                      href = url;
                      siteMonitor = url;
                      widget = {
                        type = "technitium";
                        url = url;
                        key = "{{HOMEPAGE_VAR_TECHNITIUM_NS_KEY}}";
                        range = "LastDay";
                      };
                    };
                }
              ];
            }
            {
              truenas = [
                {
                  cephalonas =
                    let
                      url = "https://cephalonas.lan.gigglesquid.tech";
                    in
                    {
                      icon = "truenas";
                      href = url;
                      siteMonitor = url;
                      widget = {
                        type = "truenas";
                        url = url;
                        key = "{{HOMEPAGE_VAR_TRUENAS_KEY}}";
                        enablePools = true;
                      };
                    };
                }
                {
                  scrutiny =
                    let
                      url = "https://scrutiny.cephalonas.lan.gigglesquid.tech";
                    in
                    {
                      icon = "scrutiny";
                      href = url;
                      siteMonitor = url;
                      widget = {
                        type = "scrutiny";
                        url = url;
                      };
                    };
                }
              ];
            }
            {
              proxmox = [
                {
                  pbs =
                    let
                      url = "https://pbs.cephalonas.lan.gigglesquid.tech:8007";
                    in
                    [
                      {
                        "pbs" = {
                          icon = "proxmox";
                          href = url;
                          siteMonitor = url;
                          widget = {
                            type = "proxmoxbackupserver";
                            url = url;
                            username = "{{HOMEPAGE_VAR_PBS_ID}}";
                            password = "{{HOMEPAGE_VAR_PBS_SECRET}}";
                            # fields = [
                            #   "failed_tasks_24h"
                            #   "cpu_usage"
                            #   "memory_usage"
                            # ];
                          };
                        };
                      }
                      {
                        pbs-datastores = [
                          {
                            "datastore main" = {
                              icon = "proxmox";
                              href = url;
                              siteMonitor = url;
                              widget = {
                                type = "proxmoxbackupserver";
                                url = url;
                                username = "{{HOMEPAGE_VAR_PBS_ID}}";
                                password = "{{HOMEPAGE_VAR_PBS_SECRET}}";
                                datastore = "main";
                                fields = [ "datastore_usage" ];
                              };
                            };
                          }
                          {
                            "datastore storj" = {
                              icon = "proxmox";
                              href = url;
                              siteMonitor = url;
                              widget = {
                                type = "proxmoxbackupserver";
                                url = url;
                                username = "{{HOMEPAGE_VAR_PBS_ID}}";
                                password = "{{HOMEPAGE_VAR_PBS_SECRET}}";
                                datastore = "storj";
                                fields = [ "datastore_usage" ];
                              };
                            };
                          }
                        ];
                      }
                    ];
                }
                {
                  kraken = [
                    {
                      tentacle0 =
                        let
                          url = "https://tentacle0.kraken.lan.gigglesquid.tech:8006";
                        in
                        {
                          icon = "proxmox";
                          href = url;
                          siteMonitor = url;
                          widget = {
                            type = "proxmox";
                            url = url;
                            username = "{{HOMEPAGE_VAR_PVE_KRAKEN_TENTACLE0_ID}}";
                            password = "{{HOMEPAGE_VAR_PVE_KRAKEN_TENTACLE0_SECRET}}";
                            node = "tentacle0";
                          };
                        };
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          Media = [
            {
              squidcasts =
                let
                  url = "https://squidcasts.gigglesquid.tech";
                in
                {
                  icon = "audiobookshelf";
                  href = url;
                  siteMonitor = url;
                  widget = {
                    type = "audiobookshelf";
                    url = url;
                    key = "{{HOMEPAGE_VAR_AUDIOBOOKSHELF_KEY}}";
                  };
                };
            }
            {
              squidjelly =
                let
                  url = "https://squidjelly.gigglesquid.tech";
                in
                {
                  icon = "jellyfin";
                  href = url;
                  siteMonitor = url;
                  widget = {
                    type = "jellyfin";
                    url = url;
                    key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                    fields = [
                      "movies"
                      "series"
                      "episodes"
                    ];
                    enableBlocks = true;
                    enableNowPlaying = true;
                    enableUser = true;
                    enableMediaControl = false;
                    showEpisodeNumber = false;
                    expandOneStreamToTwoRows = true;
                  };
                };
            }
            {
              squidseerr =
                let
                  url = "https://squidseerr.gigglesquid.tech";
                in
                {
                  icon = "jellyseerr";
                  href = url;
                  siteMonitor = url;
                  widget = {
                    type = "jellyseerr";
                    url = url;
                    key = "{{HOMEPAGE_VAR_JELLYSEERR_KEY}}";
                    fields = [
                      "pending"
                      "approved"
                      "available"
                      "processing"
                      "issues"
                    ];
                  };
                };
            }
            {
              qbittorrent =
                let
                  url = "https://qbittorrent.squidbit.lan.gigglesquid.tech";
                in
                {
                  icon = "qbittorrent";
                  href = url;
                  siteMonitor = url;
                  widget = {
                    type = "qbittorrent";
                    url = url;
                    username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
                    enableLeechProgress = true;
                    enableLeechSize = true;
                  };
                };
            }
            {
              nzbget =
                let
                  url = "https://nzbget.squidbit.lan.gigglesquid.tech";
                in
                {
                  icon = "nzbget";
                  href = url;
                  siteMonitor = url;
                  widget = {
                    type = "nzbget";
                    url = url;
                    username = "{{HOMEPAGE_VAR_NZBGET_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_NZBGET_PASSWORD}}";
                  };
                };
            }
            {
              prowlarr =
                let
                  url = "https://prowlarr.squidbit.lan.gigglesquid.tech";
                in
                {
                  icon = "prowlarr";
                  href = url;
                  siteMonitor = url;
                  widget = {
                    type = "prowlarr";
                    url = url;
                    key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                  };
                };
            }
            {
              radarr =
                let
                  url = "https://radarr.squidbit.lan.gigglesquid.tech";
                in
                {
                  icon = "radarr";
                  href = url;
                  siteMonitor = url;
                  widget = {
                    type = "radarr";
                    url = url;
                    key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                    enableQueue = true;
                  };
                };
            }
            {
              sonarr =
                let
                  url = "https://sonarr.squidbit.lan.gigglesquid.tech";
                in
                {
                  icon = "sonarr";
                  href = url;
                  siteMonitor = url;
                  widget = {
                    type = "sonarr";
                    url = url;
                    key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                    enableQueue = true;
                  };
                };
            }
          ];
        }
      ];
      bookmarks = [ ];
      customCSS = # css
        "";
    };
    caddy-squid = {
      enable = true;
    };
    caddy.virtualHosts = {
      "homepage.lan.gigglesquid.tech" =
        { name, ... }:
        {
          logFormat = ''
            output file ${config.services.caddy.logDir}/access-${
              lib.replaceStrings [ "/" " " ] [ "_" "_" ] name
            }.log {
              mode 640
            }
            level INFO
            format json
          '';
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              encode zstd gzip
              route {
                reverse_proxy localhost:8082
              }
            '';
        };
    };

    alloy-squid = {
      enable = true;
      export = {
        caddy = {
          metrics = true;
          logs = true;
        };
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.servers
      ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base
          caddy-server
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
        home.stateVersion = "25.11";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "25.11";
      };
    };
  };

  system.stateVersion = "25.11";
}
