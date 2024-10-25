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
  hostName = "ns-root";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    nameservers = [
      "10.3.0.11"
      "10.3.0.12"
    ];
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
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      email = "jack.connors@protonmail.com";
    };
    certs."ns-root.dns.lan.gigglesquid.tech" = {
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
          openssl pkcs12 -export -out ns-root.dns.lan.gigglesquid.tech.pfx -inkey key.pem -in cert.pem -certfile chain.pem -passout file:${config.sops.secrets.lego_pfx_pass.path}
          chown -v technitium-dns-server:technitium-dns-server ns-root.dns.lan.gigglesquid.tech.pfx
          chmod -v 644 ns-root.dns.lan.gigglesquid.tech.pfx
          cp -vp ns-root.dns.lan.gigglesquid.tech.pfx /var/lib/technitium-dns-server/
        '';
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
          dns-server
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
