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
    # qt5 qtwebengine is unmaintained upstream since april 2025
    # https://github.com/jellyfin/jellyfin-media-player/issues/282
    # jellyfin-media-player
    discord
    tidal-hifi
    packwiz
    framesh
    storj-uplink
    path-of-building
    scribus
    freecad-qt6
    imagemagick
    # See: https://github.com/NixOS/nixpkgs/issues/370715
    # https://bugzilla.redhat.com/show_bug.cgi?id=2248131
    # lmms
  ];
}
