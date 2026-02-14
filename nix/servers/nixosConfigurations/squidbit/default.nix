{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "squidbit";
in
{
  inherit (common) bee time;

  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      # Handled by proxmox so I can use vpn portforwarding
      enable = false;
    };
    # PIA (pain in the ass) blocks ipv6 traffic for
    # "security" and/or "pirvicy" "reasons".
    enableIPv6 = false;
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp6s18";
        networkConfig = lib.mkForce {
          # networkd sets link local by default which forces networkd
          # to set net.ipv6.conf.<interface>.disable_ipv6 = 0 at boot
          LinkLocalAddressing = "no";
        };
        address = [
          "10.3.1.30/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
        ntp = [
          "10.3.0.5"
        ];
        dns = [
          "10.3.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key = { };
      lego_pfx_pass = { };
      "pia/pia_env" = { };
      "pia/ca.rsa.4096.crt" = { };
      "prowlarr/env" = { };
      "radarr/env" = { };
      "sonarr/env" = { };
      radarr_api_key = {
        mode = "0440";
        group = "media";
      };
      sonarr_api_key = {
        mode = "0440";
        group = "media";
      };
      "cross_seed/settings.json" = { };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      server = "https://acme-v02.api.letsencrypt.org/directory";
      email = "jack.connors@protonmail.com";
      extraLegoFlags = [
        "--dns.propagation-wait=300s"
      ];
      dnsResolver = "9.9.9.9";
      dnsProvider = "bunny";
      credentialFiles = {
        "BUNNY_API_KEY_FILE" = "${config.sops.secrets.bunny_dns_api_key.path}";
        "BUNNY_PROPAGATION_TIMEOUT_FILE" = nixpkgs.writeText "BUNNY_PROPAGATION_TIMEOUT" "360";
      };
    };
    certs = {
      "squidbit.lan.gigglesquid.tech" = {
        postRun = # bash
          ''
            cp -v key.pem /var/lib/qBittorrent/
            chown -v qbittorrent /var/lib/qBittorrent/key.pem
            chmod -v 640 /var/lib/qBittorrent/key.pem

            cp -v fullchain.pem /var/lib/qBittorrent/
            chown -v qbittorrent /var/lib/qBittorrent/fullchain.pem
            chmod -v 640 /var/lib/qBittorrent/fullchain.pem

            cp -v key.pem /var/lib/nzbget/
            chown -v nzbget /var/lib/nzbget/key.pem
            chmod -v 640 /var/lib/nzbget/key.pem

            cp -v fullchain.pem /var/lib/nzbget/
            chown -v nzbget /var/lib/nzbget/fullchain.pem
            chmod -v 640 /var/lib/nzbget/fullchain.pem

            openssl pkcs12 -export \
              -out squidbit.lan.gigglesquid.tech.pfx \
              -inkey key.pem \
              -in cert.pem \
              -certfile chain.pem \
              -passout file:${config.sops.secrets.lego_pfx_pass.path}

            cp -v squidbit.lan.gigglesquid.tech.pfx /var/lib/prowlarr/
            chown -v prowlarr:prowlarr /var/lib/prowlarr/squidbit.lan.gigglesquid.tech.pfx
            chmod -v 640 /var/lib/prowlarr/squidbit.lan.gigglesquid.tech.pfx

            cp -v squidbit.lan.gigglesquid.tech.pfx /var/lib/radarr/
            chown -v radarr /var/lib/radarr/squidbit.lan.gigglesquid.tech.pfx
            chmod -v 640 /var/lib/radarr/squidbit.lan.gigglesquid.tech.pfx

            cp -v squidbit.lan.gigglesquid.tech.pfx /var/lib/sonarr/
            chown -v sonarr /var/lib/sonarr/squidbit.lan.gigglesquid.tech.pfx
            chmod -v 640 /var/lib/sonarr/squidbit.lan.gigglesquid.tech.pfx
          '';
      };
    };
  };

  users.groups.media = { };

  systemd.services = {
    qbittorrent = {
      after = [
        "mnt-media.mount"
        "pia-vpn.service"
      ];
      # we don't bother using bindsTo pia-vpn bucause
      # qbit has an internal network iface setting
    };
    nzbget = {
      after = [
        "mnt-media.mount"
        "pia-vpn.service"
      ];
      bindsTo = [ "pia-vpn.service" ];
      wantedBy = [ "pia-vpn.service" ];
      path = [ nixpkgs.python3 ];
    };
    prowlarr.after = [
      "mnt-media.mount"
      "pia-vpn.service"
      "postgresql.target"
    ];
    radarr.after = [
      "mnt-media.mount"
      "pia-vpn.service"
      "postgresql.target"
    ];
    sonarr.after = [
      "mnt-media.mount"
      "pia-vpn.service"
      "postgresql.target"
    ];
    cross-seed.after = [
      "mnt-media.mount"
      "pia-vpn.service"
      "postgresql.target"
      "sonarr.service"
      "radarr.service"
      "qbittorrent.service"
    ];
  };

  services = {
    postgresql = {
      enable = true;
      package = nixpkgs.postgresql_17;
      ensureDatabases = [
        "prowlarr-main"
        "prowlarr-log"
        "radarr-main"
        "radarr-log"
        "sonarr-main"
        "sonarr-log"
      ];
      ensureUsers = [
        { name = "prowlarr"; }
        { name = "radarr"; }
        { name = "sonarr"; }
      ];
    };
    qbittorrent = {
      enable = true;
      package = nixpkgs.qbittorrent-nox;
      group = "media";
    };
    nzbget = {
      enable = true;
      group = "media";
      settings = {
        MainDir = "/mnt/media/nzb";
        CertStore = "${nixpkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        SecureCert = "/var/lib/nzbget/fullchain.pem";
        SecureKey = "/var/lib/nzbget/key.pem";
        CertCheck = true;
      };
    };
    flaresolverr = {
      enable = true;
    };
    prowlarr = {
      enable = true;
      environmentFiles = [ config.sops.secrets."prowlarr/env".path ];
    };
    radarr = {
      enable = true;
      group = "media";
      environmentFiles = [ config.sops.secrets."radarr/env".path ];
    };
    sonarr = {
      enable = true;
      group = "media";
      environmentFiles = [ config.sops.secrets."sonarr/env".path ];
    };
    cross-seed = {
      enable = true;
      group = "media";
      useGenConfigDefaults = true;
      settingsFile = config.sops.secrets."cross_seed/settings.json".path;
      settings = {
        action = "inject";
        useClientTorrents = true;
        linkType = "hardlink";
        matchMode = "partial";
        seasonFromEpisodes = 0.5;
        linkDirs = [ "/mnt/media/torrents/seeding/cross-seed" ];
      };
    };
    unpackerr = {
      enable = true;
      group = "media";
      settings = {
        radarr_0 = {
          url = "https://radarr.squidbit.lan.gigglesquid.tech";
          api_key = "filepath:${config.sops.secrets.radarr_api_key.path}";
          paths_0 = "/mnt/media/torrents/seeding/radarr";
          protocols = "torrent";
        };
        sonarr_0 = {
          url = "https://sonarr.squidbit.lan.gigglesquid.tech";
          api_key = "filepath:${config.sops.secrets.sonarr_api_key.path}";
          paths_0 = "/mnt/media/torrents/seeding/sonarr";
          protocols = "torrent";
        };
      };
    };
    recyclarr = {
      enable = true;
      schedule = "hourly";
      configuration = {
        radarr = {
          main-radarr = {
            api_key._secret = config.sops.secrets.radarr_api_key.path;
            base_url = "https://radarr.squidbit.lan.gigglesquid.tech";
            delete_old_custom_formats = true;
            replace_existing_custom_formats = true;
            include = [
              { template = "radarr-quality-definition-sqp-streaming"; }
              { template = "radarr-quality-profile-sqp-1-2160p-imax-e"; }
              { template = "radarr-custom-formats-sqp-1-2160p"; }
              { template = "radarr-quality-definition-anime"; }
              { template = "radarr-quality-profile-anime"; }
              { template = "radarr-custom-formats-anime"; }
            ];
            custom_formats = [
              # Movie Versions
              {
                trash_ids = [
                  "570bc9ebecd92723d2d21500f4be314c" # Remaster
                  "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
                  "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                  "9d27d9d2181838f76dee150882bdc58c" # Masters of Cinema
                  "db9b4c4b53d312a3ca5f1378f6440fc9" # Vinegar Syndrome
                  "957d0f44b592285f26449575e8b1167e" # Special Edition
                  "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
                ];
                assign_scores_to = [
                  {
                    name = "SQP-1 (2160p)";
                  }
                ];
              }
              # Optional
              {
                trash_ids = [
                  "b337d6812e06c200ec9a2d3cfa9d20a7" # DV Boost
                  "caa37d0df9c348912df1fb1d88f9273a" # HDR10+ Boost
                  "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                  "cc444569854e9de0b084ab2b8b1532b2" # Black and White Editions
                  "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup
                  "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
                  "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
                  # "f537cf427b64c38c8e36298f657e4828" # Scene
                ];
                assign_scores_to = [
                  {
                    name = "SQP-1 (2160p)";
                  }
                ];
              }
              # Optional SDR
              {
                trash_ids = [
                  "25c12f78430a3a23413652cbd1d48d77" # SDR (no WEBDL)
                ];
                assign_scores_to = [
                  {
                    name = "SQP-1 (2160p)";
                  }
                ];
              }
              # Anime
              {
                trash_ids = [
                  "064af5f084a0a24458cc8ecd3220f93f" # Uncensored
                ];
                assign_scores_to = [
                  {
                    name = "Remux-1080p - Anime";
                    score = 10;
                  }
                ];
              }
              {
                trash_ids = [
                  "a5d148168c4506b55cf53984107c396e" # 10bit
                ];
                assign_scores_to = [
                  {
                    name = "Remux-1080p - Anime";
                    score = 5;
                  }
                ];
              }
              {
                trash_ids = [
                  "4a3b087eea2ce012fcc1ce319259a3be" # Anime Dual Audio
                ];
                assign_scores_to = [
                  {
                    name = "Remux-1080p - Anime";
                    score = 10;
                  }
                ];
              }
            ];
          };
        };
        sonarr = {
          main-sonarr = {
            api_key._secret = config.sops.secrets.sonarr_api_key.path;
            base_url = "https://sonarr.squidbit.lan.gigglesquid.tech";
            delete_old_custom_formats = true;
            replace_existing_custom_formats = true;
            include = [
              { template = "sonarr-quality-definition-series"; }
              { template = "sonarr-v4-quality-profile-web-2160p-alternative"; }
              { template = "sonarr-v4-custom-formats-web-2160p"; }
              { template = "sonarr-quality-definition-anime"; }
              { template = "sonarr-v4-quality-profile-anime"; }
              { template = "sonarr-v4-custom-formats-anime"; }
            ];

            custom_formats = [
              # HDR Formats
              {
                trash_ids = [
                  "0c4b99df9206d2cfac3c05ab897dd62a" # HDR10+ Boost
                  "7c3a61a9c6cb04f52f1544be6d44a026" # DV Boost
                ];
                assign_scores_to = [
                  {
                    name = "WEB-2160p";
                  }
                ];
              }
              # Optional
              {
                trash_ids = [
                  "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
                  "82d40da2bc6923f41e14394075dd4b03" # No-RlsGroup
                  "e1a997ddb54e3ecbfe06341ad323c458" # Obfuscated
                  "06d66ab109d4d2eddb2794d21526d140" # Retags
                  # "1b3994c551cbb92a2c781af061f4ab44" # Scene
                ];
                assign_scores_to = [
                  {
                    name = "WEB-2160p";
                  }
                ];
              }
              # allow x265 HD releases with HDR/DV
              {
                trash_ids = [
                  "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
                ];
                assign_scores_to = [
                  {
                    name = "WEB-2160p";
                    score = 0;
                  }
                ];
              }
              {
                trash_ids = [
                  "9b64dff695c2115facf1b6ea59c9bd07" # x265 (no HDR/DV)
                ];
                assign_scores_to = [
                  {
                    name = "WEB-2160p";
                  }
                ];
              }
              # Optional SDR
              {
                trash_ids = [
                  "83304f261cf516bb208c18c54c0adf97" # SDR (no WEBDL)
                ];
                assign_scores_to = [
                  {
                    name = "WEB-2160p";
                  }
                ];
              }
              # Upscaled
              {
                trash_ids = [
                  "23297a736ca77c0fc8e70f8edd7ee56c" # Upscaled
                ];
                assign_scores_to = [
                  {
                    name = "WEB-2160p";
                  }
                ];
              }
              # Anime
              {
                trash_ids = [
                  "026d5aadd1a6b4e550b134cb6c72b3ca" # Uncensored
                ];
                assign_scores_to = [
                  {
                    name = "Remux-1080p - Anime";
                    score = 10;
                  }
                ];
              }
              {
                trash_ids = [
                  "b2550eb333d27b75833e25b8c2557b38" # 10bit
                ];
                assign_scores_to = [
                  {
                    name = "Remux-1080p - Anime";
                    score = 5;
                  }
                ];
              }
              {
                trash_ids = [
                  "418f50b10f1907201b6cfdf881f467b7" # Anime Dual Audio
                ];
                assign_scores_to = [
                  {
                    name = "Remux-1080p - Anime";
                    score = 10;
                  }
                ];
              }
            ];
          };
        };
      };
    };
    pia-vpn = {
      enable = true;
      certificateFile = config.sops.secrets."pia/ca.rsa.4096.crt".path;
      environmentFile = config.sops.secrets."pia/pia_env".path;
      region = "nl_amsterdam";
      netdevConfig = ''
        [NetDev]
        Description=WireGuard PIA network device
        Name=''${interface}
        Kind=wireguard

        [WireGuard]
        FirewallMark=0x8888
        PrivateKey=$privateKey

        [WireGuardPeer]
        PublicKey=$(echo "$json" | jq -r '.server_key')
        AllowedIPs=0.0.0.0/0, ::/0
        Endpoint=''${wg_ip}:$(echo "$json" | jq -r '.server_port')
        PersistentKeepalive=25
      '';
      networkConfig = ''
        [Match]
        Name=''${interface}

        [Network]
        Description=WireGuard PIA network interface
        Address=''${peerip}/32
        DNS=10.3.0.1

        [RoutingPolicyRule]
        FirewallMark=0x8888
        InvertRule=true
        Priority=10
        Table=1000

        [RoutingPolicyRule]
        Priority=5
        To=''${wg_ip}/32

        [RoutingPolicyRule]
        Priority=6
        To=''${meta_ip}/32

        [RoutingPolicyRule]
        Priority=9
        To=10.3.0.0/23

        [RoutingPolicyRule]
        Priority=9
        To=10.10.0.0/24

        [Route]
        Destination=0.0.0.0/0
        Table=1000
      '';
      portForward = {
        enable = true;
        # update qbittorrent listen port via api.
        # this took way too long to figure out.
        script = # bash
          ''
            curl --insecure -i -X POST -d "json={\"listen_port\": $port}" "https://localhost:8080/api/v2/app/setPreferences"
          '';
      };
    };

    alloy-squid = {
      enable = true;
    };
  };

  environment.systemPackages = with nixpkgs; [
    jdupes
    wireguard-tools
  ];

  fileSystems = {
    "/mnt/media" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media";
      fsType = "nfs";
      noCheck = true;
      options = [
        "nolock"
        "_netdev"
        "nconnect=16"
      ];
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.vms ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base
          squidbit
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
