{
  i18n = let
    defaultLocale = "en_GB.UTF-8";
  in {
    inherit defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
    };
  };

  console = {
    earlySetup = true;
    keyMap = "uk";
    colors = [
      "1e1e2e"
      "181825"
      "313244"
      "45475a"
      "585b70"
      "cdd6f4"
      "f5e0dc"
      "b4befe"
      "f38ba8"
      "fab387"
      "f9e2af"
      "a6e3a1"
      "94e2d5"
      "89b4fa"
      "cba6f7"
      "f2cdcd"
    ];
  };
}
