{pkgs, ...}: {
  services = {
    dbus = {
      packages = with pkgs; [dconf udisks2];
      enable = true;
    };
    journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=10M
    '';
    udisks2.enable = true;
  };

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    gamemode.enable = true;
    gamescope.enable = true;
    dconf.enable = true;
  };

  # compress half of the ram to use as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  environment = {
    systemPackages = with pkgs; [
    ];

    shellAliases = {
      l = "${pkgs.lsd}/bin/lsd -Al";
      mkdir = "mkdir -p";
    };
  };

  time = {
    timeZone = "Europe/London";
    hardwareClockInLocalTime = true;
  };

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
