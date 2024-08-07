{ inputs }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;
in
{
  security.polkit.enable = true;

  programs = {
    gnupg.agent.pinentryPackage = lib.mkForce nixpkgs.pinentry-qt;
    partition-manager.enable = true;
    kdeconnect.enable = true;
  };

  services = {
    # xserver.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = "kwin";
        };
      };
    };
    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages = with nixpkgs; [
    kdePackages.sddm-kcm
    kdePackages.kio-admin
    (catppuccin.override {
      themeList = [ "k9s" ];
      variant = "mocha";
      accent = "peach";
    })
    (catppuccin-kde.override {
      flavour = [ "mocha" ];
      accents = [ "peach" ];
      winDecStyles = [ "modern" ];
    })
    catppuccin-cursors.mochaPeach
    (catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "peach";
    })
  ];
}
