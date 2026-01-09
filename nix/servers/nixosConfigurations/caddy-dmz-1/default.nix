{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) rpi nixpkgs self;
  inherit (cell) serverSuites hardwareProfiles nixosProfiles;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "dmz-1";
  hostIPv4 = "10.101.0.41";
  hostIPv6 = "2a0b:9401:64:101::41";
  valkeyHostname-a = "valkey-a.${hostName}.caddy.lan.gigglesquid.tech";
  valkeyHostname-b = "valkey-b.${hostName}.caddy.lan.gigglesquid.tech";
  valkeyHostname-c = "valkey-c.${hostName}.caddy.lan.gigglesquid.tech";
in
{
  inherit (rpi) bee time;
  networking = {
    inherit hostName;
    domain = "caddy.lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        6380
        6381
        6382
        16380
        16381
        16382
      ];
      allowedUDPPorts = [ ];
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.end0.arp_ignore" = 1;
    "net.ipv4.conf.end0.arp_announce" = 2;
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "end0";
        ipv6AcceptRAConfig = {
          Token = "static:::41";
        };
        address = [
          "${hostIPv4}/24"
        ];
        gateway = [
          "10.101.0.1"
        ];
      };
      "30-dummy0" = {
        matchConfig.Name = "dummy0";
        networkConfig = {
          IPv6AcceptRA = false;
          LinkLocalAddressing = "no";
        };
        address = [
          "10.100.0.10/32"
          "10.100.0.11/32"
          "2a0b:9401:64:100::10/128"
          "2a0b:9401:64:100::11/128"
        ];
      };
    };
    netdevs = {
      "20-dummy0" = {
        netdevConfig = {
          Kind = "dummy";
          Name = "dummy0";
        };
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key = { };
      crowdsec_bouncer_api_keys_env = { };
      "crowdsec_bouncer_api_keys/caddy_dmz-1_firewall" = { };
      "valkey/caddy-dmz/env" = { };
      "valkey/caddy-dmz/acl" = {
        group = "valkey";
        mode = "440";
      };
      "valkey/caddy-dmz/includes/replication" = {
        group = "valkey";
        mode = "440";
      };
    };
  };

  users.groups = {
    valkey = {
      members = [
        "redis-${hostName}-a"
        "redis-${hostName}-b"
        "redis-${hostName}-c"
      ];
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
      "${valkeyHostname-a}" = {
        group = "valkey";
      };
      "${valkeyHostname-b}" = {
        group = "valkey";
      };
      "${valkeyHostname-c}" = {
        group = "valkey";
      };
    };
  };

  systemd.services = {
    caddy = {
      after = [
        "redis-${hostName}-a.service"
        "redis-${hostName}-b.service"
        "redis-${hostName}-c.service"
      ];
      serviceConfig = {
        EnvironmentFile = [
          "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
          "${config.sops.secrets."valkey/caddy-dmz/env".path}"
        ];
      };
    };
    "redis-${hostName}-a".serviceConfig = {
      ExecStartPre = [ ''${lib.getExe' nixpkgs.coreutils "sleep"} 10'' ];
    };
    "redis-${hostName}-b".serviceConfig = {
      ExecStartPre = [ ''${lib.getExe' nixpkgs.coreutils "sleep"} 10'' ];
    };
    "redis-${hostName}-c".serviceConfig = {
      ExecStartPre = [ ''${lib.getExe' nixpkgs.coreutils "sleep"} 10'' ];
    };
  };

  services = {
    redis = {
      package = nixpkgs.valkey;
      servers = {
        "${hostName}-a" = {
          enable = true;
          bind = "127.0.0.1 ::1 ${hostIPv4} ${hostIPv6}";
          port = 6380;
          appendOnly = true;
          # requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          settings = {
            # # TLS
            # tls-port = 6380;
            # tls-cert-file = "${config.security.acme.certs.${valkeyHostname-a}.directory}/fullchain.pem";
            # tls-key-file = "${config.security.acme.certs.${valkeyHostname-a}.directory}/key.pem";
            # tls-ca-cert-dir = "/etc/ssl/certs";
            # tls-replication = true;
            # tls-cluster = true;
            # tls-auth-clients = false;
            # Includes
            include = "${config.sops.secrets."valkey/caddy-dmz/includes/replication".path}";
            # ACL
            aclfile = "${config.sops.secrets."valkey/caddy-dmz/acl".path}";
            # Cluster
            cluster-enabled = true;
            cluster-databases = 1;
            cluster-announce-hostname = "${valkeyHostname-a}";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
        "${hostName}-b" = {
          enable = true;
          bind = "127.0.0.1 ::1 ${hostIPv4} ${hostIPv6}";
          port = 6381;
          appendOnly = true;
          # requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          settings = {
            # # TLS
            # tls-port = 6381;
            # tls-cert-file = "${config.security.acme.certs.${valkeyHostname-b}.directory}/fullchain.pem";
            # tls-key-file = "${config.security.acme.certs.${valkeyHostname-b}.directory}/key.pem";
            # tls-ca-cert-dir = "/etc/ssl/certs";
            # tls-replication = true;
            # tls-cluster = true;
            # tls-auth-clients = false;
            # Includes
            include = "${config.sops.secrets."valkey/caddy-dmz/includes/replication".path}";
            # ACL
            aclfile = "${config.sops.secrets."valkey/caddy-dmz/acl".path}";
            # Cluster
            cluster-enabled = true;
            cluster-databases = 1;
            cluster-announce-hostname = "${valkeyHostname-b}";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
        "${hostName}-c" = {
          enable = true;
          bind = "127.0.0.1 ::1 ${hostIPv4} ${hostIPv6}";
          port = 6382;
          appendOnly = true;
          # requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          settings = {
            # # TLS
            # tls-port = 6382;
            # tls-cert-file = "${config.security.acme.certs.${valkeyHostname-c}.directory}/fullchain.pem";
            # tls-key-file = "${config.security.acme.certs.${valkeyHostname-c}.directory}/key.pem";
            # tls-ca-cert-dir = "/etc/ssl/certs";
            # tls-replication = true;
            # tls-cluster = true;
            # tls-auth-clients = false;
            # Includes
            include = "${config.sops.secrets."valkey/caddy-dmz/includes/replication".path}";
            # ACL
            aclfile = "${config.sops.secrets."valkey/caddy-dmz/acl".path}";
            # Cluster
            cluster-enabled = true;
            cluster-databases = 1;
            cluster-announce-hostname = "${valkeyHostname-c}";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
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

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_url = "https://crowdsec.lan.gigglesquid.tech:8443";
      };
      secrets = {
        apiKeyPath = "${config.sops.secrets."crowdsec_bouncer_api_keys/caddy_dmz-1_firewall".path}";
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.rpi4
        nixosProfiles.caddy-dmz
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
        home.stateVersion = "26.05";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "26.05";
      };
    };
  };

  system.stateVersion = "26.05";
}
