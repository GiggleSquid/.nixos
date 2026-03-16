{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  home.pointerCursor = {
    enable = true;
    package = nixpkgs.catppuccin-cursors.mochaPeach;
    name = "catppuccin-mocha-peach-cursors";
    size = 32;
    gtk.enable = true;
  };
}
