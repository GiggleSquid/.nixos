{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  settings = {
    auto-optimise-store = true;
    allowed-users = ["@wheel"];
    trusted-users = ["root" "@wheel"];
    experimental-features = "nix-command flakes";
  };

  registry.nixpkgs.flake = nixpkgs;
}
