{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  # Check me
  # Currently not working in cosmic de
  home.pointerCursor = {
    enable = true;
    package = nixpkgs.catppuccin-cursors.mochaPeach;
    name = "catppuccin-mocha-peach-cursors";
    size = 32;
    gtk.enable = true;
  };
}
