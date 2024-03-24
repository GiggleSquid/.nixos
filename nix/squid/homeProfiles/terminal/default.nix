{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;
in
{
  # home.packages = with nixpkgs; [
  # (iosevka-bin.override {variant = "sgr-iosevka-term-ss14";})
  # ];

  programs.wezterm = {
    enable = true;
    extraConfig = lib.readFile ./_config.lua;
  };
}
