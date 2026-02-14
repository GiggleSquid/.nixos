{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  hardware.steam-hardware.enable = true;

  environment.systemPackages = with nixpkgs; [
    protonup-qt
    protontricks
    wineWow64Packages.staging
    lutris
  ];

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
  };
}
