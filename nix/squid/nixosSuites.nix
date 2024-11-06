{ inputs, cell }:
let
  inherit (cell) nixosProfiles userProfiles nixosModules;
in
with nixosProfiles;
rec {
  base = [
    core
    ssh
    fish
    nixosModules.sops
    userProfiles.root
  ];

  larva = [
    core
    fonts
    nixosModules.sops
    userProfiles.larvaRoot
  ];

  server = base ++ [
    userProfiles.nixos
    userProfiles.squid
  ];

  pc = base ++ [
    fonts
    gpg
    userProfiles.squid
    pipewire
    networking
    lazygit
    printing
    email
    archiving-utils
  ];

  desktop = pc ++ [
    games
    boinc
    openrgb
    virtualisation
  ];

  laptop = pc ++ [ games ];

  plasma6 = [ nixosProfiles.plasma6 ];
}
