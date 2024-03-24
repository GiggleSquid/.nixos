{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  fonts = {
    enableDefaultPackages = false;
    packages = with nixpkgs; [
      noto-fonts-emoji
      sarasa-gothic
      (iosevka-bin.override { variant = "Etoile"; })
      (iosevka-bin.override { variant = "Aile"; })
      (iosevka-bin.override { variant = "SS14"; })
      (nerdfonts.override {
        fonts = [
          "Iosevka"
          "IosevkaTerm"
        ];
      })
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Iosevka Etoile"
        "Sarasa"
      ];
      sansSerif = [
        "Iosevka Aile"
        "Sarasa"
      ];
      monospace = [ "Iosevka SS14" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
