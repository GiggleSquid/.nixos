{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [./config.nix];
  home.packages = with pkgs;
  with inputs.xdg-portal-hyprland.packages.${pkgs.system}; [
    libnotify
    xdg-desktop-portal-hyprland
    wl-clipboard
    wl-clip-persist
    cliphist
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    enableNvidiaPatches = true;
  };

  services.wlsunset = {
    enable = true;
    latitude = "52.6";
    longitude = "0.1";
    temperature = {
      day = 6500;
      night = 4500;
    };
  };

  systemd.user = {
    targets = {
      # fake a tray to let apps start
      # https://github.com/nix-community/home-manager/issues/2064
      tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = ["graphical-session-pre.target"];
        };
      };

      hyprland-session = {
        Unit = {
          Wants = ["xdg-desktop-autostart.target"];
        };
      };
    };
    services = {
      xdg-desktop-portal-hyprland = {
        Unit = {
          Description = "Portal service (Hyprland implementation)";
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = "graphical-session.target";
        };
        Service = {
          Type = "dbus";
          BusName = "org.freedesktop.impl.portal.desktop.hyprland";
          ExecStart = "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
          Restart = "on-failure";
          Slice = "session.slice";
        };
      };
      cliphist = {
        Unit.Description = "Clipboard history";
        Service = {
          ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getBin pkgs.cliphist}/cliphist store";
          Restart = "always";
        };
      };
    };
  };
}
