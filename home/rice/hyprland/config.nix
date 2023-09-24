{config, ...}: let
  pointer = config.home.pointerCursor;
in {
  wayland.windowManager.hyprland = {
    settings = {
      "$MOD" = "SUPER";

      exec-once = [
        "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
        "hyprpaper"
        "waybar"
        "dunst"
        "librewolf"
        "mullvad-vpd"
        "vorta -d"
        "gridcoinresearch"
      ];

      monitor = [
        "HDMI-A-1,1920x1080@60,0x0,1"
        "HDMI-A-2,1920x1080@60,1920x0,1"
        "DP-2,3440x1440@120,200x1080,1"
      ];

      input = {
        # keyboard layout
        kb_layout = "gb";
        follow_mouse = 1;
      };

      general = {
        # gaps
        gaps_in = 4;
        gaps_out = 8;

        # border thiccness
        border_size = 2;

        # active border color
        "col.active_border" = "rgb(fab387) rgb(cba6f7) 45deg";
        "col.group_border_active" = "rgba(88888888)";
        "col.group_border" = "rgba(00000088)";
      };

      decoration = {
        rounding = 5;
        multisample_edges = true;

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
        # disable redundant renders
        disable_hypr_chan = true;
        disable_splash_rendering = true;
        # window swallowing
        enable_swallow = true; # hide windows that spawn other windows
        swallow_regex = "foot|thunar|nemo"; # windows for which swallow is applied
        # dpms
        mouse_move_enables_dpms = true; # enable dpms on mouse/touchpad action
        key_press_enables_dpms = true; # enable dpms on keyboard action
        disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
        # groupbar stuff
        # this removes the ugly gradient around grouped windows - which sucks
        groupbar_titles_font_size = 11;
        groupbar_gradients = false;
      };

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
    };
  };
}
