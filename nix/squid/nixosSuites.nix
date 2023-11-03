{
  inputs,
  cell,
}: let
  inherit (cell) nixosProfiles userProfiles nixosModules;
in
  with nixosProfiles; rec {
    base = [core fonts gpg userProfiles.root nixosModules.sops];

    server =
      base
      ++ [userProfiles.nixos userProfiles.squid];

    pc =
      base
      ++ [
        pipewire
        networking
        polkit
      ];

    desktop =
      pc
      ++ [
        userProfiles.squid
        hyprland
        games
        greetd
        boinc
        virtualisation
        partition-manager
        # https://github.com/NixOS/nixpkgs/issues/263445 mullvad
      ];
  }
