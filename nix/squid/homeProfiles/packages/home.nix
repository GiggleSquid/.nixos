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
    gimp
    gridcoin-research
    inkscape
    # monero-gui
    vintagestory
    starsector
    steam-run
    vlc
    jellyfin-media-player
    discord
    tidal-hifi
    ladybird
  ];
}
