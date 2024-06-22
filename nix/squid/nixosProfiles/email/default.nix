{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  programs.thunderbird = {
    enable = true;
    preferences = {
      "mailnews.default_sort_order" = 2;
    };
  };
  environment.systemPackages = with nixpkgs; [ protonmail-bridge-gui ];
}
