{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  services = {
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
  };

  environment = {
    cosmic.excludePackages = [
      nixpkgs.networkmanagerapplet
      nixpkgs.cosmic-term
    ];
    systemPackages = with nixpkgs; [
      catppuccin-cursors.mochaPeach
      (catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "peach";
      })
    ];
  };
}
