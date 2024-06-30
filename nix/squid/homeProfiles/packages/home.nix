{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  packages = with nixpkgs; [
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.skanpage
    isoimagewriter
    prismlauncher
    prusa-slicer
    qbittorrent
    gimp
    gridcoin-research
    inkscape
    monero-gui
    vintagestory
    starsector
    bitwarden
    vorta
    steam-run
    vlc
    jellyfin-media-player
    discord
  ];
}
