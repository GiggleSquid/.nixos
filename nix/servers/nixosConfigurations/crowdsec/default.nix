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
      allowedTCPPorts = [ 8443 ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::50";
        };
        address = [
          "10.3.0.50/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      ipv6_prefix_env = {
        owner = "crowdsec";
      };
      bunny_dns_api_key = { };
      crowdsec_enroll_key = {
        owner = "crowdsec";
      };
      crowdsec_bouncer_api_keys_env = { };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      server = "https://acme-v02.api.letsencrypt.org/directory";
      email = "jack.connors@protonmail.com";
    };
    certs."crowdsec.lan.gigglesquid.tech" = {
      group = "crowdsec";
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
  };

  systemd.services.crowdsec.serviceConfig = {
    EnvironmentFile = [
      "${config.sops.secrets.ipv6_prefix_env.path}"
      "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
    ];

    ExecStartPre =
      let
        register-bouncers =
          nixpkgs.writeScriptBin "register-bouncers" # bash
            ''
              #!${nixpkgs.runtimeShell}
              set -eu
              set -o pipefail

              declare -A bouncers=(
                ["caddy_dmz.caddy.lan.gigglesquid.tech"]="$CROWDSEC_CADDY_DMZ_CADDY_API_KEY"
                ["caddy_internal.caddy.lan.gigglesquid.tech"]="$CROWDSEC_CADDY_INTERNAL_CADDY_API_KEY"
                ["firewall_dmz.caddy.lan.gigglesquid.tech"]="$CROWDSEC_CADDY_DMZ_FIREWALL_API_KEY"
                ["firewall_i2p.lan.gigglesquid.tech"]="$CROWDSEC_I2P_FIREWALL_API_KEY"
                ["wordpress_thatferret.shop.lan.gigglesquid.tech"]="$CROWDSEC_THATFERRETSHOP_WORDPRESS_API_KEY"
              )

              for key in ''${!bouncers[@]}; do
                if ! cscli bouncers list | grep -q "$key"; then
                  cscli bouncers add "$key" --key ''${bouncers[''${key}]}
                fi
              done  
            '';
        install-collections =
          nixpkgs.writeScriptBin "install-collections" # bash
            ''
              #!${nixpkgs.runtimeShell}
              set -eu
              set -o pipefail

              collections=(
                "crowdsecurity/linux"
                "crowdsecurity/caddy"
                "crowdsecurity/appsec-generic-rules"
                "crowdsecurity/appsec-virtual-patching"
                "crowdsecurity/appsec-wordpress"
                "crowdsecurity/wordpress"
              )

              for i in ''${collections[@]}; do
                if ! cscli collections list | grep -q "$i"; then
                  cscli collections install $i
                fi
              done
            '';
        install-parsers =
          nixpkgs.writeScriptBin "install-parsers" # bash
            ''
              #!${nixpkgs.runtimeShell}
              set -eu
              set -o pipefail

              parsers=(
                "crowdsecurity/whitelists"
              )

              for i in ''${parsers[@]}; do
                if ! cscli parsers list | grep -q "$i"; then
                  cscli parsers install $i
                fi
              done
            '';
      in
      [
        "${register-bouncers}/bin/register-bouncers"
        "${install-collections}/bin/install-collections"
        "${install-parsers}/bin/install-parsers"
      ];
    ExecStartPost =
      let
        allowlist-ipv6Prefix =
          nixpkgs.writeScriptBin "allowlist-ipv6Prefix" # bash
            ''
              #!${nixpkgs.runtimeShell}
              set -eu
              set -o pipefail

              if ! cscli allowlist list | grep -q "ipv6_prefix"; then
                cscli allowlist create ipv6_prefix -d "Allow HE tunnel prefix"
              fi

              if ! cscli allowlist inspect ipv6_prefix | grep -q "''${IPV6_PREFIX}"; then
                cscli allowlist add ipv6_prefix ''${IPV6_PREFIX}
              fi
            '';
      in
      [
        "${allowlist-ipv6Prefix}/bin/allowlist-ipv6Prefix"
      ];
  };

  services.crowdsec = {
    enable = true;
    enrollKeyFile = "${config.sops.secrets.crowdsec_enroll_key.path}";
    settings = {
      api.server = {
        listen_uri = "0.0.0.0:8443";
        tls = {
          cert_file = "/var/lib/acme/crowdsec.lan.gigglesquid.tech/cert.pem";
          key_file = "/var/lib/acme/crowdsec.lan.gigglesquid.tech/key.pem";
          client_verification = "NoClientCert";
        };
      };
    };
    acquisitions = [
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
          crowdsec
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
