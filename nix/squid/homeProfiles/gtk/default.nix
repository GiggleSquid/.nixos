{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Peach-Dark";
      package = nixpkgs.catppuccin-gtk.override {
        accents = ["peach"];
        size = "compact";
        tweaks = ["rimless"];
        variant = "mocha";
      };
    };
    iconTheme = {
      package = nixpkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "peach";
      };
      name = "Papirus-Dark";
    };
  };
}
