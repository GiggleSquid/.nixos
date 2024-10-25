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
    k9s
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
    k9s
    helix
  ];

  plasma6 = gui ++ [ ];
}
