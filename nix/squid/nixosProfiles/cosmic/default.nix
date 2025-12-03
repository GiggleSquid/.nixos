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
    cosmic.excludePackages = with nixpkgs; [
      networkmanagerapplet
      cosmic-term
    ];
    systemPackages = with nixpkgs; [
      (catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "peach";
      })
    ];
  };
}
