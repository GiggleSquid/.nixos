{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  pointerCursor = {
    package = nixpkgs.catppuccin-cursors.mochaPeach;
    name = "Catppuccin-Mocha-Peach-Cursors";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };
  packages = with nixpkgs; [
    libnotify
    wl-clipboard
    wl-clip-persist
    killall
    wpaperd

    libsForQt5.dolphin
    libsForQt5.baloo
    libsForQt5.filelight
    libsForQt5.ark
    libsForQt5.okular
  ];
}
