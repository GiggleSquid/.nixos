{ inputs, cell }:
let
  inherit (inputs.cells.toolchain) pkgs;
in
{
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      google-fonts
      noto-fonts-emoji
      sarasa-gothic
      (iosevka-bin.override { variant = "Etoile"; })
      (iosevka-bin.override { variant = "Aile"; })
      (iosevka-bin.override { variant = "SS14"; })
      (nerdfonts.override {
        fonts = [
          "Iosevka"
          "IosevkaTerm"
          "IosevkaTermSlab"
        ];
      })
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Iosevka Etoile"
        "Sarasa Gothic CL"
      ];
      sansSerif = [
        "Iosevka Aile"
        "Sarasa Gothic CL"
      ];
      monospace = [ "Iosevka SS14" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
