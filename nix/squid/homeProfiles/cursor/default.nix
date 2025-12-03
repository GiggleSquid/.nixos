{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  home.pointerCursor = {
    enable = true;
    package = nixpkgs.catppuccin-cursors.mochaPeach;
    name = "Catppuccin-Mocha-Peach-Cursors";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };
}
