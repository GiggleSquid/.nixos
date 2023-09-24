{pkgs, ...}: {
  systemd.services = {
    seatd = {
      enable = true;
      description = "Seat management daemon";
      script = "${pkgs.seatd}/bin/seatd -g wheel";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
      };
      wantedBy = ["multi-user.target"];
    };
  };

  services = {
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    tailscale = {
      enable = true;
    };

    boinc = {
      enable = true;
      extraEnvPackages = with pkgs; [virtualbox ocl-icd linuxPackages.nvidia_x11];
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks -r --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    openssh.enable = true;
    udisks2.enable = true;
    printing.enable = true;
    fstrim.enable = true;
  };
}
