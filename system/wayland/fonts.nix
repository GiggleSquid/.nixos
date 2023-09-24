{
  pkgs,
  ...
}: {
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override {fonts = ["JetBrainsMono"];})
    ];

    enableDefaultPackages = false;

    fontconfig.defaultFonts = {
      serif = ["Noto"];
      sansSerif = ["Noto"];
      monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
    };
  };
}
