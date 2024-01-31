{inputs}: let
  inherit (inputs) nixpkgs;
in {
  gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };

  settings = {
    auto-optimise-store = true;
    allowed-users = ["@wheel"];
    trusted-users = ["root" "@wheel"];
    experimental-features = "nix-command flakes";
  };

  registry.nixpkgs.flake = nixpkgs;
}
