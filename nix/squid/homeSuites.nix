{ inputs, cell }:
let
  inherit (cell) homeProfiles homeModules;
in
with homeProfiles;
rec {
  base = [
    core
    shell
  ];

  nixos = base ++ [
    git
    helix
  ];

  gui = [
    terminal
    cursor
    browser
    libreoffice
    packages
  ];

  squid = base ++ [
    gpg
    git
    helix
  ];

  plasma6 = gui ++ [ ];
  cosmic = gui ++ [ ];
}
