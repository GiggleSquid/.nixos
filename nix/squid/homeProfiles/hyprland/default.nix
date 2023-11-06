{
  inputs,
  cell,
}: let
  lib = inputs.nixpkgs.lib // builtins;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    enableNvidiaPatches = true;

    settings = {
      env = [
        "EDITOR, hx"
        "BROWSER, librewolf"

        "NIXOS_OZONE_WL, 1"

        "GDK_BACKEND, wayland, x11"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "QT_QPA_PLATFORM, wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"

        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"

        "XCURSOR_SIZE, 32"

        "LIBVA_DRIVER_NAME, nvidia"
        "GBM_BACKEND, nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME, nvidia"
        "WLR_NO_HARDWARE_CURSORS, 1"
        "WLR_BACKEND, vulkan"
        "WLR_RENDERER, vulkan"

        "SDL_VIDEODRIVER, wayland"
        "MOZ_ENABLE_WAYLAND, 1"
      ];

      exec-once = [
        # "hyprctl setcursor ${pointerCursor.name} ${lib.toString pointerCursor.size}"
        "hyprctl setcursor Catppuccin-Mocha-Peach-Cursors 32"
        "killall waybar; waybar"
        "dunst"
        "librewolf"
        # "mullvad-vpn"
        "vorta -d"
        # "gridcoinresearch"
      ];

      input = {
        kb_layout = "gb";
        follow_mouse = 2;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgb(fab387) rgb(cba6f7) 45deg";
      };

      group = {
        "col.border_active" = "rgba(88888888)";
        "col.border_inactive" = "rgba(00000088)";
        groupbar = {
          font_size = 11;
          gradients = false;
        };
      };

      decoration = {
        rounding = 5;

        blur = {
          enabled = true;
          size = 4;
          passes = 3;
          ignore_opacity = true;
          new_optimizations = true;
          xray = true;
          contrast = 0.7;
          brightness = 0.8;
        };

        drop_shadow = "yes";
        shadow_range = 10;
        shadow_render_power = 3;
        "col.shadow" = "rgba(292c3cee)";
      };

      animations = {
        enabled = true;

        bezier = [
          "easeInOutCirc,0.85,0,0.15,1"
        ];

        animation = [
          "windows,1,3,easeInOutCirc,popin"
          "windowsIn,1,3,easeInOutCirc,popin"
          "windowsOut,1,3,easeInOutCirc,popin"
          "windowsMove,1,3,easeInOutCirc,slide"

          "border,1,1,easeInOutCirc"
        ];
      };

      misc = {
        force_default_wallpaper = 0;
        disable_splash_rendering = true;
        enable_swallow = true;
        swallow_regex = "foot|thunar|nemo";
        # dpms
        mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
        key_press_enables_dpms = true; # enable dpms on keyboard action
        disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
      };

      "$MOD" = "SUPER";

      bind = [
        "$MOD,Q,exec,wezterm"
        "$MOD,C,killactive"
        "$MOD,M,exit"
        "$MOD,E,exec,dolphin"
        "$MOD,V,togglefloating,"
        "$MOD,P,pseudo," # dwindle
        "$MOD,S,togglesplit," # dwindle

        "$MOD,H,movefocus,l"
        "$MOD,L,movefocus,r"
        "$MOD,K,movefocus,u"
        "$MOD,J,movefocus,d"

        "$MOD,left,movefocus,l"
        "$MOD,right,movefocus,r"
        "$MOD,up,movefocus,u"
        "$MOD,down,movefocus,d"

        "$MOD,SPACE,exec,anyrun"
      ];

      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$MOD,mouse:272,movewindow"
        "$MOD,mouse:273,resizewindow"
      ];

      monitor = lib.mkDefault ",preferred,auto,1";
    };
  };
}
