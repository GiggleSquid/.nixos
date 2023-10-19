{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  programs.hyprland.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with nixpkgs; [xdg-desktop-portal-hyprland];
  };

  security.polkit.enable = true;

  environment.systemPackages = with nixpkgs; [
    libsForQt5.polkit-kde-agent
  ];

  systemd = {
    user.services = {
      polkit-kde-authentication-agent-1 = {
        description = "polkit-kde-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        wants = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${nixpkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
    services = {
      seatd = {
        enable = true;
        description = "Seat management daemon";
        script = "${nixpkgs.seatd}/bin/seatd -g wheel";
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = "1";
        };
        wantedBy = ["multi-user.target"];
      };
    };
  };
}
