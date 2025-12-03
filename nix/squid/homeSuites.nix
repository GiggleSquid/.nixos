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
