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
      cosmic-ext-applet-minimon
      cosmic-ext-applet-privacy-indicator
      papirus-icon-theme
    ];
  };
}
