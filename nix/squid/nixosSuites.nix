{
  inputs,
  cell,
}: let
  inherit (cell) nixosProfiles userProfiles nixosModules;
in
  with nixosProfiles; rec {
    base = [core fonts gpg fish nixosModules.sops userProfiles.root];

    larva = [core fonts nixosModules.sops userProfiles.larvaRoot];

    server =
      base
      ++ [userProfiles.nixos userProfiles.squid];

    plasma5 = [
      nixosProfiles.plasma5
    ];

    pc =
      base
      ++ [
        userProfiles.squid
        pipewire
        networking
        polkit
      ];

    desktop =
      pc
      ++ [
        games
        boinc
        virtualisation
        partition-manager
      ];

    laptop =
      pc
      ++ [
        games
        partition-manager
      ];
  }
