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
  hostName = "ns1";
in
{
  inherit (rpi) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = lib.mkForce "end0";
        ipv6AcceptRAConfig = {
          Token = "static:::11";
          UseDNS = false;
        };
        address = [
          "10.3.0.11/23"
          "10.3.0.12/23"
          "2a0b:9401:64:3::12/64"
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

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key = { };
      lego_pfx_pass = { };
      "harmonia/cache-key/ns1-dns-lan" = { };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      server = "https://acme-v02.api.letsencrypt.org/directory";
      email = "jack.connors@protonmail.com";
    };
    certs."ns1.dns.lan.gigglesquid.tech" = {
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
          openssl pkcs12 -export -out ns1.dns.lan.gigglesquid.tech.pfx -inkey key.pem -in cert.pem -certfile chain.pem -passout file:${config.sops.secrets.lego_pfx_pass.path}
          chown -v technitium-dns-server:technitium-dns-server ns1.dns.lan.gigglesquid.tech.pfx
          chmod -v 644 ns1.dns.lan.gigglesquid.tech.pfx
          cp -vp ns2.dns.lan.gigglesquid.tech.pfx /var/lib/technitium-dns-server/
        '';
    };
  };

  systemd.services = {
    caddy = {
      after = [ "technitium.service" ];
      serviceConfig = {
        # 5 min delay to allow technitium to provide dns resolution as this system
        # relies on itself for dns and caddy is using domains in trusted proxies
        ExecStartPre = lib.mkForce "${lib.getExe' nixpkgs.coreutils "sleep"} 300";
        TimeoutStartSec = 305;
      };
    };
  };

  services = {
    harmonia-dev = {
      daemon.enable = true;
      cache = {
        enable = true;
        signKeyPaths = [ config.sops.secrets."harmonia/cache-key/ns1-dns-lan".path ];
        settings = {
          bind = "unix:/run/harmonia/socket";
          priority = 30;
          enable_compression = true;
        };
      };
    };

    caddy-squid = {
      enable = true;
      extraGlobalConfig = "default_bind 10.3.0.12 2a0b:9401:64:3::12";
    };
    caddy.virtualHosts = {
      "harmonia.ns1.dns.lan.gigglesquid.tech" =
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
      profiles = [ hardwareProfiles.rpi4 ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base-rpi
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
