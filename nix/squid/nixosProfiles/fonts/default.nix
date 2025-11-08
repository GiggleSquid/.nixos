{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.toolchain) pkgs;
in
{
  fonts = {
    enableDefaultPackages = false;
    packages = with nixpkgs; [
      pkgs.google-fonts
      noto-fonts-color-emoji
      sarasa-gothic
      (iosevka-bin.override { variant = "Etoile"; })
      (iosevka-bin.override { variant = "Aile"; })
      (iosevka-bin.override { variant = "SS14"; })
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka-term-slab
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
