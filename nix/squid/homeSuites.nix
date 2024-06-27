{ inputs, cell }:
let
  inherit (cell) homeProfiles homeModules;
in
with homeProfiles;
rec {
  base = [ core ];

  nixos = base ++ [
    ssh
    git
    shell
    k9s
    helix
  ];

  gui = [
    terminal
    browser
    packages
  ];

  squid = base ++ [
    gpg
    ssh
    git
    shell
    k9s
    helix
  ];

  plasma6 = gui ++ [
    homeModules.plasma-manager
    # plasma-manager
  ];
}
