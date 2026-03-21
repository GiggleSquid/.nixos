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
    jellyfin-desktop
    kmymoney
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
