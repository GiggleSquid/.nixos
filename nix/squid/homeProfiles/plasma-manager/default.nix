{
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace = {
      clickItemTo = "select";
      tooltipDelay = 300;
      theme = "default";
      colorScheme = "CatppuccinMochaPeach";
      cursorTheme = "Catppuccin-Mocha-Peach-Cursors";
      lookAndFeel = "Catppuccin-Mocha-Peach";
      iconTheme = "Papirus";
    };

    kwin = {
      titlebarButtons = {
        left = [ "keep-above-windows" ];
        right = [
          "minimize"
          "maximize"
          "close"
        ];
      };
      effects = {
        shakeCursor.enable = false;
      };
    };

    startup = { };

    panels = [
      {
        location = "bottom";
        height = 44;
        floating = true;
        screen = 0;
        hiding = "none";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General.launchers = [
                "applications:systemsettings.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:librewolf.desktop"
                "applications:org.wezfurlong.wezterm.desktop"
                "applications:steam.desktop"
                "applications:org.qbittorrent.qBittorrent.desktop"
                "applications:com.github.iwalton3.jellyfin-media-player.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
    configFile = {
      "baloofilerc"."General"."index hidden folders".value = true;
      "kxkbrc"."Layout"."LayoutList".value = "gb";
      "plasma-localerc"."Formats"."LANG".value = "en_GB.UTF-8";
      "powerdevilrc"."AC/Display"."TurnOffDisplayIdleTimeoutSec".value = 1200;
      "powerdevilrc"."AC/SuspendAndShutdown"."AutoSuspendAction".value = 0;
      "powerdevilrc"."BatteryManagement"."BatteryCriticalAction".value = 1;
    };
  };
}
