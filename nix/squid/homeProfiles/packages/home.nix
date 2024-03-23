{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  packages = with nixpkgs; [
    kdePackages.filelight
    kdePackages.kcalc
    isoimagewriter
    libreoffice
    prismlauncher
    prusa-slicer
    qbittorrent
    gimp
    gridcoin-research
    inkscape
    jellyfin-media-player
    monero-gui
    vintagestory
    starsector
    bitwarden
    vorta

    #https://github.com/NixOS/nixpkgs/issues/159267#issuecomment-1037372237
    (writeShellApplication {
      name = "discord";
      text = "${pkgs.discord}/bin/discord --use-gl=desktop";
    })
    (makeDesktopItem {
      name = "discord";
      exec = "discord";
      desktopName = "Discord";
    })
  ];
}
