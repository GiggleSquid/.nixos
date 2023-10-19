{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  qt = {
    enable = true;
    platformTheme = "qtct";
    style.name = "kvantum";
  };

  # home.packages = with nixpkgs; [
  #   (catppuccin-kvantum.override {
  #     accent = "Peach";
  #     variant = "Mocha";
  #   })
  # ];

  xdg = {
    configFile = {
      # Don't ask me why, afaik just installing the package should make it available to Kvantum
      "Kvantum/Catppuccin-Mocha-Peach/Catppuccin-Mocha-Peach.kvconfig" = {
        source = "${nixpkgs.catppuccin-kvantum.override {
          variant = "Mocha";
          accent = "Peach";
        }}/share/Kvantum/Catppuccin-Mocha-Peach/Catppuccin-Mocha-Peach.kvconfig";
      };
      "Kvantum/Catppuccin-Mocha-Peach/Catppuccin-Mocha-Peach.svg" = {
        source = "${nixpkgs.catppuccin-kvantum.override {
          variant = "Mocha";
          accent = "Peach";
        }}/share/Kvantum/Catppuccin-Mocha-Peach/Catppuccin-Mocha-Peach.svg";
      };
      "Kvantum/kvantum.kvconfig" = {
        source = (nixpkgs.formats.ini {}).generate "kvantum.kvconfig" {
          General.theme = "Catppuccin-Mocha-Peach";
        };
      };

      # Set the icon theme for qtct which really should be detected from gtk. 2 weeks of my life to figure this one out
      "qt5ct/qt5ct.conf" = {
        source = (nixpkgs.formats.ini {}).generate "qt5ct.conf" {
          Appearance.icon_theme = "Papirus-Dark";
        };
      };
      "qt6ct/qt6ct.conf" = {
        source = (nixpkgs.formats.ini {}).generate "qt6ct.conf" {
          Appearance.icon_theme = "Papirus-Dark";
        };
      };
    };
  };
}
