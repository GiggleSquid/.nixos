{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  enable = true;
  style = ./_style.css;
  settings = {
    mainBar = {
      layer = "top";
      position = "top";
      margin = "8 20 0 20";

      modules-left = [
        "network"
        "disk"
        "memory"
        "custom/gpu-usage"
        "custom/gpu-temperature"
        "cpu"
        "temperature#cpu"
      ];

      modules-center = [
        "clock"
      ];

      modules-right = [
        "tray"
        "pulseaudio"
        "network#2"
        "keyboard-state"
        "custom/wlogout"
      ];

      network = {
        interval = 5;
        min-length = 20;
        format-ethernet = "󰯎 {bandwidthUpBits}|{bandwidthDownBits}";
        tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
        format-disconnected = "Network Disconnected";
        tooltip-format-disconnected = "Network Disconnected";
      };

      "network#2" = {
        interval = 5;
        format-wifi = "{essid} {signalStrength}% ";
        tooltip-format-wifi = "{frequency} | {signaldBm}dBm\n{ifname}: {ipaddr}/{cidr}";
      };

      disk = {
        format = " {percentage_used}%";
      };

      memory = {
        interval = 5;
        format = " {}%";
        tooltip-format = "RAM: {used} / {total} GiB | Swap {swapUsed} / {swapTotal} GiB";
      };

      "custom/gpu-usage" = {
        exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits";
        return-type = "";
        format = "󰢮 {}%";
        interval = 5;
        min-length = 5;
      };

      "custom/gpu-temperature" = {
        exec = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits";
        format = "| {}°C";
        return-type = "";
        interval = 5;
      };

      cpu = {
        interval = 5;
        format = " {usage}%";
        min-length = 5;
      };

      "temperature#cpu" = {
        format = "| {temperatureC}°C";
        critical-threshold = 80;
        hwmod-path = "/sys/class/hwmon/hwmon1/temp1_input";
      };

      clock = {
        format = "{:%A, %d %b, %I:%M %p}";
        tooltip = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };

      pulseaudio = {
        format = "{icon} {volume}% | {format_source}";
        format-muted = "󰝟 {format_source}";
        format-source = " {volume}%";
        format-source-muted = "";
        format-icons = {
          default = ["" "" ""];
          headphone = "";
        };
        on-click-middle = "${nixpkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        on-click = "${nixpkgs.killall}/bin/killall pavucontrol || ${nixpkgs.pavucontrol}/bin/pavucontrol";
      };

      keyboard-state = {
        #"numlock": true,
        capslock = true;
        format = "{name} {icon} ";
        format-icons = {
          locked = "";
          unlocked = "";
        };
      };

      "custom/wlogout" = {
        format = "";
        on-click = "${nixpkgs.wlogout}/bin/wlogout";
      };
    };
  };
}
