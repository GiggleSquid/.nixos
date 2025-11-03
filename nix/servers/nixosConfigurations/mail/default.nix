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
  hostName = "mail";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp6s18";
        ipv6AcceptRAConfig = {
          Token = "static:::20";
        };
        address = [
          "10.100.0.20/24"
        ];
        gateway = [
          "10.100.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key = { };
      crowdsec_bouncer_api_keys_env = { };
      "mailserver/pass/postmaster@gigglesquid.tech" = { };
      "mailserver/pass/jack.connors@gigglesquid.tech" = { };
      "mailserver/pass/kraken.lan@gigglesquid.tech" = { };
      "mailserver/pass/cephalonas.lan@gigglesquid.tech" = { };
      "mailserver/pass/pbs.cephalonas.lan@gigglesquid.tech" = { };
      "mailserver/pass/hello@thatferret.shop" = { };
      "mailserver/pass/privacy@thatferret.shop" = { };
      "mailserver/pass/notifications@thatferret.shop" = { };
      "mailserver/pass/jack.connors@thatferret.shop" = { };
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
        "BUNNY_PROPAGATION_TIMEOUT_FILE" = nixpkgs.writeText "BUNNY_PROPAGATION_TIMEOUT" ''360'';
      };
    };
    certs = {
      "mail.gigglesquid.tech" = { };
    };
  };

  systemd.services = {
    crowdsec-firewall-bouncer.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
      ];
    };
  };

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "mail.gigglesquid.tech";
    domains = [
      "gigglesquid.tech"
      # "thatferret.blog"
      "thatferret.shop"
    ];
    certificateScheme = "acme";
    enablePop3 = false;
    enablePop3Ssl = false;
    enableImap = false;
    enableImapSsl = true;
    enableSubmission = true;
    enableSubmissionSsl = true;

    hierarchySeparator = "/";
    indexDir = "/var/lib/dovecot/indices";
    useFsLayout = true;
    useUTF8FolderNames = true;
    virusScanning = true;
    dkimKeyType = "ed25519";

    fullTextSearch = {
      enable = true;
      memoryLimit = 2048;
      enforced = "body";
      autoIndex = true;
      autoIndexExclude = [
        "\\Trash"
        "\\Junk"
      ];
      filters = [
        "stopwords"
        "snowball"
        "normalizer-icu"
      ];
      headerExcludes = [
        "Received"
        "DKIM-*"
        "X-*"
      ];
      languages = [ "en" ];
      substringSearch = false;
    };

    dmarcReporting = {
      enable = true;
    };

    loginAccounts = {
      # gigglesquid.tech
      "postmaster@gigglesquid.tech" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/postmaster@gigglesquid.tech".path}";
        aliases = [ "abuse@gigglesquid.tech" ];
      };
      "jack.connors@gigglesquid.tech" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/jack.connors@gigglesquid.tech".path}";
      };
      "kraken.lan@gigglesquid.tech" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/kraken.lan@gigglesquid.tech".path}";
        sendOnly = true;
      };
      "cephalonas.lan@gigglesquid.tech" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/cephalonas.lan@gigglesquid.tech".path
        }";
        sendOnly = true;
      };
      "pbs.cephalonas.lan@gigglesquid.tech" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/pbs.cephalonas.lan@gigglesquid.tech".path
        }";
        sendOnly = true;
      };

      # thatferret.shop
      "hello@thatferret.shop" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/hello@thatferret.shop".path}";
      };
      "privacy@thatferret.shop" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/privacy@thatferret.shop".path}";
      };
      "notifications@thatferret.shop" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/notifications@thatferret.shop".path}";
        sendOnly = true;
        sendOnlyRejectMessage = "This mailbox cannot receive email. Please send your emails to hello@thatferret.shop";
      };
      "jack.connors@thatferret.shop" = {
        hashedPasswordFile = "${config.sops.secrets."mailserver/pass/jack.connors@thatferret.shop".path}";
      };
    };
    extraVirtualAliases = { };
    borgbackup = { };
  };

  services = {
    # alloy-squid = {
    #   enable = true;
    #   supplementaryGroups = [ ];
    #   alloyConfig = # river
    #     ''
    #       local.file_match "mail_log" {
    #         path_targets = [
    #           {"__path__" = "/var/log/mail.log"},
    #         ]
    #         sync_period = "15s"
    #       }
    #       loki.source.file "mail_log" {
    #         targets    = local.file_match.mail_log.targets
    #         forward_to = [loki.process.mail_add_labels.receiver]
    #         tail_from_end = true
    #       }

    #       loki.process "mail_add_labels" {
    #         stage.json {
    #           expressions = {
    #             level = "",
    #             logger = "",
    #             host = "request.host",
    #             method = "request.method",
    #             proto = "request.proto",
    #             ts = "",
    #           }
    #         }

    #         stage.labels {
    #           values = {
    #             level = "",
    #             logger = "",
    #             host = "",
    #             method = "",
    #             proto = "",
    #           }
    #         }

    #         stage.static_labels {
    #           values = {
    #             job = "loki.source.file.mail_log",
    #           }
    #         }

    #         stage.timestamp {
    #           source = "ts"
    #           format = "unix"
    #         }

    #         forward_to = [loki.write.grafana_loki.receiver]
    #       }
    #     '';
    # };

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_key = ''''${CROWDSEC_MAIL_FIREWALL_API_KEY}'';
        api_url = "https://crowdsec.lan.gigglesquid.tech:8443";
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
          base
          crowdsec
          snm
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
