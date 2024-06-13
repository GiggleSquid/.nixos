{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  packages = with nixpkgs; [
    kdePackages.filelight
    kdePackages.kcalc
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
    (writeShellApplication {
      name = "jellyfin-media-player";
      text = "${nixpkgs.jellyfin-media-player}/bin/jellyfinmediaplayer --disable-gpu";
    })
    (makeDesktopItem {
      name = "jellyfin-media-player";
      exec = "jellyfin-media-player";
      desktopName = "Jellyfin Media Player";
    })

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
