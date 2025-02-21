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

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      bunny_dns_api_key = { };
      lego_pfx_pass = { };
      "pia/pia_env" = { };
      "pia/ca.rsa.4096.crt" = { };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      server = "https://acme-v02.api.letsencrypt.org/directory";
      email = "jack.connors@protonmail.com";
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
    certs = {
      "squidbit.lan.gigglesquid.tech" = {
        postRun = # bash
          ''
            cp -v key.pem /var/lib/qbittorrent/
            chown -v qbittorrent:qbittorrent /var/lib/qbittorrent/key.pem
            chmod -v 640 /var/lib/qbittorrent/key.pem

            cp -v fullchain.pem /var/lib/qbittorrent/
            chown -v qbittorrent:qbittorrent /var/lib/qbittorrent/fullchain.pem
            chmod -v 640 /var/lib/qbittorrent/fullchain.pem

            openssl pkcs12 -export -out squidbit.lan.gigglesquid.tech.pfx -inkey key.pem -in cert.pem -certfile chain.pem -passout file:${config.sops.secrets.lego_pfx_pass.path}

            cp -v squidbit.lan.gigglesquid.tech.pfx /var/lib/prowlarr/
            chown -v prowlarr:prowlarr /var/lib/prowlarr/squidbit.lan.gigglesquid.tech.pfx
            chmod -v 640 /var/lib/prowlarr/squidbit.lan.gigglesquid.tech.pfx

            cp -v squidbit.lan.gigglesquid.tech.pfx /var/lib/radarr/
            chown -v radarr:radarr /var/lib/radarr/squidbit.lan.gigglesquid.tech.pfx
            chmod -v 640 /var/lib/radarr/squidbit.lan.gigglesquid.tech.pfx

            cp -v squidbit.lan.gigglesquid.tech.pfx /var/lib/sonarr/
            chown -v sonarr:sonarr /var/lib/sonarr/squidbit.lan.gigglesquid.tech.pfx
            chmod -v 640 /var/lib/sonarr/squidbit.lan.gigglesquid.tech.pfx
          '';
      };
    };
  };

  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    nameservers = [ "10.3.0.1" ];
    useNetworkd = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        8888
        7777
        9595
      ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = lib.mkForce "en*18";
        DHCP = "no";
        address = [ "10.3.1.30/23" ];
        gateway = [ "10.3.0.1" ];
        dns = [ "10.3.0.1" ];
        ntp = [ "10.3.0.5" ];
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
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    flaresolverr = {
      enable = true;
      package = pkgs.nur.repos.xddxdd.flaresolverr-21hsmw;
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
      package = pkgs.qbittorrent-enhanced-nox;
      openFirewall = true;
      waitForMounts = [
        "mnt-media.mount"
        "mnt-media-torrent\x2ddownloads.mount"
      ];
    };
    pia-vpn = {
      enable = true;
      certificateFile = config.sops.secrets."pia/ca.rsa.4096.crt".path;
      environmentFile = config.sops.secrets."pia/pia_env".path;
      netdevConfig = ''
        [NetDev]
        Description=WireGuard PIA network device
        Name=''${interface}
        Kind=wireguard

        [WireGuard]
        FirewallMark=0x8888
        PrivateKey=$privateKey

        [WireGuardPeer]
        PublicKey=$(echo "$json" | jq -r '.server_key')
        AllowedIPs=0.0.0.0/0, ::/0
        Endpoint=''${wg_ip}:$(echo "$json" | jq -r '.server_port')
        PersistentKeepalive=25
      '';
      networkConfig = ''
        [Match]
        Name=''${interface}

        [Network]
        Description=WireGuard PIA network interface
        Address=''${peerip}/32
        DNS=10.3.0.1
        NTP=10.3.0.5

        [RoutingPolicyRule]
        FirewallMark=0x8888
        InvertRule=true
        Priority=10
        Table=1000

        [RoutingPolicyRule]
        Priority=5
        To=''${wg_ip}/32

        [RoutingPolicyRule]
        Priority=6
        To=''${meta_ip}/32

        [RoutingPolicyRule]
        Priority=9
        To=10.3.0.0/23

        [RoutingPolicyRule]
        Priority=9
        To=10.10.0.0/24

        [Route]
        Destination=0.0.0.0/0
        Table=1000
      '';
      portForward = {
        enable = true;
      };
    };
  };

  environment.systemPackages = with nixpkgs; [
    recyclarr
    jdupes
    wireguard-tools
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
