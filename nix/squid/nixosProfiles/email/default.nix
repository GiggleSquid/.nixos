{ inputs }:
let
  inherit (inputs) nixpkgs;

  catppuccinThunderbird = nixpkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "thunderbird";
    rev = "0289f3bd9566f9666682f66a3355155c0d0563fc";
    hash = "sha256-07gT37m1+OhRTbUk51l0Nhx+I+tl1il5ayx2ow23APY=";
  };
in
{
  programs.thunderbird = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      Extensions.Install = [ "${catppuccinThunderbird}/themes/mocha/mocha-peach.xpi" ];
    };
    preferences = {
      "privacy.donottrackheader.enabled" = true;
      "mail.phishing.detection.enabled" = true;
      "mailnews.default_sort_order" = 2;
    };
  };
  environment.systemPackages = with nixpkgs; [ protonmail-bridge-gui ];
}
