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
    nameservers = [ "10.3.0.1" ];
    firewall = {
      allowedTCPPorts = [ 8443 ];
      allowedUDPPorts = [ ];
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key = { };
      crowdsec_enroll_key = {
        owner = "crowdsec";
      };
      crowdsec_caddy-internal_caddy_api_key_env = { };
      crowdsec_caddy-dmz_caddy_api_key_env = { };
      crowdsec_caddy-dmz_firewall_api_key_env = { };
      crowdsec_i2p_firewall_api_key_env = { };
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
      "${config.sops.secrets.crowdsec_caddy-internal_caddy_api_key_env.path}"
      "${config.sops.secrets.crowdsec_caddy-dmz_caddy_api_key_env.path}"
      "${config.sops.secrets.crowdsec_caddy-dmz_firewall_api_key_env.path}"
      "${config.sops.secrets.crowdsec_i2p_firewall_api_key_env.path}"
    ];

    ExecStartPre =
      let
        register-bouncers = # bash
          nixpkgs.writeScriptBin "register-bouncers" ''
            #!${nixpkgs.runtimeShell}
            set -eu
            set -o pipefail

            if ! cscli bouncers list | grep -q "caddy_internal.caddy.lan.gigglesquid.tech"; then
              cscli bouncers add "caddy_internal.caddy.lan.gigglesquid.tech" --key $CROWDSEC_CADDY_INTERNAL_CADDY_API_KEY
            fi

            if ! cscli bouncers list | grep -q "caddy_dmz.caddy.lan.gigglesquid.tech"; then
              cscli bouncers add "caddy_dmz.caddy.lan.gigglesquid.tech" --key $CROWDSEC_CADDY_DMZ_CADDY_API_KEY
            fi

            if ! cscli bouncers list | grep -q "firewall_dmz.caddy.lan.gigglesquid.tech"; then
              cscli bouncers add "firewall_dmz.caddy.lan.gigglesquid.tech" --key $CROWDSEC_CADDY_DMZ_FIREWALL_API_KEY
            fi

            if ! cscli bouncers list | grep -q "firewall_i2p.lan.gigglesquid.tech"; then
              cscli bouncers add "firewall_i2p.lan.gigglesquid.tech" --key $CROWDSEC_I2P_FIREWALL_API_KEY
            fi
          '';
        install-collections = # bash
          nixpkgs.writeScriptBin "install-collections" ''
            #!${nixpkgs.runtimeShell}
            set -eu
            set -o pipefail

            if ! cscli collections list | grep -q "crowdsecurity/caddy"; then
              cscli collections install crowdsecurity/caddy
            fi

            if ! cscli collections list | grep -q "crowdsecurity/linux"; then
              cscli collections install crowdsecurity/linux
            fi
          '';
        install-parsers = # bash
          nixpkgs.writeScriptBin "install-parsers" ''
            #!${nixpkgs.runtimeShell}
            set -eu
            set -o pipefail

            if ! cscli parsers list | grep -q "crowdsecurity/whitelists"; then
              cscli parsers install crowdsecurity/whitelists
            fi
          '';
      in
      [
        "${register-bouncers}/bin/register-bouncers"
        "${install-collections}/bin/install-collections"
        "${install-parsers}/bin/install-parsers"
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
