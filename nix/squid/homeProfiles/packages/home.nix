{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.toolchain) pkgs;
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
    kdePackages.isoimagewriter
    # Check me
    # qt5 qtwebengine is unmaintained upstream since april 2025
    # https://github.com/jellyfin/jellyfin-media-player/issues/282
    pkgs.jellyfin-media-player
    kdePackages.filelight
    kdePackages.skanpage
    libopus
    # See: https://github.com/NixOS/nixpkgs/issues/370715
    # https://bugzilla.redhat.com/show_bug.cgi?id=2248131
    # lmms
    # monero-gui
    packwiz
    rusty-path-of-building
    (prismlauncher.override {
      jdks = [
        jdk25
        jdk21
        jdk17
        jdk8
      ];
      # withWaylandGLFW = true;
    })
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
