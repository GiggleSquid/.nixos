{ inputs, cell }:
let
  inherit (cell) nixosProfiles userProfiles nixosModules;
in
with nixosProfiles;
rec {
  base = [
    core
    ssh
    networking
    nixosModules.sops
    userProfiles.root
  ];

  larva = [
    core
    ssh
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
    nix-ld
  ];

  laptop = pc ++ [ games ];

  plasma6 = [ nixosProfiles.plasma6 ];
  cosmic = [ nixosProfiles.cosmic ];
}
