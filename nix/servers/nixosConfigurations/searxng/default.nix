{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  inherit (inputs.cells.toolchain) pkgs;
  lib = nixpkgs.lib // builtins;
  hostName = "search";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        8080
      ];
      allowedUDPPorts = [ ];
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets."searxng_env_vars" = { };
  };

  services = {
    searx = {
      enable = true;
      package = pkgs.searxng;
      redisCreateLocally = true;
      environmentFile = config.sops.secrets."searxng_env_vars".path;
      runInUwsgi = true;
      uwsgiConfig = {
        http = ":8080";
      };
      settings = {
        search = {
          safe_search = 0;
          autocomplete = "duckduckgo";
          favicon_resolver = "duckduckgo";
          default_lang = "en";
        };
        server = {
          base_url = "https://search.gigglesquid.tech";
          port = 8080;
          bind_address = "0.0.0.0";
          secret_key = "@SEARX_SECRET_KEY@";
          method = "GET";
          public_instance = false;
          image_proxy = true;
          limiter = false;
        };
        engines = lib.mapAttrsToList (name: value: { inherit name; } // value) {
          "nixos wiki".disabled = false;
          "codeberg".disabled = false;
          "gitea.com".disabled = false;
          "gitlab".disabled = false;
          "caddy.community".disabled = false;
          "npm".disabled = false;
          "crates.io".disabled = false;
          "1337x".disabled = false;
          "nyaa".disabled = false;
          "annas archive".disabled = false;
          "reddit".disabled = false;
          "duckduckgo images".disabled = false;
          "duckduckgo videos".disabled = false;
          "wikibooks".disabled = false;
          "wikisource".disabled = false;
          "wikispecies".disabled = false;
        };
      };
      faviconsSettings = {
        favicons = {
          cfg_schema = 1;
          cache = {
            db_url = "/run/searx/faviconcache.db";
            LIMIT_TOTAL_BYTES = 2147483648;
            HOLD_TIME = 2592000;
            BLOB_MAX_BYTES = 40960;
            MAINTENANCE_MODE = "auto";
            MAINTENANCE_PERIOD = 3600;
          };
        };
      };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.servers ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          searxng
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
