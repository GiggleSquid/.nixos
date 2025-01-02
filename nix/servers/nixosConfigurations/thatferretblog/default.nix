{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) machineProfiles hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  inherit (inputs.cells.toolchain) pkgs;
  lib = nixpkgs.lib // builtins;
  hostName = "thatferretblog";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    nameservers = [ "10.3.0.1" ];
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [ ];
    };
  };

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 2500000;
    "net.core.wmem_max" = 2500000;
  };

  sops.secrets = {
    bunny_dns_api_key_caddy = {
      sopsFile = "${self}/sops/squid-rig.yaml";
      owner = "caddy";
    };
  };

  systemd.services.caddy.serviceConfig = {
    EnvironmentFile = [
      "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
    ];
  };

  services.caddy = {
    enable = true;
    package = nixpkgs.caddy.withPlugins {
      plugins = [
        "github.com/GiggleSquid/caddy-bunny-mirror@v1.5.2-mirror"
      ];
      hash = "sha256-RlvzmMNvugopm8gLQSsmZqnBFuKmu+am6E8k8M6rUi4=";
    };
    logFormat = ''
      level DEBUG
    '';
    email = "jack.connors@protonmail.com";
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    globalConfig = # caddyfile
      '''';
    extraConfig = # caddyfile
      ''
        (bunny_acme_settings_gigglesquid_tech) {
          tls {
            dns bunny {
              access_key {env.BUNNY_API_KEY}
              zone gigglesquid.tech
            }
            propagation_timeout -1
          }
        }
        (deny_non_local) {
          @denied not remote_ip private_ranges
          handle @denied {
            abort
          }
        }
      '';
    virtualHosts = {
      "http://thatferret.blog.lan.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_gigglesquid_tech
            import deny_non_local
            redir https://thatferret.blog.lan.gigglesquid.tech{uri} permanent
          '';
      };
      "thatferret.blog.lan.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            import bunny_acme_settings_gigglesquid_tech
            import deny_non_local
            root * "${pkgs.hugo-website-thatferretblog}"
            file_server
            encode zstd gzip
            @cache-images path_regexp \/.*\.(jpg|jpeg|png|gif|webp|ico)$
            @cache-assets path_regexp \/assets\/(js\/.*\.js|css\/.*\.css)$
            header @cache-images Cache-Control max-age=604800
            header @cache-assets Cache-Control max-age=345600
          '';
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.servers
        machineProfiles.caddy-squid
      ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
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