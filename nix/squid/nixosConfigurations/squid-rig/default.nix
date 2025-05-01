{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell)
    machineProfiles
    hardwareProfiles
    nixosSuites
    homeSuites
    ;
  lib = nixpkgs.lib // builtins;
in
{
  inherit (common) bee time;
  networking = {
    hostName = "squid-rig";
    firewall = {
      allowedTCPPorts = [
        1313 # hugo
      ];
      allowedUDPPorts = [ ];
    };
  };

  systemd.network = {
    # netdevs = {
    #   "10-wg0" = {
    #     netdevConfig = {
    #       Kind = "wireguard";
    #       Name = "wg0";
    #       MTUBytes = "1300";
    #     };
    #     wireguardConfig = {
    #       PrivateKeyFile = "${config.sops.secrets."protonvpn/squid-rig/pk".path}";
    #       ListenPort = 51820;
    #       FirewallMark = 34952;
    #       RouteTable = "off";
    #     };
    #     wireguardPeers = [
    #       {
    #         PublicKey = "kNPJPSh9cam56piHoWP3ZVkWRgvgcuspf2X6IXhiZVU=";
    #         AllowedIPs = [
    #           "::/0"
    #         ];
    #         Endpoint = "[2a02:6ea0:1a01:5261::10]:51820";
    #       }
    #     ];
    #   };
    # };
    networks = {
      # "10-wg0" = {
      #   matchConfig.Name = "wg0";
      #   address = [
      #     "fdca:45ca:6140::10:2/128"
      #   ];
      #   dns = config.systemd.network.networks."10-lan".dns;
      #   routingPolicyRules = [
      #     {
      #       Family = "ipv6";
      #       SuppressPrefixLength = 0;
      #       Priority = 999;
      #       Table = "main";
      #     }
      #     {
      #       Family = "ipv6";
      #       FirewallMark = 34952;
      #       InvertRule = true;
      #       Table = 1000;
      #       Priority = 1000;
      #     }
      #     {
      #       To = "${ipv6Prefix}";
      #       Priority = 10;
      #     }
      #   ];
      #   routes = [
      #     {
      #       Gateway = "::";
      #       Table = 1000;
      #     }
      #   ];
      # };
      "10-lan" = {
        matchConfig.Name = "eno1";
        ipv6AcceptRAConfig = {
          Token = "static:::10";
        };
        address = [
          "10.10.0.10/24"
        ];
        gateway = [
          "10.10.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      "protonvpn/squid-rig/pk" = {
        owner = "systemd-network";
      };
    };
  };

  services = {
    xserver.xkb = lib.mkForce {
      layout = "us";
      variant = "colemak_dh_wide_iso";
    };
  };

  programs.ladybird.enable = false;

  imports =
    let
      profiles = [
        hardwareProfiles.squid-rig
        machineProfiles.squid-rig
      ];
      suites =
        with nixosSuites;
        lib.concatLists [
          desktop
          plasma6
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
            suites =
              with homeSuites;
              lib.concatLists [
                squid
                plasma6
              ];
          in
          lib.concatLists [
            modules
            profiles
            suites
          ];
        home.stateVersion = "25.05";
      };
    };
  };

  system.stateVersion = "25.05";
}
