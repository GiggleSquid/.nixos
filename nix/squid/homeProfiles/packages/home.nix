{ inputs, cell }:
let
  inherit (inputs) nixpkgs;

  prismlauncher = nixpkgs.prismlauncher.override {
    jdks = with nixpkgs; [
      jdk23
      jdk21
      jdk17
      jdk8
    ];
    # withWaylandGLFW = true;
  };
in
{
  packages = with nixpkgs; [
    discord
    dust
    framesh
    freecad-qt6
    gimp
    gridcoin-research
    haruna
    imagemagick
    inkscape
    isoimagewriter
    # qt5 qtwebengine is unmaintained upstream since april 2025
    # https://github.com/jellyfin/jellyfin-media-player/issues/282
    jellyfin-media-player
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.skanpage
    libopus
    # See: https://github.com/NixOS/nixpkgs/issues/370715
    # https://bugzilla.redhat.com/show_bug.cgi?id=2248131
    # lmms
    # monero-gui
    packwiz
    path-of-building
    prismlauncher
    prusa-slicer
    scribus
    starsector
    steam-run
    storj-uplink
    tidal-hifi
    vintagestory
    vlc
  ];
}
