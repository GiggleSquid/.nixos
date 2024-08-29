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
  hostName = "squidbit";
in
{
  inherit (common) bee time;

  sops.secrets."wg_priv_key/tentacle-0_squidbit" = {
    sopsFile = "${self}/sops/squid-rig.yaml";
    owner = "systemd-network";
  };

  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    nameservers = [ "10.4.0.1" ];
    useNetworkd = true;
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    netdevs = {
      "10-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.sops.secrets."wg_priv_key/tentacle-0_squidbit".path;
          ListenPort = 51820;
          FirewallMark = 34952;
        };
        wireguardPeers = [
          {
            PublicKey = "VJHNhHnzYw3UTJb6EDY+280TkNMtlz1SShJ7wMvGmkQ=";
            AllowedIPs = [ "0.0.0.0/0" ];
            Endpoint = "149.40.48.225:51820";
          }
        ];
      };
    };
    networks = {
      "10-lan" = {
        matchConfig.Name = lib.mkForce "en*18";
        DHCP = "no";
        address = [ "10.4.0.30/24" ];
        gateway = [ "10.4.0.1" ];
        dns = [ "10.4.0.1" ];
        ntp = [ "10.3.0.5" ];
      };

      "10-wg0" = {
        matchConfig.Name = "wg0";
        DHCP = "no";
        address = [ "10.2.0.2/32" ];
        gateway = [ "10.2.0.1" ];
        dns = [ "10.4.0.1" ];
        ntp = [ "10.3.0.5" ];
        routingPolicyRules = [
          {
            FirewallMark = 34952;
            InvertRule = true;
            Table = 1000;
            Priority = 10;
          }
          {
            To = "149.40.48.255/32";
            Priority = 5;
          }
          {
            To = "10.0.0.0/8";
            Priority = 9;
          }
        ];
        routes = [
          {
            Destination = "0.0.0.0/0";
            Table = 1000;
          }
        ];
      };
    };
  };

  services = {
    chrony = {
      enable = true;
      initstepslew = lib.mkDefault {
        enabled = true;
        threshold = 120;
      };
    };
    timesyncd.enable = false;
    resolved = {
      fallbackDns = [ ];
    };
    # openssh.listenAddresses = [ { addr = "10.4.0.30"; } ];
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    flaresolverr = {
      enable = true;
      package = pkgs.pkgs-flaresolverr-chromium-126.flaresolverr;
    };
    radarr = {
      enable = true;
      openFirewall = true;
    };
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    qbittorrent = {
      enable = true;
      openFirewall = true;
      waitForMounts = [
        "mnt-media.mount"
        "mnt-media-torrent\x2ddownloads.mount"
      ];
    };
  };

  environment.systemPackages = with nixpkgs; [
    recyclarr
    jdupes
    libnatpmp
    pkgs.py-natpmp
  ];

  fileSystems = {
    "/mnt/media" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media";
      fsType = "nfs";
      noCheck = true;
      options = [ "nolock" ];
    };
    "/mnt/media/torrent-downloads" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media/torrent-downloads";
      fsType = "nfs";
      noCheck = true;
      options = [ "nolock" ];
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.vms ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          squidbit
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
