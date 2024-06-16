{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  environment.systemPackages = with nixpkgs; [
    raspberrypi-eeprom
    libraspberrypi
    pps-tools
    gpsd
  ];

  services.gpsd = {
    enable = true;
    nowait = true;
    devices = [
      "/dev/ttyAMA0"
      "/dev/pps0"
    ];
    extraArgs = [
      "-r"
      "-s"
      "115200"
    ];
  };

  users.users.chrony = {
    extraGroups = [ "gpsd" ];
  };

  systemd.services."serial-getty@ttyAMA0".enable = false;

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", KERNEL=="ttyAMA0", OWNER="root", GROUP="gpsd", MODE="0660"
    SUBSYSTEM=="pps", KERNEL=="pps0", OWNER="root", GROUP="gpsd", MODE="0660"
  '';
}
