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

    nixos = base;

    squid =
      base
      ++ [
        browser
        gpg
        git
        shell
        helix
        vorta
      ];

    hyprland = [
      homeProfiles.hyprland
      wallpaper
      qt
      gtk
      terminal
    ];
  }
