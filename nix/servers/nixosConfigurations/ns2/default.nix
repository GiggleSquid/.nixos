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
  hostName = "ns2";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = lib.mkForce "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::13";
          UseDNS = false;
        };
        address = [
          "10.3.0.13/23"
          "10.3.0.14/23"
          "2a0b:9401:64:3::14/64"
        ];
        gateway = [
          "10.3.0.1"
        ];
        dns = [
          "::1"
          "127.0.0.1"
        ];
      };
    };
  };

  sops.secrets = {
    bunny_dns_api_key = { };
    lego_pfx_pass = { };
    "harmonia/cache-key/ns2-dns-lan" = { };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      server = "https://acme-v02.api.letsencrypt.org/directory";
      email = "jack.connors@protonmail.com";
    };
    certs."ns2.dns.lan.gigglesquid.tech" = {
      extraLegoFlags = [
        "--dns.propagation-wait=300s"
      ];
      dnsResolver = "9.9.9.9";
      dnsProvider = "bunny";
      credentialFiles = {
        "BUNNY_API_KEY_FILE" = "${config.sops.secrets.bunny_dns_api_key.path}";
        "BUNNY_PROPAGATION_TIMEOUT_FILE" = nixpkgs.writeText "BUNNY_PROPAGATION_TIMEOUT" "360";
      };
      postRun = # bash
        ''
          openssl pkcs12 -export -out ns2.dns.lan.gigglesquid.tech.pfx -inkey key.pem -in cert.pem -certfile chain.pem -passout file:${config.sops.secrets.lego_pfx_pass.path}
          chown -v technitium-dns-server:technitium-dns-server ns2.dns.lan.gigglesquid.tech.pfx
          chmod -v 644 ns2.dns.lan.gigglesquid.tech.pfx
          cp -vp ns2.dns.lan.gigglesquid.tech.pfx /var/lib/technitium-dns-server/
        '';
    };
  };

  systemd.services = {
    wait-for-dns-resolution = {
      description = "Wait for DNS resolution to become available";
      after = [ "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe nixpkgs.bash} -c 'until ${lib.getExe' nixpkgs.host "host"} ns1.dns.lan.gigglesquid.tech; do ${lib.getExe' nixpkgs.coreutils "sleep"} 1; done'";
      };
    };
    caddy.after = [ "wait-for-dns-resolution.service" ];
  };

  services = {
    harmonia-dev = {
      daemon.enable = true;
      cache = {
        enable = true;
        signKeyPaths = [ config.sops.secrets."harmonia/cache-key/ns2-dns-lan".path ];
        settings = {
          bind = "unix:/run/harmonia/socket";
          priority = 30;
          enable_compression = true;
        };
      };
    };

    caddy-squid = {
      enable = true;
      extraGlobalConfig = "default_bind 10.3.0.14 2a0b:9401:64:3::14";
    };
    caddy.virtualHosts = {
      "harmonia.ns2.dns.lan.gigglesquid.tech" =
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
              handle {
                reverse_proxy unix//run/harmonia/socket
              }
            '';
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
          dns-server
          caddy-server
          harmonia
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
        home.stateVersion = "25.05";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "25.05";
      };
    };
  };

  system.stateVersion = "25.05";
}
