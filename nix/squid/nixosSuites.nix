{ inputs, cell }:
let
  inherit (cell) nixosProfiles userProfiles nixosModules;
in
with nixosProfiles;
rec {
  base = [
    core
    fonts
    gpg
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

  plasma6 = [ nixosProfiles.plasma6 ];

  pc = base ++ [
    userProfiles.squid
    pipewire
    networking
    libreoffice
  ];

  desktop = pc ++ [
    games
    boinc
    virtualisation
  ];

  laptop = pc ++ [ games ];
}
