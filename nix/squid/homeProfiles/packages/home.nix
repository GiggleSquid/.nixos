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
    # Check me
    # qt5 qtwebengine is unmaintained upstream since april 2025
    # work on qt6 is ongoing upstraem
    # nixpkgs has a draft https://github.com/NixOS/nixpkgs/pull/465340
    # so we've taken that pr as an input and overridden the src rev in an overlay
    pkgs.jellyfin-media-player
    kdePackages.filelight
    kdePackages.isoimagewriter
    kdePackages.skanpage
    kicad
    libopus
    # See: https://github.com/NixOS/nixpkgs/issues/370715
    # https://bugzilla.redhat.com/show_bug.cgi?id=2248131
    # lmms
    # monero-gui
    packwiz
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
    rusty-path-of-building
    scribus
    starsector
    steam-run
    storj-uplink
    tidal-hifi
    vintagestory
    vlc
  ];
}
