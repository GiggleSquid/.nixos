{ inputs, cell }:
let
  inherit (inputs) nixpkgs;

  prismlauncher = nixpkgs.prismlauncher.override {
    jdks = with nixpkgs; [
      jdk22
      jdk21
      jdk17
      jdk8
    ];
    # withWaylandGLFW = true;
  };
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
    haruna
    libopus
    jellyfin-media-player
    discord
    tidal-hifi
    lmms
    packwiz
    framesh
    storj-uplink
  ];
}
