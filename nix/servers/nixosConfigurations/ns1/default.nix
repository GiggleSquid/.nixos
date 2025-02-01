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
    nameservers = [ "127.0.0.1" ];
    timeServers = [ "10.3.0.5" ];
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key = { };
      lego_pfx_pass = { };
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
        "BUNNY_PROPAGATION_TIMEOUT_FILE" = nixpkgs.writeText "BUNNY_PROPAGATION_TIMEOUT" ''360'';
      };
      postRun = # bash
        ''
          openssl pkcs12 -export -out ns1.dns.lan.gigglesquid.tech.pfx -inkey key.pem -in cert.pem -certfile chain.pem -passout file:${config.sops.secrets.lego_pfx_pass.path}
          chown -v technitium-dns-server:technitium-dns-server ns1.dns.lan.gigglesquid.tech.pfx
          chmod -v 644 ns1.dns.lan.gigglesquid.tech.pfx
          cp -vp ns1.dns.lan.gigglesquid.tech.pfx /var/lib/technitium-dns-server/
        '';
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = lib.mkForce "end0";
        networkConfig = {
          DHCP = "no";
          Address = "10.3.0.11/23";
          Gateway = "10.3.0.1";
        };
        dns = [ "127.0.0.1" ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.ns1
      ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          dns-server
          rpi-server
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
        home.stateVersion = "24.11";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "24.11";
      };
    };
  };

  system.stateVersion = "24.11";
}
