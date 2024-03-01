{
  inputs,
  cell,
}: let
  inherit (cell) homeProfiles;
in
  with homeProfiles; rec {
    base = [
      core
    ];

    nixos =
      base
      ++ [
        ssh
        git
        shell
        k9s
        helix
      ];

    gui = [
      qt
      gtk
      terminal
      browser
      packages
    ];

    squid =
      base
      ++ [
        gpg
        ssh
        git
        shell
        helix
      ];

    plasma5 = gui;

    hyprland =
      gui
      ++ [
        homeProfiles.hyprland
        wallpaper
      ];
  }
