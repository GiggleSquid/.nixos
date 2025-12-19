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
  hostName = "crowdsec";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        8443
        7422
      ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp6s18";
        ipv6AcceptRAConfig = {
          Token = "static:::50";
        };
        address = [
          "10.100.0.50/24"
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
      crowdsec_enroll_key = { };
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
      "crowdsec.gigglesquid.tech" = {
        group = "crowdsec";
        extraDomainNames = [
          "crowdsec.lan.gigglesquid.tech"
        ];
      };
    };
  };

  services.crowdsec = {
    enable = true;
    autoUpdateService = true;
    settings = {
      console = {
        tokenFile = "${config.sops.secrets.crowdsec_enroll_key.path}";
      };
      capi = {
        credentialsFile = "/var/lib/crowdsec/online_api_credentials.yaml";
      };
      lapi = {
        credentialsFile = "/var/lib/crowdsec/local_api_credentials.yaml";
      };
      general = {
        api.server = {
          enable = true;
          listen_uri = "0.0.0.0:8443";
          tls = {
            cert_file = "/var/lib/acme/crowdsec.gigglesquid.tech/cert.pem";
            key_file = "/var/lib/acme/crowdsec.gigglesquid.tech/key.pem";
            client_verification = "NoClientCert";
          };
        };
        crowdsec_service = {
          parser_routines = 4;
          buckets_routines = 4;
          output_routines = 2;
        };
      };
    };
    hub = {
      scenarios = [ ];
      postOverflows = [ ];
      parsers = [
        "crowdsecurity/whitelists"
      ];
      collections = [
        "crowdsecurity/linux"
        "crowdsecurity/caddy"
        "crowdsecurity/postfix"
        "crowdsecurity/dovecot"
        "crowdsecurity/appsec-generic-rules"
        "crowdsecurity/appsec-virtual-patching"
        "crowdsecurity/appsec-wordpress"
        "crowdsecurity/wordpress"
      ];
      appSecRules = [ ];
      appSecConfigs = [ ];
    };
    localConfig = {
      acquisitions = [
        {
          source = "appsec";
          listen_addr = "0.0.0.0:7422";
          cert_file = "/var/lib/acme/crowdsec.gigglesquid.tech/cert.pem";
          key_file = "/var/lib/acme/crowdsec.gigglesquid.tech/key.pem";
          appsec_configs = [ "crowdsecurity/appsec-default" ];
          routines = 2;
          labels = {
            type = "appsec";
          };
        }
        {
          source = "loki";
          url = "https://loki.otel.lan.gigglesquid.tech";
          # auth = {
          #   username = "something";
          #   password = "secret";
          # };
          log_level = "info";
          limit = 1000;
          query = ''
            {job="loki.source.file.caddy_access_log"}
          '';
          labels = {
            type = "caddy";
          };
        }
        {
          source = "loki";
          url = "https://loki.otel.lan.gigglesquid.tech";
          # auth = {
          #   username = "something";
          #   password = "secret";
          # };
          limit = 1000;
          query = ''
            {job="loki.source.journal.journal", systemd_unit=~"sshd.*.service"}
          '';
          labels = {
            type = "sshd";
          };
        }
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
