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
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ ];
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      crowdsec_enroll_key = {
        owner = "crowdsec";
      };
      crowdsec_caddy-internal_api_key_env = { };
      crowdsec_caddy-dmz_api_key_env = { };
    };
  };

  systemd.services.crowdsec.serviceConfig = {
    EnvironmentFile = [
      "${config.sops.secrets.crowdsec_caddy-internal_api_key_env.path}"
      "${config.sops.secrets.crowdsec_caddy-dmz_api_key_env.path}"
    ];

    ExecStartPre =
      let
        register-bouncer-caddy-internal = nixpkgs.writeScriptBin "register-bouncer-caddy-internal" ''
          #!${nixpkgs.runtimeShell}
          set -eu
          set -o pipefail

          if ! cscli bouncers list | grep -q "caddy-internal"; then
            cscli bouncers add "caddy-internal" --key $CROWDSEC_CADDY_INTERNAL_API_KEY
          fi
        '';
        register-bouncer-caddy-dmz = nixpkgs.writeScriptBin "register-bouncer-caddy-dmz" ''
          #!${nixpkgs.runtimeShell}
          set -eu
          set -o pipefail

          if ! cscli bouncers list | grep -q "caddy-dmz"; then
            cscli bouncers add "caddy-dmz" --key $CROWDSEC_CADDY_DMZ_API_KEY
          fi
        '';
        install-collection-caddy = nixpkgs.writeScriptBin "install-collection-caddy" ''
          #!${nixpkgs.runtimeShell}
          set -eu
          set -o pipefail

          if ! cscli collections list | grep -q "crowdsecurity/caddy"; then
            cscli collections install crowdsecurity/caddy
          fi
        '';
      in
      [
        "${register-bouncer-caddy-internal}/bin/register-bouncer-caddy-internal"
        "${register-bouncer-caddy-dmz}/bin/register-bouncer-caddy-dmz"
        "${install-collection-caddy}/bin/install-collection-caddy"
      ];
  };

  services.crowdsec = {
    enable = true;
    enrollKeyFile = "${config.sops.secrets.crowdsec_enroll_key.path}";
    settings = {
      api.server = {
        listen_uri = "10.3.0.50:8080";
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
          {job="caddy_access_log"}
        '';
        labels = {
          type = "caddy";
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
