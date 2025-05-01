{ inputs, cell }:
let
  inherit (inputs) rpi;
in
{
  imports = [ cell.nixosConfigurations.timesquid-0 ];
  inherit (rpi) bee;

  deployment = rpi.deployment // {
    targetHost = "timesquid-0.ntp.lan.gigglesquid.tech";
    tags = (rpi.deployment.tags) ++ [
      "ntp"
      "timesquid-0"
    ];
  };
}
