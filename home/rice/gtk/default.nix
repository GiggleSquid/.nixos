{pkgs, ...}: {
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Peach-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["peach"];
        size = "compact";
        tweaks = ["rimless"];
        variant = "mocha";
      };
    };
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders;
      name = "Papirus-Dark";
    };
    font = {
      name = "Noto";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
    gtk2.extraConfig = ''
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
    '';
  };

  qt.enable = true;
  qt.platformTheme = "qtct";
  qt.style.name = "kvantum";

  home.packages = with pkgs; [
    (catppuccin-kvantum.override {
      accent = "Peach";
      variant = "Mocha";
    })
  ];

  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
    General.theme = "Catppuccin-Mocha-Peach";
  };

  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaPeach;
    name = "Catppuccin-Mocha-Peach-Cursors";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "32";
  };
}
